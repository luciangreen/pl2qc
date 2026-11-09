%% pl2qc_sim.pl
%% Checking, simulating and exporting pl2qc oracles.
%%
%%   oracle_eval/3          classical evaluation on one binding (also checks
%%                          that every ancilla and input is restored)
%%   oracle_solutions/2     all bindings the oracle marks
%%   oracle_marked_count/2  number of marked basis inputs (M for Grover)
%%   phase_oracle/2         oracle with output qubit in |->  (phase kickback)
%%   diffusion/4            Grover diffusion over the input qubits
%%   grover_circuit/3       full Grover search circuit with measurements
%%   grover_run/3           simulate it and return P-Values, most likely first
%%   simulate/2             sparse real statevector simulator for
%%                          x, cx, ccx, h, z (the gates pl2qc emits)
%%   circuit_to_qasm/2      OpenQASM 2.0 export

:- module(pl2qc_sim, [
    oracle_eval/3,
    oracle_solutions/2,
    oracle_marked_count/2,
    phase_oracle/2,
    diffusion/4,
    grover_circuit/3,
    grover_run/3,
    simulate/2,
    circuit_to_qasm/2
]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(aggregate)).
:- use_module(library(error)).
:- use_module(pl2qc, [oracle_circuit/2, oracle_info/2]).

%% ------------------------------------------------------------------
%% Classical evaluation (oracles contain only X, CNOT and Toffoli)
%% ------------------------------------------------------------------

%% oracle_eval(+Oracle, +Values, -Bool)
%%   Values: one domain value per register, in Domains order.
oracle_eval(Oracle, Values, Bool) :-
    oracle_info(Oracle, info(Regs, _, _, _)),
    must_be(list, Values),
    maplist(value_code, Regs, Values, Codes),
    eval_codes(Oracle, Codes, R),
    (   R =:= 1 -> Bool = true ; Bool = false ).

value_code(reg(N, Vs, _), V, C) :-
    (   nth0(C0, Vs, V)
    ->  C = C0
    ;   domain_error(value_of(N), V)
    ).

%% eval_codes(+Oracle, +Codes, -OutBit)
%% Throws pl2qc_dirty_qubit/2 if any qubit other than the output is
%% left changed, i.e. if uncomputation failed.
eval_codes(oracle(circuit(Qubits, _, Gates), info(Regs, Out, _, _)), Codes, Result) :-
    empty_assoc(E),
    foldl(load_reg, Regs, Codes, E, B0),
    eval_gates(Gates, B0, B),
    forall(member(Q, Qubits),
           (   Q == Out
           ->  true
           ;   bit(Q, B0, V), bit(Q, B, V)
           ->  true
           ;   throw(error(pl2qc_dirty_qubit(Q, Codes), _))
           )),
    bit(Out, B, Result).

load_reg(reg(_, _, Qs), Code, B0, B) :-
    load_bits(Qs, 0, Code, B0, B).

load_bits([], _, _, B, B).
load_bits([Q|Qs], K, Code, B0, B) :-
    V is (Code >> K) /\ 1,
    put_assoc(Q, B0, V, B1),
    K1 is K + 1,
    load_bits(Qs, K1, Code, B1, B).

eval_gates([], B, B).
eval_gates([G|Gs], B0, B) :-
    eval_gate(G, B0, B1),
    eval_gates(Gs, B1, B).

eval_gate(x(Q), B0, B) :- !,
    flip(Q, B0, B).
eval_gate(cx(C, T), B0, B) :- !,
    (   bit(C, B0, 1) -> flip(T, B0, B) ; B = B0 ).
eval_gate(ccx(A, C, T), B0, B) :- !,
    (   bit(A, B0, 1), bit(C, B0, 1) -> flip(T, B0, B) ; B = B0 ).
eval_gate(G, _, _) :-
    domain_error(classical_gate, G).

bit(Q, B, V) :-
    (   get_assoc(Q, B, V0) -> V = V0 ; V = 0 ).

flip(Q, B0, B) :-
    bit(Q, B0, V),
    V1 is 1 - V,
    put_assoc(Q, B0, V1, B).

%% oracle_solutions(+Oracle, -Solutions)
oracle_solutions(Oracle, Solutions) :-
    oracle_info(Oracle, info(Regs, _, _, _)),
    findall(Values,
            ( maplist(reg_member, Regs, Values),
              oracle_eval(Oracle, Values, true)
            ),
            Solutions).

