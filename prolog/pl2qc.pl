%% pl2qc.pl
%% Prolog to quantum circuit compiler.
%%
%% Compiles a finite-domain Prolog program and query into a reversible
%% quantum oracle   U_f |x>|y>|0..0> = |x>|y xor f(x)>|0..0>
%% where f(x) is true exactly when the query succeeds for the variable
%% binding encoded in the input registers x.
%%
%% Pipeline
%%   1. Each query variable becomes a register of ceil(log2 |Domain|) qubits.
%%   2. The query is unfolded against the program (bounded by depth/1),
%%      giving a Boolean formula over equality constraints:
%%        conjunction      -> and/1
%%        several clauses  -> or/1
%%        \+ G, X \= Y     -> not/1
%%        unification      -> eqc(Reg, Value) / eqq(Reg1, Reg2)
%%      Body-local variables are resolved classically during unfolding;
%%      only the query variables stay quantum.
%%   3. The formula is simplified and hash-consed, then synthesised into
%%      X / CNOT / Toffoli gates with ancillas (and -> Toffoli chain,
%%      or -> De Morgan, not -> free polarity flip).
%%   4. The result is copied to the output qubit and every ancilla is
%%      uncomputed (Bennett), so ancillas return to |0>.
%%
%% Supported goals: true, fail, false, (A,B), (A;B), (C->T;E), (C->T),
%% \+ G, A = B, A \= B, member(X, List) and calls to program predicates.
%% If-then-else is compiled as (C,T ; \+ C, E), which equals Prolog's
%% committed choice unless C has several solutions that disagree on T.
%% Recursion is unrolled to depth(D) nested calls (default 8); deeper
%% derivations count as failure.

:- module(pl2qc, [
    pl2qc/5,            % +Program, +Query, +Domains, +Options, -Oracle
    pl2qc_file/5,       % +File, +Query, +Domains, +Options, -Oracle
    pl2qc_formula/5,    % +Program, +Query, +Domains, +Options, -Formula
    read_program/2,     % +File, -Clauses
    oracle_circuit/2,   % +Oracle, -Circuit
    oracle_info/2,      % +Oracle, -info(Registers, Out, Ancillas, Formula)
    oracle_stats/2      % +Oracle, -Stats
]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(error)).

%% ------------------------------------------------------------------
%% Public interface
%% ------------------------------------------------------------------

%% pl2qc(+Program, +Query, +Domains, +Options, -Oracle)
%%   Program: list of clauses, e.g. [a(1), (g(X) :- a(X), b(X))]
%%   Query:   goal whose variables are listed in Domains
%%   Domains: list of Var-Values, e.g. [X-[0,1,2,3]]
%%   Options: depth(D)        recursion unrolling depth (default 8)
%%            names(Names)    register names, one per domain (default r1, r2, ...)
%%   Oracle:  oracle(circuit(Qubits, [], Gates), info(Registers, Out, Ancillas, Formula))
%%            Registers = [reg(Name, Values, BitQubits)], bit qubit 0 is the LSB.
pl2qc(Program, Query, Domains, Options, oracle(Circuit, Info)) :-
    compile_formula(Program, Query, Domains, Options, Formula, Regs),
    synthesise(Formula, Regs, Circuit, Info).

pl2qc_file(File, Query, Domains, Options, Oracle) :-
    read_program(File, Program),
    pl2qc(Program, Query, Domains, Options, Oracle).

pl2qc_formula(Program, Query, Domains, Options, Formula) :-
    compile_formula(Program, Query, Domains, Options, Formula, _).

read_program(File, Clauses) :-
    setup_call_cleanup(open(File, read, S),
                       read_clauses(S, Clauses),
                       close(S)).

read_clauses(S, Clauses) :-
    read_term(S, T, []),
    (   T == end_of_file
    ->  Clauses = []
    ;   nonvar(T), T = (:- _)
    ->  read_clauses(S, Clauses)
    ;   Clauses = [T|Rest],
        read_clauses(S, Rest)
    ).

oracle_circuit(oracle(Circuit, _), Circuit).
oracle_info(oracle(_, Info), Info).

