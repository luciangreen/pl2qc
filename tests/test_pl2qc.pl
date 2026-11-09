%% test_pl2qc.pl
%% Run from this directory:  swipl test_pl2qc.pl
%%
%% Most tests compile a program, evaluate the oracle classically on every
%% binding (which also checks that every ancilla is uncomputed), and
%% compare the marked bindings with what plain Prolog finds.

:- use_module('../prolog/pl2qc').
:- use_module('../prolog/pl2qc_sim').
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(gensym)).

:- dynamic test_dir/1.
:- prolog_load_context(directory, Dir), asserta(test_dir(Dir)).

:- initialization(main, main).

tests([ xor, conjunction, clauses, negation, if_then_else, local_variable,
        exported_binding, member, register_equality, non_power_of_two,
        recursion_full, recursion_depth_limit, file_loading, sharing,
        grover_one_of_four, grover_one_of_eight, grover_path,
        grover_restores_ancillas, qasm_export ]).

main :-
    tests(Ts),
    format("=== pl2qc tests ===~n"),
    foldl(run_test, Ts, 0, Failed),
    length(Ts, N),
    Passed is N - Failed,
    format("~w/~w tests passed~n", [Passed, N]),
    (   Failed =:= 0 -> halt(0) ; halt(1) ).

run_test(T, F0, F) :-
    (   catch(test(T), E, (print_message(error, E), fail))
    ->  format("  PASS ~w~n", [T]),
        F = F0
    ;   format("  FAIL ~w~n", [T]),
        F is F0 + 1
    ).

%% ------------------------------------------------------------------
%% Helpers
%% ------------------------------------------------------------------

%% agrees(+Program, +Query, +Domains, +Options)
agrees(Program, Query, Domains, Options) :-
    pl2qc(Program, Query, Domains, Options, Oracle),
    oracle_solutions(Oracle, QS0),
    classical_solutions(Program, Query, Domains, CS0),
    msort(QS0, QS),
    msort(CS0, CS),
    (   QS == CS
    ->  true
    ;   format("    quantum:   ~w~n    classical: ~w~n", [QS, CS]),
        fail
    ).

%% Plain Prolog reference: assert the program in a fresh module and
%% call the query on every ground binding.
classical_solutions(Program, Query, Domains, Sols) :-
    gensym(pl2qc_ref_, M),
    forall(member(C, Program), assertz(M:C)),
    findall(Vars,
            ( copy_term(Query-Domains, Q-D),
              pairs_keys_values(D, Vars, Doms),
              maplist(member, Vars, Doms),
              once(M:Q)
            ),
            Sols).

expect_solutions(Program, Query, Domains, Options, Expected) :-
    pl2qc(Program, Query, Domains, Options, Oracle),
    oracle_solutions(Oracle, S0),
    msort(S0, S),
    msort(Expected, E),
    (   S == E
    ->  true
    ;   format("    got ~w, expected ~w~n", [S, E]),
        fail
    ).

graph([ edge(a, b), edge(b, c), edge(c, d),
        (path(X, Y) :- edge(X, Y)),
        (path(X, Y) :- edge(X, Z), path(Z, Y)) ]).

%% ------------------------------------------------------------------
%% Tests
%% ------------------------------------------------------------------

test(xor) :-
    P = [(ok(X, Y) :- X \= Y)],
    agrees(P, ok(A, B), [A-[0,1], B-[0,1]], []),
    expect_solutions(P, ok(A, B), [A-[0,1], B-[0,1]], [], [[0,1],[1,0]]).

test(conjunction) :-
    P = [a(1), a(2), b(2), b(3), (g(X) :- a(X), b(X))],
    agrees(P, g(V), [V-[0,1,2,3]], []),
    expect_solutions(P, g(V), [V-[0,1,2,3]], [], [[2]]).

test(clauses) :-
    P = [(h(X) :- X = 0), (h(X) :- X = 3)],
    agrees(P, h(V), [V-[0,1,2,3]], []).

test(negation) :-
    P = [a(1), a(2), (n(X) :- \+ a(X))],
    agrees(P, n(V), [V-[0,1,2,3]], []),
    expect_solutions(P, n(V), [V-[0,1,2,3]], [], [[0],[3]]).

test(if_then_else) :-
    P = [(s(X, Y) :- ( X = a -> Y = 1 ; Y = 0 ))],
    agrees(P, s(A, B), [A-[a,b], B-[0,1]], []).