reg_member(reg(_, Vs, _), V) :-
    member(V, Vs).

%% oracle_marked_count(+Oracle, -M): over all 2^n input codes,
%% including codes that do not stand for any domain value.
oracle_marked_count(Oracle, M) :-
    oracle_info(Oracle, info(Regs, _, _, _)),
    aggregate_all(count,
                  ( maplist(reg_code, Regs, Codes),
                    eval_codes(Oracle, Codes, 1)
                  ),
                  M).

reg_code(reg(_, _, Qs), C) :-
    length(Qs, B),
    Max is (1 << B) - 1,
    between(0, Max, C).

%% ------------------------------------------------------------------
%% Grover search
%% ------------------------------------------------------------------

%% phase_oracle(+Oracle, -Gates): |x> -> (-1)^f(x) |x>, output qubit
%% prepared in |-> and returned to |0>.
phase_oracle(Oracle, Gates) :-
    oracle_circuit(Oracle, circuit(_, _, G)),
    oracle_info(Oracle, info(_, Out, _, _)),
    append([[x(Out), h(Out)], G, [h(Out), x(Out)]], Gates).

%% diffusion(+Inputs, +AncillaPool, -Gates, -ExtraAncillas)
%% H X (multi-controlled Z) X H. The oracle's ancillas are clean between
%% oracle calls, so they are reused for the multi-controlled gate.
diffusion(Inputs, Pool, Gates, Extra) :-
    maplist(gate_h, Inputs, Hs),
    maplist(gate_x, Inputs, Xs),
    append(Cs, [T], Inputs), !,
    mcz(Cs, T, Pool, Mid, Extra),
    append([Hs, Xs, Mid, Xs, Hs], Gates).

mcz([], T, _, [z(T)], []) :- !.
mcz(Cs, T, Pool, Gates, Extra) :-
    mcx(Cs, T, Pool, MG, Extra),
    append([[h(T)], MG, [h(T)]], Gates).

mcx([C], T, _, [cx(C, T)], []) :- !.
mcx([C1, C2], T, _, [ccx(C1, C2, T)], []) :- !.
mcx([C1, C2|Rest], T, Pool, Gates, Extra) :-
    length(Rest, NA),
    take_ancillas(NA, Pool, As, Extra),
    As = [A1|_],
    ladder(Rest, As, T, Steps, Final),
    Compute = [ccx(C1, C2, A1)|Steps],
    reverse(Compute, Uncompute),
    append([Compute, [Final], Uncompute], Gates).

ladder([C], [A], T, [], ccx(A, C, T)) :- !.
ladder([C|Cs], [A, A2|As], T, [ccx(A, C, A2)|Steps], Final) :-
    ladder(Cs, [A2|As], T, Steps, Final).

take_ancillas(N, Pool, As, Extra) :-
    length(Pool, P),
    (   P >= N
    ->  length(As, N),
        append(As, _, Pool),
        Extra = []
    ;   NE1 is N - P - 1,
        numlist(0, NE1, Ks),
        maplist(dif_name, Ks, Extra),
        append(Pool, Extra, As)
    ).

%% grover_circuit(+Oracle, +Options, -Circuit)
%%   Options: iterations(K). Default: the optimal K for the marked count
%%   M, computed classically here (quantum counting could replace this).
grover_circuit(Oracle, Options, circuit(Qubits, Cbits, Gates)) :-
    oracle_circuit(Oracle, circuit(OQs, _, _)),
    oracle_info(Oracle, info(Regs, _, Ancillas, _)),
    input_qubits(Regs, Inputs),
    phase_oracle(Oracle, PO),
    diffusion(Inputs, Ancillas, Diff, Extra),
    iterations(Oracle, Inputs, Options, K),
    append(PO, Diff, Step),
    length(Steps, K),
    maplist(=(Step), Steps),
    append(Steps, Body),
    maplist(gate_h, Inputs, Init),
    maplist(cbit_name, Inputs, Cbits),
    maplist(gate_measure, Inputs, Cbits, Ms),
    append([Init, Body, Ms], Gates),
    append(OQs, Extra, Qubits).

