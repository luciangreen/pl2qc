# pl2qc

Prolog to quantum circuit compiler.

pl2qc compiles a finite-domain Prolog program and query into a reversible
quantum **oracle**:

```
U_f |x⟩|y⟩|0…0⟩ = |x⟩|y ⊕ f(x)⟩|0…0⟩
```

Here `f(x)` is true exactly when the query succeeds for the binding encoded
in the input registers `x`. The oracle can then drive **Grover search**,
which finds solutions in about √N oracle calls instead of the N tries that
backtracking may need.

pl2qc is the quantum counterpart to pl2ann (Prolog → neural network). Its
circuits use the same `circuit(Qubits, Cbits, Gates)` form and gate names as
[pl2q](https://github.com/luciangreen/pl2q), so they can be passed straight to
pl2q for decomposition, optimisation, simulation or export.

## How Prolog maps to the circuit

| Prolog | Circuit |
|---|---|
| Query variable over a domain of n values | Register of ⌈log₂ n⌉ qubits (bit 0 = LSB) |
| `X = c`, unification with a head constant | Equality test on the register's bits |
| `X = Y` (two query variables) | OR over shared values of (X = v ∧ Y = v) |
| Conjunction `A, B` | Toffoli chain into an ancilla |
| Several clauses for a head, `A ; B` | OR via De Morgan (negated Toffoli chain) |
| `\+ G`, `X \= Y` | Polarity flip (X gates around the gate that uses it) |
| Body-local variables | Resolved classically while unfolding |
| Recursion | Unrolled to `depth(D)` nested calls |
| Repeated subgoals | Shared: each distinct subformula is computed once |
| Ancillas | Uncomputed (reverse of compute), so they end in \|0⟩ |
| Search over bindings | `H` on inputs, then Grover iterations (phase oracle + diffusion) |

Supported goals: `true`, `fail`, `false`, `(A,B)`, `(A;B)`, `(C->T;E)`,
`(C->T)`, `\+ G`, `A = B`, `A \= B`, `member(X, List)`, `R is E`, the
comparisons `<`, `>`, `=<`, `>=`, `=:=`, `=\=`, `between(L, H, X)`, and calls
to program predicates.

### Arithmetic

For arithmetic goals, pl2qc enumerates the domain values of any query
registers the goal uses, evaluates the arithmetic classically for each
combination, and marks the combinations where the goal holds:

```prolog
?- pl2qc([(q(X,Y) :- S is X + Y, S =:= 3)], q(A,B),
         [A-[0,1,2,3], B-[0,1,2,3]], [], O),
   oracle_solutions(O, S).
S = [[0,3],[1,2],[2,1],[3,0]].
```

Local variables bound by earlier goals work as in Prolog, including
counters in recursion (`N is M + 1`). An expression with an unbound
variable raises `instantiation_error`, as in Prolog. The oracle is a lookup
over register values, not a reversible adder, so its size grows with the
product of the domains the goal uses.

## Usage

```prolog
:- use_module(prolog/pl2qc).
:- use_module(prolog/pl2qc_sim).

?- Program = [a(1), a(2), b(2), b(3), (g(X) :- a(X), b(X))],
   pl2qc(Program, g(V), [V-[0,1,2,3]], [], Oracle),
   oracle_solutions(Oracle, Sols),     % [[2]]
   grover_run(Oracle, [], Dist).       % [1.0-[2]]
```

`pl2qc(+Program, +Query, +Domains, +Options, -Oracle)`

- `Program`: list of clauses. Use `pl2qc_file/5` to read them from a file.
- `Domains`: one `Var-Values` pair per query variable.
- `Options`: `depth(D)` sets the recursion unrolling depth (default 8);
  `names(Names)` sets the register names (default `r1`, `r2`, …).
- `Oracle`: `oracle(circuit(Qubits, [], Gates), info(Registers, Out, Ancillas, Formula))`.

Recursive example (`examples/path.pl`):

```prolog
?- pl2qc_file('examples/path.pl', path(X, Y),
              [X-[a,b,c,d], Y-[a,b,c,d]], [depth(6)], O),
   oracle_solutions(O, S).
S = [[a,b],[a,c],[a,d],[b,c],[b,d],[c,d]].
```

### Other predicates

| Predicate | Purpose |
|---|---|
| `pl2qc_formula/5` | The Boolean formula the oracle computes |
| `oracle_stats/2` | Qubit, ancilla, gate and Toffoli counts |
| `oracle_eval/3` | Evaluate the oracle on one binding; throws if any ancilla is left dirty |
| `oracle_solutions/2` | All bindings the oracle marks |
| `oracle_marked_count/2` | Marked basis inputs, M |
| `phase_oracle/2` | Oracle with the output qubit in \|−⟩ (phase kickback) |
| `diffusion/4` | Grover diffusion operator (reuses the oracle's clean ancillas) |
| `grover_circuit/3` | Full Grover circuit with measurements; `iterations(K)` or the optimal K for M |
| `grover_run/3` | Simulate it: `P-Values` pairs, most likely first |
| `simulate/2` | Sparse statevector simulator for `x`, `cx`, `ccx`, `h`, `z` |
| `circuit_to_qasm/2` | OpenQASM 2.0 export |

## Run

```bash
cd examples && swipl demo.pl
cd tests && swipl test_pl2qc.pl
```

The tests check the oracle against plain Prolog on every binding, check
uncomputation, and check Grover probabilities.

`tests/io_cases.pl` holds 240 input/output cases:
`io(Id, Kind, Tag, Program, Query, Domains, Options, ExpectedSolutions)`.
They cover facts, conjunction, disjunction, negation, `=`/`\=`, `member/2`,
if-then-else, local variables, binary relations, chains, three query
variables, recursion on random graphs, depth-limited recursion and (cases
201–240) arithmetic, including a path-length counter. Expected
solutions come from an independent reference evaluator. Run them with:

```bash
cd tests && swipl test_io.pl
```

For each case, the runner checks the marked solutions and the marked count
(so unused codes stay unmarked). For `exact` cases it also checks the result
against plain Prolog.

## Limits

- Domains must be finite and ground. Only the query variables are quantum.
- Recursion deeper than `depth(D)` counts as failure, so `\+` of a goal cut
  off by the depth limit succeeds.
- `(C->T;E)` is compiled as `(C,T ; \+C, E)`. This matches Prolog unless `C`
  has several solutions that disagree on `T`.
- Not supported: `!`, `assert`/`retract` and I/O.
- Recursion is unrolled linearly. Log-depth restructuring (such as repeated
  squaring for transitive closure) and quantum counting are not implemented.
  The Grover iteration count is computed from a classical count of M.
- Unfolding is exponential in the worst case, so pl2qc is for small programs.

## Licence

BSD 3-Clause. See `LICENSE`.