oracle_stats(oracle(circuit(Qubits, _, Gates), info(Regs, _, Ancillas, _)),
             stats(qubits(NQ), inputs(NI), ancillas(NA), gates(NG),
                   toffolis(NT), cnots(NC), xs(NX))) :-
    length(Qubits, NQ),
    findall(Q, (member(reg(_, _, Qs), Regs), member(Q, Qs)), Inputs),
    length(Inputs, NI),
    length(Ancillas, NA),
    length(Gates, NG),
    aggregate_count(ccx(_, _, _), Gates, NT),
    aggregate_count(cx(_, _), Gates, NC),
    aggregate_count(x(_), Gates, NX).

aggregate_count(Pattern, List, N) :-
    include(subsumes_term(Pattern), List, Matching),
    length(Matching, N).

%% ------------------------------------------------------------------
%% Front end: program + query -> Boolean formula
%% ------------------------------------------------------------------

compile_formula(Program0, Query0, Domains0, Options, Formula, Regs) :-
    must_be(list, Program0),
    must_be(list, Domains0),
    copy_term(Query0-Domains0, Query-Domains),
    maplist(normalise_clause, Program0, Program),
    make_registers(Domains, Options, Regs),
    option_depth(Options, Depth),
    Ctx = ctx(Program, Regs),
    goal_formula(Query, Ctx, Depth, F0),
    validity_formulas(Regs, Valid),
    simp(and([F0|Valid]), Formula).

normalise_clause(Clause, _) :-
    var(Clause), !,
    instantiation_error(Clause).
normalise_clause((H :- B), cl(H, B)) :- !,
    must_be(callable, H).
normalise_clause(H, cl(H, true)) :-
    must_be(callable, H).

option_depth(Options, D) :-
    (   memberchk(depth(D0), Options)
    ->  must_be(nonneg, D0),
        D = D0
    ;   D = 8
    ).

make_registers(Domains, Options, Regs) :-
    (   memberchk(names(Names), Options) -> true ; Names = [] ),
    foldl(make_register(Names), Domains, Regs, 1, _).

make_register(Names, Spec, reg(Name, Values, Qubits), I0, I) :-
    I is I0 + 1,
    (   nonvar(Spec), Spec = Var-Values
    ->  true
    ;   domain_error(var_minus_values, Spec)
    ),
    must_be(list, Values),
    (   Values == [] -> domain_error(non_empty_domain, Spec) ; true ),
    (   ground(Values) -> true ; instantiation_error(Values) ),
    length(Values, Len),
    sort(Values, Distinct),
    (   length(Distinct, Len) -> true ; domain_error(distinct_values, Values) ),
    (   nth1(I0, Names, Name) -> true ; format(atom(Name), "r~w", [I0]) ),
    bits_needed(Len, B),
    B1 is B - 1,
    numlist(0, B1, Ks),
    maplist(bit_qubit(Name), Ks, Qubits),
    (   var(Var) -> Var = '$q'(Name) ; type_error(variable, Var) ).

bit_qubit(Name, K, Q) :-
    format(atom(Q), "~w_~w", [Name, K]).

bits_needed(Len, B) :-
    bits_needed_(Len, 1, B).

bits_needed_(Len, B0, B) :-
    (   (1 << B0) >= Len
    ->  B = B0
    ;   B1 is B0 + 1,
        bits_needed_(Len, B1, B)
    ).

%% Unused codes of a register (when |Domain| is not a power of two)
%% must never be marked, so the formula is conjoined with
%% "register holds one of its values".
validity_formulas(Regs, Fs) :-
    findall(or(Eqs),
            ( member(reg(N, Vs, Qs), Regs),
              length(Vs, L),
              length(Qs, B),
              L < 1 << B,
              findall(eqc(N, V), member(V, Vs), Eqs)
            ),
            Fs).

%% goal_formula(+Goal, +Ctx, +Depth, -Formula)
%% Disjunction over all ways Goal can succeed. Bindings are not exported.
goal_formula(G, Ctx, D, or(Fs)) :-
    findall(F, branch(G, Ctx, D, F), Fs).