gate_h(Q, h(Q)).
gate_x(Q, x(Q)).
gate_measure(Q, C, measure(Q, C)).

dif_name(K, Q) :-
    format(atom(Q), "dif_~w", [K]).

cbit_name(Q, C) :-
    format(atom(C), "c_~w", [Q]).

input_qubits(Regs, Inputs) :-
    findall(Q, (member(reg(_, _, Qs), Regs), member(Q, Qs)), Inputs).

iterations(_, _, Options, K) :-
    memberchk(iterations(K0), Options), !,
    must_be(nonneg, K0),
    K = K0.
iterations(Oracle, Inputs, _, K) :-
    oracle_marked_count(Oracle, M),
    length(Inputs, N),
    Total is 1 << N,
    (   ( M =:= 0 ; M =:= Total )
    ->  K = 0
    ;   Theta is asin(sqrt(M / Total)),
        K is max(0, round(pi / (4 * Theta) - 0.5))
    ).

%% grover_run(+Oracle, +Options, -Distribution)
%%   Distribution: [P-Values, ...], most likely first; P < 1e-9 dropped.
%%   Codes outside a register's domain decode as '$invalid'(Code).
grover_run(Oracle, Options, Dist) :-
    grover_circuit(Oracle, Options, Circuit),
    Circuit = circuit(Qubits, _, _),
    simulate(Circuit, State),
    oracle_info(Oracle, info(Regs, _, _, _)),
    qubit_positions(Qubits, Pos),
    findall(Vals-P,
            ( member(I-A, State),
              P is A * A,
              maplist(decode_reg(Pos, I), Regs, Vals)
            ),
            Pairs0),
    msort(Pairs0, Pairs1),
    sum_pairs(Pairs1, Summed),
    findall(P-V, (member(V-P, Summed), P > 1.0e-9), L),
    sort(1, @>=, L, Dist).

decode_reg(Pos, I, reg(_, Vs, Qs), V) :-
    reg_code_of(Qs, Pos, I, 0, 0, Code),
    (   nth0(Code, Vs, V0) -> V = V0 ; V = '$invalid'(Code) ).

reg_code_of([], _, _, _, C, C).
reg_code_of([Q|Qs], Pos, I, K, C0, C) :-
    mask(Pos, Q, M),
    (   I /\ M =:= 0 -> C1 = C0 ; C1 is C0 \/ (1 << K) ),
    K1 is K + 1,
    reg_code_of(Qs, Pos, I, K1, C1, C).

sum_pairs([], []).
sum_pairs([K-P|T], [K-S|Out]) :-
    sum_same(T, K, P, S, Rest),
    sum_pairs(Rest, Out).

sum_same([K2-P2|T], K, P0, S, Rest) :-
    K2 == K, !,
    P1 is P0 + P2,
    sum_same(T, K, P1, S, Rest).
sum_same(Rest, _, S, S, Rest).

%% ------------------------------------------------------------------
%% Sparse statevector simulator (all pl2qc gates have real matrices)
%% State: sorted list of BasisIndex-Amplitude; qubit k of the circuit's
%% qubit list is bit k of BasisIndex.
%% ------------------------------------------------------------------

simulate(circuit(Qubits, _, Gates), State) :-
    qubit_positions(Qubits, Pos),
    foldl(sv_gate(Pos), Gates, [0-1.0], State).

qubit_positions(Qs, Pos) :-
    findall(Q-I, nth0(I, Qs, Q), Pairs),
    list_to_assoc(Pairs, Pos).

mask(Pos, Q, M) :-
    (   get_assoc(Q, Pos, I)
    ->  M is 1 << I
    ;   existence_error(qubit, Q)
    ).

sv_gate(_, measure(_, _), S, S) :- !.
sv_gate(_, barrier(_), S, S) :- !.
sv_gate(Pos, x(Q), S0, S) :- !,
    mask(Pos, Q, M),
    maplist(sv_x(M), S0, S1),
    keysort(S1, S).
sv_gate(Pos, cx(C, T), S0, S) :- !,
    mask(Pos, C, MC),
    mask(Pos, T, MT),
    maplist(sv_cx(MC, MT), S0, S1),
    keysort(S1, S).
