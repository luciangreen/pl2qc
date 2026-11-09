%% demo.pl - run from this directory:  swipl demo.pl

:- use_module('../prolog/pl2qc').
:- use_module('../prolog/pl2qc_sim').

:- initialization(main, main).

main :-
    example_conjunction,
    example_path,
    halt.

example_conjunction :-
    format("~n=== g(X) :- a(X), b(X).  X in 0..3 ===~n"),
    Program = [a(1), a(2), b(2), b(3), (g(X) :- a(X), b(X))],
    pl2qc(Program, g(V), [V-[0,1,2,3]], [names([x])], Oracle),
    oracle_info(Oracle, info(_, _, _, Formula)),
    format("Formula: ~q~n", [Formula]),
    oracle_circuit(Oracle, circuit(Qubits, _, Gates)),
    format("Qubits:  ~w~nGates:~n", [Qubits]),
    forall(member(G, Gates), format("  ~w~n", [G])),
    oracle_stats(Oracle, Stats),
    format("Stats:   ~w~n", [Stats]),
    oracle_solutions(Oracle, Sols),
    format("Marked:  ~w~n", [Sols]),
    grover_run(Oracle, [], Dist),
    format("Grover:  ~w~n", [Dist]),
    grover_circuit(Oracle, [], GC),
    circuit_to_qasm(GC, QASM),
    format("~nOpenQASM:~n~w", [QASM]).

example_path :-
    format("~n=== path/2 from path.pl, depth 6 ===~n"),
    pl2qc_file('path.pl', path(A, B), [A-[a,b,c,d], B-[a,b,c,d]],
               [depth(6), names([from, to])], Oracle),
    oracle_stats(Oracle, Stats),
    format("Stats:   ~w~n", [Stats]),
    oracle_solutions(Oracle, Sols),
    format("Marked:  ~w~n", [Sols]),
    grover_run(Oracle, [], Dist),
    format("Grover (most likely first):~n"),
    forall(member(P-V, Dist), format("  ~4f  ~w~n", [P, V])).