%% branch(+Goal, +Ctx, +Depth, -Formula)
%% Nondeterministic: each solution is one group of derivations that
%% bind Goal's variables the same way; Formula is the condition (over
%% the quantum registers) under which that group succeeds.
branch(G, _, _, _) :-
    var(G), !,
    instantiation_error(G).
branch('$q'(N), _, _, _) :- !,
    type_error(callable, '$q'(N)).
branch(true, _, _, true) :- !.
branch(fail, _, _, false) :- !.
branch(false, _, _, false) :- !.
branch((A, B), Ctx, D, and([FA, FB])) :- !,
    branch(A, Ctx, D, FA),
    branch(B, Ctx, D, FB).
branch((C -> T ; E), Ctx, D, F) :- !,
    branch(((C, T) ; (\+ C, E)), Ctx, D, F).
branch((A ; B), Ctx, D, F) :- !,
    (   branch(A, Ctx, D, F)
    ;   branch(B, Ctx, D, F)
    ).
branch((C -> T), Ctx, D, F) :- !,
    branch((C, T), Ctx, D, F).
branch(\+ G, Ctx, D, not(F)) :- !,
    goal_formula(G, Ctx, D, F).
branch(A \= B, Ctx, D, F) :- !,
    branch(\+ A = B, Ctx, D, F).
branch(A = B, Ctx, _, and(Cs)) :- !,
    unify_q(A, B, Ctx, Cs).
branch(member(X, L), Ctx, D, F) :- !,
    must_be(list, L),
    member(E, L),
    branch(X = E, Ctx, D, F).
branch(G, Ctx, D, F) :-
    callable(G), !,
    Ctx = ctx(Program, _),
    functor(G, Name, Arity),
    (   member(cl(H, _), Program),
        functor(H, Name, Arity)
    ->  true
    ;   existence_error(procedure, Name/Arity)
    ),
    D > 0,
    D1 is D - 1,
    term_variables(G, Vs),
    findall(Vs-FD, derivation(G, Ctx, D1, FD), Pairs),
    group_alternatives(Pairs, Groups),
    member(Vs-F, Groups).
branch(G, _, _, _) :-
    type_error(callable, G).

%% derivation(+Goal, +Ctx, +Depth, -Formula): resolve Goal with one clause.
derivation(G, Ctx, D, and([and(Cs), FB])) :-
    Ctx = ctx(Program, _),
    functor(G, Name, Arity),
    member(Cl0, Program),
    Cl0 = cl(H0, _),
    functor(H0, Name, Arity),
    copy_term(Cl0, cl(H, B)),
    unify_q(G, H, Ctx, Cs),
    branch(B, Ctx, D, FB).

%% Derivations that leave the goal's variables bound the same way are
%% merged into one or/1, which keeps the circuit factored by clause.
group_alternatives([], []).
group_alternatives([K-F|Rest], [K-or([F|Fs])|Groups]) :-
    partition_variant(Rest, K, Fs, Others),
    group_alternatives(Others, Groups).

partition_variant([], _, [], []).
partition_variant([K2-F|Rest], K, Fs, Others) :-
    (   K2 =@= K
    ->  Fs = [F|Fs1],
        Others = Others1
    ;   Fs = Fs1,
        Others = [K2-F|Others1]
    ),
    partition_variant(Rest, K, Fs1, Others1).

%% unify_q(+A, +B, +Ctx, -Constraints)
%% Unification where '$q'(Reg) stands for an unknown register value.
%% Nondeterministic when a register meets a partial term: one solution
%% per domain value that unifies with it.
unify_q(A, B, _, []) :-
    var(A), !,
    A = B.
unify_q(A, B, _, []) :-
    var(B), !,
    B = A.
unify_q('$q'(N), '$q'(M), _, Cs) :- !,
    (   N == M -> Cs = [] ; Cs = [eqq(N, M)] ).
unify_q('$q'(N), T, Ctx, [eqc(N, V)]) :- !,
    reg_values(Ctx, N, Vs),
    member(V, Vs),
    V = T.
unify_q(T, '$q'(N), Ctx, Cs) :- !,
    unify_q('$q'(N), T, Ctx, Cs).
unify_q(A, B, Ctx, Cs) :-
    compound(A),
    compound(B), !,
    A =.. [F|As],
    B =.. [F|Bs],
    same_length(As, Bs),
    unify_args(As, Bs, Ctx, Cs).