test(local_variable) :-
    P = [q(1, a), q(2, b), q(3, a), r(a), (p(X) :- q(X, Y), r(Y))],
    agrees(P, p(V), [V-[0,1,2,3]], []).

test(exported_binding) :-
    % t/1 binds its argument; the binding must reach X = Y.
    P = [(t(Z) :- Z = c), (u(X) :- t(Y), X = Y)],
    agrees(P, u(V), [V-[a,b,c]], []).

test(member) :-
    P = [(m(X) :- member(X, [b, c]))],
    agrees(P, m(V), [V-[a,b,c,d]], []).

test(register_equality) :-
    P = [(e(X, Y) :- X = Y)],
    agrees(P, e(A, B), [A-[a,b,c], B-[b,c,d]], []).

test(non_power_of_two) :-
    % 3 values need 2 qubits; the unused code 3 must not be marked.
    P = [(q(X) :- X \= a)],
    pl2qc(P, q(V), [V-[a,b,c]], [], O),
    oracle_solutions(O, S),
    msort(S, [[b],[c]]),
    oracle_marked_count(O, 2).

test(recursion_full) :-
    graph(P),
    agrees(P, path(A, B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(6)]).

test(recursion_depth_limit) :-
    % depth(2): path -> edge only, so just the direct edges.
    graph(P),
    expect_solutions(P, path(A, B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(2)],
                     [[a,b],[b,c],[c,d]]).

test(file_loading) :-
    test_dir(Dir),
    atomic_list_concat([Dir, '/../examples/path.pl'], File),
    pl2qc_file(File, path(A, B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(6)], O),
    oracle_solutions(O, S),
    length(S, 6).

test(sharing) :-
    % A repeated subgoal is merged, so both programs give the same circuit.
    P1 = [a(1), (g(X) :- a(X))],
    P2 = [a(1), (g(X) :- a(X), a(X))],
    pl2qc(P1, g(V), [V-[0,1,2,3]], [], O1),
    pl2qc(P2, g(W), [W-[0,1,2,3]], [], O2),
    oracle_circuit(O1, circuit(_, _, G1)),
    oracle_circuit(O2, circuit(_, _, G2)),
    length(G1, N1),
    length(G2, N2),
    N1 =:= N2.

test(grover_one_of_four) :-
    P = [(w(X, Y) :- X = 1, Y = 1)],
    pl2qc(P, w(A, B), [A-[0,1], B-[0,1]], [], O),
    grover_run(O, [], [Prob-[1,1]|_]),
    Prob > 0.99.

test(grover_one_of_eight) :-
    P = [(f(X) :- X = 5)],
    pl2qc(P, f(V), [V-[0,1,2,3,4,5,6,7]], [], O),
    grover_run(O, [], [Prob-[5]|_]),
    Prob > 0.9.

test(grover_path) :-
    % 6 of 16 bindings are solutions: one Grover step lifts their total
    % probability from 0.375 to about 0.84.
    graph(P),
    pl2qc(P, path(A, B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(6)], O),
    oracle_solutions(O, Sols),
    grover_run(O, [], Dist),
    findall(Pr, (member(Pr-V, Dist), memberchk(V, Sols)), Ps),
    sum_list(Ps, Total),
    Total > 0.8.

test(grover_restores_ancillas) :-
    % After the full Grover circuit, the output qubit and all ancillas
    % (which come after the inputs) are |0> in every basis state.
    P = [a(1), a(2), b(2), b(3), (g(X) :- a(X), b(X))],
    pl2qc(P, g(V), [V-[0,1,2,3]], [], O),
    grover_circuit(O, [], C),
    simulate(C, State),
    oracle_info(O, info(Regs, _, _, _)),
    findall(Q, (member(reg(_, _, Qs), Regs), member(Q, Qs)), Inputs),
    length(Inputs, N),
    forall(member(I-_, State), I >> N =:= 0).

test(qasm_export) :-
    P = [a(1), a(2), b(2), b(3), (g(X) :- a(X), b(X))],
    pl2qc(P, g(V), [V-[0,1,2,3]], [], O),
    oracle_circuit(O, C),
    circuit_to_qasm(C, QASM),
    sub_atom(QASM, 0, _, _, 'OPENQASM 2.0;'),
    sub_atom(QASM, _, _, _, 'ccx q[').