sv_gate(Pos, ccx(A, B, T), S0, S) :- !,
    mask(Pos, A, MA),
    mask(Pos, B, MB),
    mask(Pos, T, MT),
    MAB is MA \/ MB,
    maplist(sv_cx(MAB, MT), S0, S1),
    keysort(S1, S).
sv_gate(Pos, z(Q), S0, S) :- !,
    mask(Pos, Q, M),
    maplist(sv_z(M), S0, S).
sv_gate(Pos, h(Q), S0, S) :- !,
    mask(Pos, Q, M),
    R is sqrt(0.5),
    foldl(sv_h(M, R), S0, [], L1),
    keysort(L1, L2),
    merge_amps(L2, S).
sv_gate(_, G, _, _) :-
    domain_error(pl2qc_gate, G).

% Helpers kept as plain predicates rather than yall lambdas: inside a
% lambda, yall reads \X as "X is local", which broke bitwise negation.
sv_x(M, I-A, J-A) :-
    J is I xor M.

% Flip the target bits T when all control bits C are set
% (one control for cx, two for ccx).
sv_cx(C, T, I-A, J-A) :-
    (   I /\ C =:= C -> J is I xor T ; J = I ).

sv_z(M, I-A, I-B) :-
    (   I /\ M =:= 0 -> B = A ; B is -A ).

sv_h(M, R, I-A, L0, [I0-A0, I1-A1|L0]) :-
    I0 is I - (I /\ M),
    I1 is I0 + M,
    A0 is R * A,
    (   I /\ M =:= 0 -> A1 is R * A ; A1 is -R * A ).

merge_amps([], []).
merge_amps([K-A|T], Out) :-
    merge_same(T, K, A, Sum, Rest),
    (   abs(Sum) < 1.0e-12 -> Out = Out1 ; Out = [K-Sum|Out1] ),
    merge_amps(Rest, Out1).

merge_same([K2-A2|T], K, A0, Sum, Rest) :-
    K2 == K, !,
    A1 is A0 + A2,
    merge_same(T, K, A1, Sum, Rest).
merge_same(Rest, _, Sum, Sum, Rest).

%% ------------------------------------------------------------------
%% OpenQASM 2.0 export
%% ------------------------------------------------------------------

circuit_to_qasm(circuit(Qubits, Cbits, Gates), QASM) :-
    length(Qubits, NQ),
    length(Cbits, NC),
    qubit_positions(Qubits, QP),
    qubit_positions(Cbits, CP),
    findall(L, (nth0(I, Qubits, Q), format(atom(L), "// q[~w] = ~w~n", [I, Q])), Map),
    maplist(qasm_line(QP, CP), Gates, Lines),
    (   NC > 0 -> format(atom(CReg), "creg c[~w];~n", [NC]) ; CReg = '' ),
    atomic_list_concat(Map, MapText),
    atomic_list_concat(Lines, Body),
    format(atom(QASM),
           "OPENQASM 2.0;~ninclude \"qelib1.inc\";~n~wqreg q[~w];~n~w~w",
           [MapText, NQ, CReg, Body]).

qasm_line(QP, _, x(Q), L) :- !, qidx(QP, Q, I), format(atom(L), "x q[~w];~n", [I]).
qasm_line(QP, _, h(Q), L) :- !, qidx(QP, Q, I), format(atom(L), "h q[~w];~n", [I]).
qasm_line(QP, _, z(Q), L) :- !, qidx(QP, Q, I), format(atom(L), "z q[~w];~n", [I]).
qasm_line(QP, _, cx(C, T), L) :- !,
    qidx(QP, C, I), qidx(QP, T, J),
    format(atom(L), "cx q[~w],q[~w];~n", [I, J]).
qasm_line(QP, _, ccx(A, B, T), L) :- !,
    qidx(QP, A, I), qidx(QP, B, J), qidx(QP, T, K),
    format(atom(L), "ccx q[~w],q[~w],q[~w];~n", [I, J, K]).
qasm_line(QP, CP, measure(Q, C), L) :- !,
    qidx(QP, Q, I), qidx(CP, C, J),
    format(atom(L), "measure q[~w] -> c[~w];~n", [I, J]).
qasm_line(_, _, G, _) :-
    domain_error(qasm_gate, G).

qidx(Pos, Q, I) :-
    (   get_assoc(Q, Pos, I) -> true ; existence_error(qubit, Q) ).