unify_q(A, B, _, []) :-
    A == B.

unify_args([], [], _, []).
unify_args([A|As], [B|Bs], Ctx, Cs) :-
    unify_q(A, B, Ctx, C1),
    unify_args(As, Bs, Ctx, C2),
    append(C1, C2, Cs).

reg_values(ctx(_, Regs), N, Vs) :-
    memberchk(reg(N, Vs, _), Regs).

%% ------------------------------------------------------------------
%% Formula simplification (canonical, so equal subformulas share gates)
%% ------------------------------------------------------------------

simp(true, true) :- !.
simp(false, false) :- !.
simp(eqc(N, V), eqc(N, V)) :- !.
simp(eqq(N, M), S) :- !,
    (   N == M
    ->  S = true
    ;   msort([N, M], [A, B]),
        S = eqq(A, B)
    ).
simp(not(F), S) :- !,
    simp(F, S1),
    negate(S1, S).
simp(and(Fs), S) :- !,
    maplist(simp, Fs, Ss),
    combine(and, Ss, S).
simp(or(Fs), S) :- !,
    maplist(simp, Fs, Ss),
    combine(or, Ss, S).
simp(F, _) :-
    domain_error(pl2qc_formula, F).

negate(true, false) :- !.
negate(false, true) :- !.
negate(not(F), F) :- !.
negate(F, not(F)).

combine(Op, Ss, S) :-
    absorbing(Op, Zero),
    identity(Op, One),
    flatten_op(Ss, Op, Flat),
    (   memberchk(Zero, Flat)
    ->  S = Zero
    ;   exclude(==(One), Flat, F1),
        sort(F1, F2),
        (   member(X, F2),
            negate(X, NX),
            memberchk(NX, F2)
        ->  S = Zero
        ;   F2 == []
        ->  S = One
        ;   F2 = [S]
        ->  true
        ;   S =.. [Op, F2]
        )
    ).

absorbing(and, false).
absorbing(or, true).
identity(and, true).
identity(or, false).

flatten_op([], _, []).
flatten_op([S|Ss], Op, Flat) :-
    (   S =.. [Op, Inner]
    ->  append(Inner, Rest, Flat)
    ;   Flat = [S|Rest]
    ),
    flatten_op(Ss, Op, Rest).

%% ------------------------------------------------------------------
%% Synthesis: formula -> reversible circuit
%% ------------------------------------------------------------------
%% A literal lit(Q, P) means "qubit Q equals P"; P = 0 is a negated
%% literal, realised by X gates around the gate that uses it.
%% State st(RevGates, Memo, NextAncilla, RevAncillas).

synthesise(Formula, Regs,
           circuit(Qubits, [], Gates),
           info(Regs, Out, Ancillas, Formula)) :-
    Out = out,
    empty_assoc(M0),
    synth(Formula, Regs, Lit, st([], M0, 0, []), st(RevCompute, _, _, RevAnc)),
    reverse(RevCompute, Compute),
    copy_out(Lit, Out, Copy),
    % Compute uses only X and Toffoli gates, which are self-inverse,
    % so the reversed sequence uncomputes every ancilla.
    append([Compute, Copy, RevCompute], Gates0),
    peephole(Gates0, Gates),
    reverse(RevAnc, Ancillas),
    findall(Q, (member(reg(_, _, Qs), Regs), member(Q, Qs)), Inputs),
    append([Inputs, [Out], Ancillas], Qubits).

copy_out(lit(Q, 1), Out, [cx(Q, Out)]).
copy_out(lit(Q, 0), Out, [cx(Q, Out), x(Out)]).

synth(F, Regs, Lit, S0, S) :-
    S0 = st(_, M0, _, _),
    (   get_assoc(F, M0, Lit0)
    ->  Lit = Lit0,
        S = S0
    ;   synth_(F, Regs, Lit, S0, st(G1, M1, N1, A1)),
        put_assoc(F, M1, Lit, M2),
        S = st(G1, M2, N1, A1)
    ).

% A fresh ancilla is |0>, so it is the constant false; negated, true.
synth_(true, _, lit(A, 0), S0, S) :- !,
    fresh_ancilla(A, S0, S).
