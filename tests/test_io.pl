%% test_io.pl - run the 200 input/output cases in io_cases.pl.
%% Run from this directory:  swipl test_io.pl
%%
%% For each io/8 case it checks that:
%%   1. the oracle marks exactly ExpectedSolutions (oracle_solutions/2,
%%      which also throws if any ancilla is left dirty),
%%   2. it marks no other basis input, including codes outside a
%%      domain (oracle_marked_count/2 = number of expected solutions),
%%   3. for Kind = exact, plain Prolog finds the same solutions.

:- use_module('../prolog/pl2qc').
:- use_module('../prolog/pl2qc_sim').
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(gensym)).

:- ensure_loaded(io_cases).

:- initialization(main, main).

main :-
    findall(Id, io(Id, _, _, _, _, _, _, _), Ids),
    length(Ids, N),
    format("=== pl2qc io cases (~w) ===~n", [N]),
    foldl(run_case, Ids, [], FailedRev),
    reverse(FailedRev, Failed),
    length(Failed, NF),
    Passed is N - NF,
    format("~w/~w io cases passed~n", [Passed, N]),
    (   Failed == []
    ->  halt(0)
    ;   format("Failed: ~w~n", [Failed]),
        halt(1)
    ).

run_case(Id, F0, F) :-
    io(Id, Kind, Tag, Program, Query, Domains, Options, Expected),
    (   catch(check_case(Kind, Program, Query, Domains, Options, Expected, Why),
              E, (Why = error(E)))
    ->  true
    ;   Why = failed
    ),
    (   Why == ok
    ->  F = F0
    ;   format("  FAIL io(~w) ~w: ~q~n", [Id, Tag, Why]),
        F = [Id|F0]
    ).

check_case(Kind, Program, Query, Domains, Options, Expected, Why) :-
    pl2qc(Program, Query, Domains, Options, Oracle),
    oracle_solutions(Oracle, S0),
    msort(S0, Got),
    msort(Expected, Want),
    oracle_marked_count(Oracle, M),
    length(Want, NW),
    (   Got \== Want
    ->  Why = solutions(got(Got), expected(Want))
    ;   M =\= NW
    ->  Why = marked_count(got(M), expected(NW))
    ;   Kind == exact,
        classical_solutions(Program, Query, Domains, C0),
        msort(C0, Classical),
        Classical \== Want
    ->  Why = classical_mismatch(prolog(Classical), expected(Want))
    ;   Why = ok
    ).

%% Plain Prolog reference: assert the program in a fresh module and call
%% the query on every ground binding.
classical_solutions(Program, Query, Domains, Sols) :-
    gensym(pl2qc_io_, M),
    forall(member(C, Program), assertz(M:C)),
    findall(Vars,
            ( copy_term(Query-Domains, Q-D),
              pairs_keys_values(D, Vars, Doms),
              maplist(member, Vars, Doms),
              once(M:Q)
            ),
            Sols).