synth_(false, _, lit(A, 1), S0, S) :- !,
    fresh_ancilla(A, S0, S).
synth_(not(F), Regs, lit(Q, P1), S0, S) :- !,
    synth(F, Regs, lit(Q, P), S0, S),
    P1 is 1 - P.
synth_(and(Fs), Regs, Lit, S0, S) :- !,
    synth_list(Fs, Regs, Lits, S0, S1),
    and_lits(Lits, Lit, S1, S).
synth_(or(Fs), Regs, lit(Q, P1), S0, S) :- !,
    synth_list(Fs, Regs, Lits, S0, S1),
    maplist(flip_lit, Lits, NLits),
    and_lits(NLits, lit(Q, P), S1, S),
    P1 is 1 - P.
synth_(eqc(N, V), Regs, Lit, S0, S) :- !,
    memberchk(reg(N, Vs, Qs), Regs),
    once(nth0(Code, Vs, V)),
    code_lits(Qs, 0, Code, Lits),
    and_lits(Lits, Lit, S0, S).
synth_(eqq(N, M), Regs, Lit, S0, S) :- !,
    memberchk(reg(N, VN, _), Regs),
    memberchk(reg(M, VM, _), Regs),
    findall(and([eqc(N, V), eqc(M, V)]),
            ( member(V, VN), memberchk(V, VM) ),
            Alts),
    simp(or(Alts), F),
    synth(F, Regs, Lit, S0, S).
synth_(F, _, _, _, _) :-
    domain_error(pl2qc_formula, F).

synth_list([], _, [], S, S).
synth_list([F|Fs], Regs, [L|Ls], S0, S) :-
    synth(F, Regs, L, S0, S1),
    synth_list(Fs, Regs, Ls, S1, S).

code_lits([], _, _, []).
code_lits([Q|Qs], K, Code, [lit(Q, B)|Ls]) :-
    B is (Code >> K) /\ 1,
    K1 is K + 1,
    code_lits(Qs, K1, Code, Ls).

flip_lit(lit(Q, P), lit(Q, P1)) :-
    P1 is 1 - P.

%% and_lits(+Lits, -Lit, +S0, -S): AND of literals via a Toffoli chain.
and_lits(Lits0, Lit, S0, S) :-
    sort(Lits0, Lits),
    (   member(lit(Q, 0), Lits),
        memberchk(lit(Q, 1), Lits)
    ->  synth_(false, [], Lit, S0, S)
    ;   Lits == []
    ->  synth_(true, [], Lit, S0, S)
    ;   and_chain(Lits, Lit, S0, S)
    ).

and_chain([L], L, S, S) :- !.
and_chain([L1, L2|Ls], Lit, S0, S) :-
    fresh_ancilla(A, S0, S1),
    toffoli_gates(L1, L2, A, Gs),
    emit(Gs, S1, S2),
    and_chain([lit(A, 1)|Ls], Lit, S2, S).

toffoli_gates(lit(Q1, P1), lit(Q2, P2), T, Gates) :-
    wrap(Q1, P1, W1),
    wrap(Q2, P2, W2),
    append([W1, W2, [ccx(Q1, Q2, T)], W2, W1], Gates).

wrap(Q, 0, [x(Q)]).
wrap(_, 1, []).

emit(Gs, st(G0, M, N, A), st(G, M, N, A)) :-
    reverse(Gs, R),
    append(R, G0, G).

fresh_ancilla(Q, st(G, M, N, A), st(G, M, N1, [Q|A])) :-
    format(atom(Q), "anc_~w", [N]),
    N1 is N + 1.

%% Cancel adjacent identical self-inverse gates (cascading).
peephole(Gates, Out) :-
    foldl(push_gate, Gates, [], Rev),
    reverse(Rev, Out).

push_gate(G, [G0|Stack], Stack) :-
    G == G0,
    self_inverse(G), !.
push_gate(G, Stack, [G|Stack]).

self_inverse(x(_)).
self_inverse(cx(_, _)).
self_inverse(ccx(_, _, _)).
self_inverse(h(_)).
self_inverse(z(_)).
