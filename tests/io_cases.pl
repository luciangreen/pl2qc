%% io_cases.pl - 240 input/output cases for pl2qc (201-240 use arithmetic).
%% io(Id, Kind, Tag, Program, Query, Domains, Options, ExpectedSolutions)
%%   Kind = exact: ExpectedSolutions are also what plain Prolog finds.
%%   Kind = depth_limited: expected under pl2qc's depth(D) unrolling, where
%%   derivations deeper than D nested calls count as failure.
%% Expected solutions list one value per query variable, in Domains order,
%% computed by an independent reference evaluator.

io(1, exact, facts, [p(0), p(1), (q(X) :- p(X))], q(A), [A-[0,1]], [], [[0],[1]]).
io(2, exact, facts, [p(a), p(b), (q(X) :- p(X))], q(A), [A-[a,b,c,d]], [], [[a],[b]]).
io(3, exact, facts, [p(0), (q(X) :- p(X))], q(A), [A-[0]], [], [[0]]).
io(4, exact, facts, [p(1), p(2), (q(X) :- p(X))], q(A), [A-[0,1,2]], [], [[1],[2]]).
io(5, exact, facts, [p(a), p(b), (q(X) :- p(X))], q(A), [A-[a,b]], [], [[a],[b]]).
io(6, exact, facts, [p(b), (q(X) :- p(X))], q(A), [A-[a,b,c,d,e]], [], [[b]]).
io(7, exact, facts, [p(b), (q(X) :- p(X))], q(A), [A-[a,b]], [], [[b]]).
io(8, exact, facts, [p(a), p(b), (q(X) :- p(X))], q(A), [A-[a,b]], [], [[a],[b]]).
io(9, exact, facts, [p(a), (q(X) :- p(X))], q(A), [A-[a,b]], [], [[a]]).
io(10, exact, facts, [p(0), (q(X) :- p(X))], q(A), [A-[0,1,2]], [], [[0]]).
io(11, exact, facts, [p(3), (q(X) :- p(X))], q(A), [A-[0,1,2,3,4]], [], [[3]]).
io(12, exact, facts, [p(0), p(2), (q(X) :- p(X))], q(A), [A-[0,1,2]], [], [[0],[2]]).
io(13, exact, facts, [p(a), p(b), p(c), p(d), p(e), p(f), (q(X) :- p(X))], q(A), [A-[a,b,c,d,e,f]], [], [[a],[b],[c],[d],[e],[f]]).
io(14, exact, facts, [p(0), (q(X) :- p(X))], q(A), [A-[0,1]], [], [[0]]).
io(15, exact, facts, [p(0), (q(X) :- p(X))], q(A), [A-[0]], [], [[0]]).
io(16, exact, conjunction, [p(0), r(1), s(0), s(1), (q(X) :- (p(X), (r(X), s(X))))], q(A), [A-[0,1]], [], []).
io(17, exact, conjunction, [p(b), p(c), p(d), p(e), p(f), r(a), r(b), r(c), r(d), (q(X) :- (p(X), r(X)))], q(A), [A-[a,b,c,d,e,f]], [], [[b],[c],[d]]).
io(18, exact, conjunction, [p(b), p(c), p(e), r(a), r(d), r(e), s(c), s(d), (q(X) :- (p(X), (r(X), s(X))))], q(A), [A-[a,b,c,d,e]], [], []).
io(19, exact, conjunction, [p(3), r(0), r(1), r(2), r(3), s(0), s(2), (q(X) :- (p(X), (r(X), s(X))))], q(A), [A-[0,1,2,3]], [], []).
io(20, exact, conjunction, [p(b), p(c), r(b), r(c), (q(X) :- (p(X), r(X)))], q(A), [A-[a,b,c]], [], [[b],[c]]).
io(21, exact, conjunction, [p(0), r(0), r(1), (q(X) :- (p(X), r(X)))], q(A), [A-[0,1]], [], [[0]]).
io(22, exact, conjunction, [p(a), r(a), s(a), (q(X) :- (p(X), (r(X), s(X))))], q(A), [A-[a]], [], [[a]]).
io(23, exact, conjunction, [p(1), r(0), r(1), (q(X) :- (p(X), r(X)))], q(A), [A-[0,1]], [], [[1]]).
io(24, exact, conjunction, [p(2), r(3), s(0), s(1), s(3), (q(X) :- (p(X), (r(X), s(X))))], q(A), [A-[0,1,2,3,4]], [], []).
io(25, exact, conjunction, [p(c), r(b), (q(X) :- (p(X), r(X)))], q(A), [A-[a,b,c]], [], []).
io(26, exact, conjunction, [p(a), p(b), p(c), p(d), p(e), r(a), r(b), r(c), r(d), r(f), (q(X) :- (p(X), r(X)))], q(A), [A-[a,b,c,d,e,f]], [], [[a],[b],[c],[d]]).
io(27, exact, conjunction, [p(0), p(1), r(1), (q(X) :- (p(X), r(X)))], q(A), [A-[0,1]], [], [[1]]).
io(28, exact, conjunction, [p(0), p(1), r(0), r(1), (q(X) :- (p(X), r(X)))], q(A), [A-[0,1]], [], [[0],[1]]).
io(29, exact, conjunction, [p(c), r(b), (q(X) :- (p(X), r(X)))], q(A), [A-[a,b,c,d]], [], []).
io(30, exact, disjunction, [(q(X) :- (X = c))], q(A), [A-[a,b,c]], [], [[c]]).
io(31, exact, disjunction, [p(0), r(0), (q(X) :- (p(X) ; r(X)))], q(A), [A-[0]], [], [[0]]).
io(32, exact, disjunction, [(q(X) :- (X = 1)), (q(X) :- (X = 3))], q(A), [A-[0,1,2,3]], [], [[1],[3]]).
io(33, exact, disjunction, [p(1), p(2), p(3), p(4), r(0), (q(X) :- (p(X) ; r(X)))], q(A), [A-[0,1,2,3,4]], [], [[0],[1],[2],[3],[4]]).
io(34, exact, disjunction, [(q(X) :- (X = 0)), (q(X) :- (X = 1))], q(A), [A-[0,1]], [], [[0],[1]]).
io(35, exact, disjunction, [p(1), p(2), p(3), p(5), r(0), r(1), r(2), r(3), r(4), r(5), (q(X) :- (p(X) ; r(X)))], q(A), [A-[0,1,2,3,4,5]], [], [[0],[1],[2],[3],[4],[5]]).
io(36, exact, disjunction, [(q(X) :- (X = 0)), (q(X) :- (X = 2))], q(A), [A-[0,1,2]], [], [[0],[2]]).
io(37, exact, disjunction, [p(0), r(1), (q(X) :- (p(X) ; r(X)))], q(A), [A-[0,1]], [], [[0],[1]]).
io(38, exact, disjunction, [(q(X) :- (X = 0))], q(A), [A-[0]], [], [[0]]).
io(39, exact, disjunction, [p(a), p(b), r(a), r(b), (q(X) :- (p(X) ; r(X)))], q(A), [A-[a,b]], [], [[a],[b]]).
io(40, exact, disjunction, [(q(X) :- (X = 1))], q(A), [A-[0,1,2]], [], [[1]]).
io(41, exact, disjunction, [p(0), r(0), (q(X) :- (p(X) ; r(X)))], q(A), [A-[0]], [], [[0]]).
io(42, exact, disjunction, [(q(X) :- (X = 0)), (q(X) :- (X = 1)), (q(X) :- (X = 2))], q(A), [A-[0,1,2]], [], [[0],[1],[2]]).
io(43, exact, disjunction, [p(a), p(b), p(c), p(e), r(a), r(b), r(c), r(d), r(e), (q(X) :- (p(X) ; r(X)))], q(A), [A-[a,b,c,d,e]], [], [[a],[b],[c],[d],[e]]).
io(44, exact, disjunction, [(q(X) :- (X = 0)), (q(X) :- (X = 1))], q(A), [A-[0,1]], [], [[0],[1]]).
io(45, exact, disjunction, [p(a), p(b), p(c), r(a), r(b), r(c), (q(X) :- (p(X) ; r(X)))], q(A), [A-[a,b,c]], [], [[a],[b],[c]]).
io(46, exact, disjunction, [(q(X) :- (X = b)), (q(X) :- (X = c)), (q(X) :- (X = d)), (q(X) :- (X = e)), (q(X) :- (X = f))], q(A), [A-[a,b,c,d,e,f]], [], [[b],[c],[d],[e],[f]]).
io(47, exact, disjunction, [p(a), p(c), p(e), p(f), r(b), r(d), r(f), (q(X) :- (p(X) ; r(X)))], q(A), [A-[a,b,c,d,e,f]], [], [[a],[b],[c],[d],[e],[f]]).
io(48, exact, disjunction, [(q(X) :- (X = c)), (q(X) :- (X = d))], q(A), [A-[a,b,c,d]], [], [[c],[d]]).
io(49, exact, disjunction, [p(a), r(a), (q(X) :- (p(X) ; r(X)))], q(A), [A-[a]], [], [[a]]).
io(50, exact, negation, [p(2), r(1), r(2), (q(X) :- (\+ p(X)))], q(A), [A-[0,1,2]], [], [[0],[1]]).
io(51, exact, negation, [p(0), p(1), r(0), r(1), (q(X) :- (r(X), (\+ p(X))))], q(A), [A-[0,1]], [], []).
io(52, exact, negation, [p(2), r(0), r(1), (q(X) :- (\+ p(X)))], q(A), [A-[0,1,2]], [], [[0],[1]]).
io(53, exact, negation, [p(0), r(0), r(1), (q(X) :- (r(X), (\+ p(X))))], q(A), [A-[0,1]], [], [[1]]).
io(54, exact, negation, [p(0), p(3), p(5), r(5), (q(X) :- (\+ p(X)))], q(A), [A-[0,1,2,3,4,5]], [], [[1],[2],[4]]).
io(55, exact, negation, [p(a), p(b), p(c), p(d), r(a), r(d), (q(X) :- (r(X), (\+ p(X))))], q(A), [A-[a,b,c,d]], [], []).
io(56, exact, negation, [p(b), p(c), r(c), r(d), (q(X) :- (\+ p(X)))], q(A), [A-[a,b,c,d]], [], [[a],[d]]).
io(57, exact, negation, [p(2), p(5), r(3), (q(X) :- (r(X), (\+ p(X))))], q(A), [A-[0,1,2,3,4,5]], [], [[3]]).
io(58, exact, negation, [p(1), p(4), r(0), r(2), r(3), r(4), (q(X) :- (\+ p(X)))], q(A), [A-[0,1,2,3,4]], [], [[0],[2],[3]]).
io(59, exact, negation, [p(a), r(a), (q(X) :- (r(X), (\+ p(X))))], q(A), [A-[a]], [], []).
io(60, exact, negation, [p(a), p(b), r(b), (q(X) :- (\+ p(X)))], q(A), [A-[a,b]], [], []).
io(61, exact, negation, [p(a), p(b), p(c), r(b), r(c), r(d), r(f), (q(X) :- (r(X), (\+ p(X))))], q(A), [A-[a,b,c,d,e,f]], [], [[d],[f]]).
io(62, exact, negation, [p(0), p(1), p(2), p(3), p(5), r(0), r(1), r(2), r(3), r(4), r(5), (q(X) :- (\+ p(X)))], q(A), [A-[0,1,2,3,4,5]], [], [[4]]).
io(63, exact, negation, [p(2), p(3), p(4), r(3), (q(X) :- (r(X), (\+ p(X))))], q(A), [A-[0,1,2,3,4]], [], []).
io(64, exact, negation, [p(0), p(1), p(2), r(0), r(2), (q(X) :- (\+ p(X)))], q(A), [A-[0,1,2]], [], []).
io(65, exact, equality, [(q(X,Y) :- (X = Y))], q(A,B), [A-[0,1,2,3,4,5], B-[0,1,2,3,4,5]], [], [[0,0],[1,1],[2,2],[3,3],[4,4],[5,5]]).
io(66, exact, equality, [(q(X,Y) :- (X \= Y))], q(A,B), [A-[0,1,2], B-[0,1,2,3,4]], [], [[0,1],[0,2],[0,3],[0,4],[1,0],[1,2],[1,3],[1,4],[2,0],[2,1],[2,3],[2,4]]).
io(67, exact, equality, [(q(X,Y) :- (X = Y))], q(A,B), [A-[0,1,2,3,4], B-[0,1,2,3,4]], [], [[0,0],[1,1],[2,2],[3,3],[4,4]]).
io(68, exact, equality, [(q(X,Y) :- (X \= Y))], q(A,B), [A-[a], B-[a,b,c,d]], [], [[a,b],[a,c],[a,d]]).
io(69, exact, equality, [(q(X,Y) :- (X = Y))], q(A,B), [A-[a], B-[a,b,c,d]], [], [[a,a]]).
io(70, exact, equality, [(q(X,Y) :- (X \= Y))], q(A,B), [A-[0], B-[0,1,2,3,4,5]], [], [[0,1],[0,2],[0,3],[0,4],[0,5]]).
io(71, exact, equality, [(q(X,Y) :- (X = Y))], q(A,B), [A-[0], B-[0,1,2,3]], [], [[0,0]]).
io(72, exact, equality, [(q(X,Y) :- (X \= Y))], q(A,B), [A-[a,b,c,d], B-[a,b,c]], [], [[a,b],[a,c],[b,a],[b,c],[c,a],[c,b],[d,a],[d,b],[d,c]]).
io(73, exact, equality, [(q(X,Y) :- (X = Y))], q(A,B), [A-[a], B-[a,b,c]], [], [[a,a]]).
io(74, exact, equality, [(q(X,Y) :- (X \= Y))], q(A,B), [A-[a,b,c,d,e,f], B-[a,b,c,d]], [], [[a,b],[a,c],[a,d],[b,a],[b,c],[b,d],[c,a],[c,b],[c,d],[d,a],[d,b],[d,c],[e,a],[e,b],[e,c],[e,d],[f,a],[f,b],[f,c],[f,d]]).
io(75, exact, equality, [(q(X,Y) :- (X = Y))], q(A,B), [A-[a,b,c], B-[a,b,c,d]], [], [[a,a],[b,b],[c,c]]).
io(76, exact, equality, [(q(X,Y) :- (X \= Y))], q(A,B), [A-[0,1,2], B-[0]], [], [[1,0],[2,0]]).
io(77, exact, equality, [(q(X,Y) :- (X = Y))], q(A,B), [A-[a], B-[a,b,c,d,e]], [], [[a,a]]).
io(78, exact, equality, [(q(X,Y) :- (X \= Y))], q(A,B), [A-[0,1,2,3,4], B-[0,1,2,3,4]], [], [[0,1],[0,2],[0,3],[0,4],[1,0],[1,2],[1,3],[1,4],[2,0],[2,1],[2,3],[2,4],[3,0],[3,1],[3,2],[3,4],[4,0],[4,1],[4,2],[4,3]]).
io(79, exact, equality, [(q(X,Y) :- (X = Y))], q(A,B), [A-[a,b], B-[a,b,c]], [], [[a,a],[b,b]]).
io(80, exact, member, [(q(X) :- member(X,[0,z]))], q(A), [A-[0,1,2]], [], [[0]]).
io(81, exact, member, [(q(X) :- member(X,[b,c,y]))], q(A), [A-[a,b,c]], [], [[b],[c]]).
io(82, exact, member, [(q(X) :- member(X,[a,z]))], q(A), [A-[a]], [], [[a]]).
io(83, exact, member, [(q(X) :- member(X,[0,1,y]))], q(A), [A-[0,1,2]], [], [[0],[1]]).
io(84, exact, member, [(q(X) :- member(X,[b,c,z]))], q(A), [A-[a,b,c]], [], [[b],[c]]).
io(85, exact, member, [(q(X) :- member(X,[0]))], q(A), [A-[0,1,2,3,4]], [], [[0]]).
io(86, exact, member, [(q(X) :- member(X,[a]))], q(A), [A-[a]], [], [[a]]).
io(87, exact, member, [(q(X) :- member(X,[1,y]))], q(A), [A-[0,1,2,3]], [], [[1]]).
io(88, exact, member, [(q(X) :- member(X,[a,b,c]))], q(A), [A-[a,b,c]], [], [[a],[b],[c]]).
io(89, exact, member, [(q(X) :- member(X,[0,1,3,4,5,z]))], q(A), [A-[0,1,2,3,4,5]], [], [[0],[1],[3],[4],[5]]).
io(90, exact, if_then_else, [(q(X,Y) :- (((X = a) -> (Y = 0)) ; (Y = 1)))], q(A,B), [A-[a,b], B-[0,1]], [], [[a,0],[b,1]]).
io(91, exact, if_then_else, [(q(X,Y) :- (((X = a) -> (Y = 1)) ; (Y = 0)))], q(A,B), [A-[a], B-[0,1]], [], [[a,1]]).
io(92, exact, if_then_else, [(q(X,Y) :- (((X = a) -> (Y = 2)) ; (Y = 1)))], q(A,B), [A-[a,b,c,d,e], B-[0,1,2]], [], [[a,2],[b,1],[c,1],[d,1],[e,1]]).
io(93, exact, if_then_else, [(q(X,Y) :- (((X = b) -> (Y = 0)) ; (Y = 0)))], q(A,B), [A-[a,b], B-[0,1]], [], [[a,0],[b,0]]).
io(94, exact, if_then_else, [(q(X,Y) :- (((X = a) -> (Y = 0)) ; (Y = 0)))], q(A,B), [A-[a,b], B-[0,1,2]], [], [[a,0],[b,0]]).
io(95, exact, if_then_else, [(q(X,Y) :- (((X = b) -> (Y = 1)) ; (Y = 1)))], q(A,B), [A-[a,b,c], B-[0,1,2]], [], [[a,1],[b,1],[c,1]]).
io(96, exact, if_then_else, [(q(X,Y) :- (((X = a) -> (Y = 0)) ; (Y = 1)))], q(A,B), [A-[a], B-[0,1,2]], [], [[a,0]]).
io(97, exact, if_then_else, [(q(X,Y) :- (((X = c) -> (Y = 1)) ; (Y = 1)))], q(A,B), [A-[a,b,c], B-[0,1,2]], [], [[a,1],[b,1],[c,1]]).
io(98, exact, if_then_else, [(q(X,Y) :- (((X = a) -> (Y = 1)) ; (Y = 1)))], q(A,B), [A-[a,b], B-[0,1]], [], [[a,1],[b,1]]).
io(99, exact, if_then_else, [(q(X,Y) :- (((X = d) -> (Y = 0)) ; (Y = 0)))], q(A,B), [A-[a,b,c,d], B-[0,1,2]], [], [[a,0],[b,0],[c,0],[d,0]]).
io(100, exact, local_variable, [e(3,a), e(3,b), e(4,a), r(a), r(b), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1,2,3,4]], [], [[3],[4]]).
io(101, exact, local_variable, [e(0,a), e(2,a), e(4,a), r(a), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1,2,3,4,5]], [], [[0],[2],[4]]).
io(102, exact, local_variable, [e(a,a), r(a), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[a,b,c]], [], [[a]]).
io(103, exact, local_variable, [e(0,c), e(1,a), e(1,b), e(1,c), e(2,c), e(4,a), e(4,b), r(b), r(c), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1,2,3,4]], [], [[0],[1],[2],[4]]).
io(104, exact, local_variable, [e(0,a), e(2,a), r(a), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1,2]], [], [[0],[2]]).
io(105, exact, local_variable, [e(2,b), r(b), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1,2,3]], [], [[2]]).
io(106, exact, local_variable, [e(0,a), r(a), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1,2,3,4]], [], [[0]]).
io(107, exact, local_variable, [e(a,b), e(b,a), e(b,b), e(d,b), r(a), r(b), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[a,b,c,d]], [], [[a],[b],[d]]).
io(108, exact, local_variable, [e(0,a), e(1,a), r(b), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1]], [], []).
io(109, exact, local_variable, [e(a,a), e(b,a), e(c,a), e(d,a), r(a), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[a,b,c,d,e]], [], [[a],[b],[c],[d]]).
io(110, exact, local_variable, [e(a,b), e(b,a), e(b,b), r(a), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[a,b]], [], [[b]]).
io(111, exact, local_variable, [e(a,b), e(a,c), e(b,c), e(c,b), e(e,a), e(e,b), e(e,d), r(a), r(b), r(c), r(d), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[a,b,c,d,e]], [], [[a],[b],[c],[e]]).
io(112, exact, local_variable, [e(1,b), r(a), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1,2]], [], []).
io(113, exact, local_variable, [e(a,a), e(a,d), e(b,c), e(c,d), e(d,b), e(e,a), e(e,b), r(a), r(b), r(c), r(d), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[a,b,c,d,e]], [], [[a],[b],[c],[d],[e]]).
io(114, exact, local_variable, [e(3,a), r(a), (q(X) :- (e(X,Y), r(Y)))], q(A), [A-[0,1,2,3]], [], [[3]]).
io(115, exact, relation, [e(1,1), (q(X,Y) :- e(X,Y))], q(A,B), [A-[0,1], B-[0,1]], [], [[1,1]]).
io(116, exact, relation, [e(0,1), (q(X,Y) :- (\+ e(X,Y)))], q(A,B), [A-[0], B-[0,1,2]], [], [[0,0],[0,2]]).
io(117, exact, relation, [e(a,1), e(b,0), e(b,1), e(c,1), e(d,0), e(d,1), (q(X,Y) :- (e(X,Y), (X \= Y)))], q(A,B), [A-[a,b,c,d], B-[0,1,2]], [], [[a,1],[b,0],[b,1],[c,1],[d,0],[d,1]]).
io(118, exact, relation, [e(0,a), e(0,b), e(1,c), (q(X,Y) :- (e(X,Y) ; e(Y,X)))], q(A,B), [A-[0,1], B-[a,b,c]], [], [[0,a],[0,b],[1,c]]).
io(119, exact, relation, [e(3,a), (q(X,Y) :- e(X,Y))], q(A,B), [A-[0,1,2,3], B-[a]], [], [[3,a]]).
io(120, exact, relation, [e(a,0), e(a,3), (q(X,Y) :- (\+ e(X,Y)))], q(A,B), [A-[a], B-[0,1,2,3]], [], [[a,1],[a,2]]).
io(121, exact, relation, [e(a,a), (q(X,Y) :- (e(X,Y), (X \= Y)))], q(A,B), [A-[a,b], B-[a,b]], [], []).
io(122, exact, relation, [e(a,0), e(d,1), (q(X,Y) :- (e(X,Y) ; e(Y,X)))], q(A,B), [A-[a,b,c,d], B-[0,1]], [], [[a,0],[d,1]]).
io(123, exact, relation, [e(0,0), (q(X,Y) :- e(X,Y))], q(A,B), [A-[0], B-[0,1]], [], [[0,0]]).
io(124, exact, relation, [e(0,2), e(0,3), e(1,3), (q(X,Y) :- (\+ e(X,Y)))], q(A,B), [A-[0,1], B-[0,1,2,3]], [], [[0,0],[0,1],[1,0],[1,1],[1,2]]).
io(125, exact, relation, [e(1,1), (q(X,Y) :- (e(X,Y), (X \= Y)))], q(A,B), [A-[0,1], B-[0,1]], [], []).
io(126, exact, relation, [e(a,0), (q(X,Y) :- (e(X,Y) ; e(Y,X)))], q(A,B), [A-[a], B-[0,1]], [], [[a,0]]).
io(127, exact, relation, [e(a,a), (q(X,Y) :- e(X,Y))], q(A,B), [A-[a,b,c], B-[a,b]], [], [[a,a]]).
io(128, exact, relation, [e(a,1), e(a,2), e(a,3), e(b,2), (q(X,Y) :- (\+ e(X,Y)))], q(A,B), [A-[a,b,c], B-[0,1,2,3]], [], [[a,0],[b,0],[b,1],[b,3],[c,0],[c,1],[c,2],[c,3]]).
io(129, exact, relation, [e(0,0), e(0,3), e(1,1), e(1,2), (q(X,Y) :- (e(X,Y), (X \= Y)))], q(A,B), [A-[0,1], B-[0,1,2,3]], [], [[0,3],[1,2]]).
io(130, exact, relation, [e(1,b), (q(X,Y) :- (e(X,Y) ; e(Y,X)))], q(A,B), [A-[0,1], B-[a,b,c]], [], [[1,b]]).
io(131, exact, recursion, [edge(a,d), edge(c,d), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(7)], [[a,d],[c,d]]).
io(132, exact, recursion, [edge(a,b), edge(a,c), edge(b,e), edge(c,e), edge(d,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(7)], [[a,b],[a,c],[a,e],[b,e],[c,e],[d,e]]).
io(133, exact, recursion, [edge(b,d), edge(c,d), edge(d,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(7)], [[b,d],[b,e],[c,d],[c,e],[d,e]]).
io(134, exact, recursion, [edge(a,d), edge(a,e), edge(c,e), edge(d,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(7)], [[a,d],[a,e],[c,e],[d,e]]).
io(135, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b], B-[a,b]], [depth(4)], [[a,b]]).
io(136, exact, recursion, [edge(a,b), edge(a,d), edge(b,c), edge(b,d), edge(c,e), edge(d,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(7)], [[a,b],[a,c],[a,d],[a,e],[b,c],[b,d],[b,e],[c,e],[d,e]]).
io(137, exact, recursion, [edge(a,b), edge(a,c), edge(a,e), edge(b,c), edge(b,d), edge(b,e), edge(c,d), edge(d,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(7)], [[a,b],[a,c],[a,d],[a,e],[b,c],[b,d],[b,e],[c,d],[c,e],[d,e]]).
io(138, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b], B-[a,b]], [depth(4)], [[a,b]]).
io(139, exact, recursion, [edge(a,b), edge(a,d), edge(b,c), edge(b,d), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(6)], [[a,b],[a,c],[a,d],[b,c],[b,d]]).
io(140, exact, recursion, [edge(a,b), edge(a,c), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c], B-[a,b,c]], [depth(5)], [[a,b],[a,c]]).
io(141, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b], B-[a,b]], [depth(4)], [[a,b]]).
io(142, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b], B-[a,b]], [depth(4)], [[a,b]]).
io(143, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b], B-[a,b]], [depth(4)], [[a,b]]).
io(144, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c], B-[a,b,c]], [depth(5)], [[a,b]]).
io(145, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b], B-[a,b]], [depth(4)], [[a,b]]).
io(146, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b], B-[a,b]], [depth(4)], [[a,b]]).
io(147, exact, recursion, [edge(a,b), edge(a,c), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c], B-[a,b,c]], [depth(5)], [[a,b],[a,c]]).
io(148, exact, recursion, [edge(a,b), edge(a,c), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c], B-[a,b,c]], [depth(5)], [[a,b],[a,c]]).
io(149, exact, recursion, [edge(a,b), edge(a,c), edge(a,e), edge(c,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(7)], [[a,b],[a,c],[a,e],[c,e]]).
io(150, exact, recursion, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b], B-[a,b]], [depth(4)], [[a,b]]).
io(151, depth_limited, depth_limit, [edge(a,b), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c], B-[a,b,c]], [depth(2)], [[a,b]]).
io(152, depth_limited, depth_limit, [edge(a,c), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(2)], [[a,c]]).
io(153, depth_limited, depth_limit, [edge(b,c), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c], B-[a,b,c]], [depth(4)], [[b,c]]).
io(154, depth_limited, depth_limit, [edge(a,b), edge(a,c), edge(b,d), edge(b,e), edge(c,e), edge(d,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(4)], [[a,b],[a,c],[a,d],[a,e],[b,d],[b,e],[c,e],[d,e]]).
io(155, depth_limited, depth_limit, [edge(a,b), edge(a,c), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(2)], [[a,b],[a,c]]).
io(156, depth_limited, depth_limit, [edge(a,b), edge(a,c), edge(a,d), edge(b,c), edge(c,d), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(4)], [[a,b],[a,c],[a,d],[b,c],[b,d],[c,d]]).
io(157, depth_limited, depth_limit, [edge(b,c), edge(b,d), edge(c,e), edge(d,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(2)], [[b,c],[b,d],[c,e],[d,e]]).
io(158, depth_limited, depth_limit, [edge(b,c), edge(b,d), edge(c,d), edge(c,e), edge(d,e), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(3)], [[b,c],[b,d],[b,e],[c,d],[c,e],[d,e]]).
io(159, depth_limited, depth_limit, [edge(c,d), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d], B-[a,b,c,d]], [depth(2)], [[c,d]]).
io(160, depth_limited, depth_limit, [edge(a,b), edge(a,c), edge(a,e), edge(b,c), (path(X,Y) :- edge(X,Y)), (path(X,Y) :- (edge(X,Z), path(Z,Y)))], path(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [depth(4)], [[a,b],[a,c],[a,e],[b,c]]).
io(161, exact, exported_binding, [(t(W) :- (W = c)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b,c,d]], [], [[c]]).
io(162, exact, exported_binding, [(t(W) :- (W = f)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b,c,d,e,f]], [], [[f]]).
io(163, exact, exported_binding, [(t(W) :- (W = a)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b,c,d]], [], [[a]]).
io(164, exact, exported_binding, [(t(W) :- (W = z)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a]], [], []).
io(165, exact, exported_binding, [(t(W) :- (W = z)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b]], [], []).
io(166, exact, exported_binding, [(t(W) :- (W = a)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b]], [], [[a]]).
io(167, exact, exported_binding, [(t(W) :- (W = c)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b,c,d,e]], [], [[c]]).
io(168, exact, exported_binding, [(t(W) :- (W = d)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b,c,d]], [], [[d]]).
io(169, exact, exported_binding, [(t(W) :- (W = b)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b]], [], [[b]]).
io(170, exact, exported_binding, [(t(W) :- (W = d)), (u(X) :- (t(Y), (X = Y)))], u(A), [A-[a,b,c,d,e,f]], [], [[d]]).
io(171, exact, three_vars, [p(1), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[0,1], B-[0,1], C-[0,1]], [], [[1,0,1],[1,1,0]]).
io(172, exact, three_vars, [p(a), p(c), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[a,b,c], B-[a,b,c], C-[a,b,c]], [], [[a,a,b],[a,a,c],[a,b,a],[a,c,a],[c,a,c],[c,b,c],[c,c,a],[c,c,b]]).
io(173, exact, three_vars, [p(a), p(b), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[a,b], B-[a,b], C-[a,b]], [], [[a,a,b],[a,b,a],[b,a,b],[b,b,a]]).
io(174, exact, three_vars, [p(0), p(1), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[0,1], B-[0,1,2], C-[0,1,2]], [], [[0,0,1],[0,0,2],[0,1,0],[0,2,0],[1,0,1],[1,1,0],[1,1,2],[1,2,1]]).
io(175, exact, three_vars, [p(a), p(b), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[a,b], B-[a,b], C-[a,b]], [], [[a,a,b],[a,b,a],[b,a,b],[b,b,a]]).
io(176, exact, three_vars, [p(0), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[0,1], B-[0,1], C-[0,1]], [], [[0,0,1],[0,1,0]]).
io(177, exact, three_vars, [p(b), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[a,b], B-[a,b], C-[a,b]], [], [[b,a,b],[b,b,a]]).
io(178, exact, three_vars, [p(b), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[a,b,c], B-[a,b], C-[a,b]], [], [[b,a,b],[b,b,a]]).
io(179, exact, three_vars, [p(1), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[0,1], B-[0,1], C-[0,1]], [], [[1,0,1],[1,1,0]]).
io(180, exact, three_vars, [p(1), p(2), (q(X,Y,Z) :- (p(X), ((Y \= Z), ((X = Y) ; (X = Z)))))], q(A,B,C), [A-[0,1,2], B-[0,1,2], C-[0,1,2]], [], [[1,0,1],[1,1,0],[1,1,2],[1,2,1],[2,0,2],[2,1,2],[2,2,0],[2,2,1]]).
io(181, exact, chain, [par(b,d), par(d,a), par(d,c), par(d,e), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [], [[b,a],[b,c],[b,e]]).
io(182, exact, chain, [par(c,b), par(d,c), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c,d], B-[a,b,c,d]], [], [[d,b]]).
io(183, exact, chain, [par(a,b), par(b,a), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b], B-[a,b]], [], [[a,a],[b,b]]).
io(184, exact, chain, [par(a,c), par(b,c), par(c,a), par(c,b), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c], B-[a,b,c]], [], [[a,a],[a,b],[b,a],[b,b],[c,c]]).
io(185, exact, chain, [par(a,c), par(a,e), par(b,c), par(c,a), par(c,b), par(d,c), par(e,a), par(e,b), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [], [[a,a],[a,b],[b,a],[b,b],[c,c],[c,e],[d,a],[d,b],[e,c],[e,e]]).
io(186, exact, chain, [par(b,e), par(d,b), par(e,b), par(e,c), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [], [[b,b],[b,c],[d,e],[e,e]]).
io(187, exact, chain, [par(b,d), par(c,a), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c,d], B-[a,b,c,d]], [], []).
io(188, exact, chain, [par(b,a), par(c,b), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c], B-[a,b,c]], [], [[c,a]]).
io(189, exact, chain, [par(a,d), par(b,e), par(c,e), par(d,a), par(e,a), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c,d,e], B-[a,b,c,d,e]], [], [[a,a],[b,a],[c,a],[d,d],[e,d]]).
io(190, exact, chain, [par(a,b), par(b,a), (gp(X,Y) :- (par(X,Z), par(Z,Y)))], gp(A,B), [A-[a,b,c,d], B-[a,b,c,d]], [], [[a,a],[b,b]]).
io(191, exact, nested_negation, [p(a), p(b), p(c), p(d), p(e), p(f), r(a), r(c), r(d), r(e), r(f), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[a,b,c,d,e,f]], [], [[b]]).
io(192, exact, nested_negation, [p(0), r(0), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[0]], [], []).
io(193, exact, nested_negation, [p(a), p(b), p(d), p(e), r(b), r(c), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[a,b,c,d,e,f]], [], [[a],[c],[d],[e],[f]]).
io(194, exact, nested_negation, [p(a), p(b), p(c), p(d), r(a), r(b), r(c), r(d), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[a,b,c,d]], [], []).
io(195, exact, nested_negation, [p(1), p(2), p(3), p(4), r(0), r(1), r(2), r(3), r(4), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[0,1,2,3,4]], [], [[0]]).
io(196, exact, nested_negation, [p(d), p(e), p(f), r(a), r(c), r(d), r(e), r(f), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[a,b,c,d,e,f]], [], [[a],[b],[c]]).
io(197, exact, nested_negation, [p(a), p(b), r(b), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[a,b]], [], [[a]]).
io(198, exact, nested_negation, [p(0), r(0), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[0]], [], []).
io(199, exact, nested_negation, [p(1), p(4), r(2), r(3), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[0,1,2,3,4]], [], [[0],[1],[2],[3],[4]]).
io(200, exact, nested_negation, [p(2), p(3), p(4), r(1), r(2), r(3), r(4), (s(X) :- (\+ r(X))), (q(X) :- ((p(X), s(X)) ; (\+ p(X))))], q(A), [A-[0,1,2,3,4]], [], [[0],[1]]).
io(201, exact, arith_sum, [(q(X,Y) :- ((S is (X + Y)), (S >= 4)))], q(A,B), [A-[0,1,2], B-[0,1,2,3]], [], [[1,3],[2,2],[2,3]]).
io(202, exact, arith_sum, [(q(X,Y) :- ((S is (X + Y)), (S >= 4)))], q(A,B), [A-[0,1,2,3], B-[0,1,2]], [], [[2,2],[3,1],[3,2]]).
io(203, exact, arith_sum, [(q(X,Y) :- ((S is (X + Y)), (S =\= 1)))], q(A,B), [A-[0,1,2], B-[0,1,2,3,4]], [], [[0,0],[0,2],[0,3],[0,4],[1,1],[1,2],[1,3],[1,4],[2,0],[2,1],[2,2],[2,3],[2,4]]).
io(204, exact, arith_sum, [(q(X,Y) :- ((S is (X + Y)), (S < 4)))], q(A,B), [A-[0,1,2,3,4], B-[0,1,2]], [], [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[3,0]]).
io(205, exact, arith_sum, [(q(X,Y) :- ((S is (X + Y)), (S =< 2)))], q(A,B), [A-[0,1,2], B-[0,1,2,3,4]], [], [[0,0],[0,1],[0,2],[1,0],[1,1],[2,0]]).
io(206, exact, arith_sum, [(q(X,Y) :- ((S is (X + Y)), (S =\= 6)))], q(A,B), [A-[0,1,2], B-[0,1,2]], [], [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]]).
io(207, exact, arith_compare, [(q(X) :- (X >= 7))], q(A), [A-[0,1,2,3]], [], []).
io(208, exact, arith_compare, [(q(X) :- (X =< 1))], q(A), [A-[0,1,2,3]], [], [[0],[1]]).
io(209, exact, arith_compare, [(q(X) :- (X < 7))], q(A), [A-[0,1,2,3,4,5]], [], [[0],[1],[2],[3],[4],[5]]).
io(210, exact, arith_compare, [(q(X) :- (X < 4))], q(A), [A-[0,1,2,3,4,5]], [], [[0],[1],[2],[3]]).
io(211, exact, arith_compare, [(q(X) :- (X > 6))], q(A), [A-[0,1,2,3,4,5]], [], []).
io(212, exact, arith_compare, [(q(X) :- (X >= 6))], q(A), [A-[0,1,2,3]], [], []).
io(213, exact, arith_is, [(q(X,Y) :- (Y is ((X * 3) + 0)))], q(A,B), [A-[0,1,2,3,4], B-[0,1,2,3,4,5]], [], [[0,0],[1,3]]).
io(214, exact, arith_is, [(q(X,Y) :- (Y is ((X * 1) + 2)))], q(A,B), [A-[0,1,2], B-[0,1,2,3,4,5]], [], [[0,2],[1,3],[2,4]]).
io(215, exact, arith_is, [(q(X,Y) :- (Y is ((X * 1) + 2)))], q(A,B), [A-[0,1,2,3,4], B-[0,1,2,3,4,5,6]], [], [[0,2],[1,3],[2,4],[3,5],[4,6]]).
io(216, exact, arith_is, [(q(X,Y) :- (Y is ((X * 1) + 1)))], q(A,B), [A-[0,1,2], B-[0,1,2,3]], [], [[0,1],[1,2],[2,3]]).
io(217, exact, arith_is, [(q(X,Y) :- (Y is ((X * 1) + 2)))], q(A,B), [A-[0,1,2,3,4], B-[0,1,2,3,4,5,6,7,8]], [], [[0,2],[1,3],[2,4],[3,5],[4,6]]).
io(218, exact, arith_mod, [(q(X) :- ((M is (X mod 2)), (M =:= 0)))], q(A), [A-[0,1,2,3,4,5,6,7,8,9]], [], [[0],[2],[4],[6],[8]]).
io(219, exact, arith_mod, [(q(X) :- ((M is (X mod 4)), (M =:= 1)))], q(A), [A-[0,1,2,3,4,5,6,7,8,9]], [], [[1],[5],[9]]).
io(220, exact, arith_mod, [(q(X) :- ((M is (X mod 2)), (M =:= 1)))], q(A), [A-[0,1,2,3,4,5,6,7,8,9]], [], [[1],[3],[5],[7],[9]]).
io(221, exact, arith_mod, [(q(X) :- ((M is (X mod 3)), (M =:= 1)))], q(A), [A-[0,1,2,3,4,5,6]], [], [[1],[4]]).
io(222, exact, arith_mod, [(q(X) :- ((M is (X mod 2)), (M =:= 0)))], q(A), [A-[0,1,2,3,4,5,6,7,8]], [], [[0],[2],[4],[6],[8]]).
io(223, exact, arith_between, [(q(X) :- between(2,4,X))], q(A), [A-[0,1,2,3,4,5,6]], [], [[2],[3],[4]]).
io(224, exact, arith_between, [(q(X) :- between(1,3,X))], q(A), [A-[0,1,2,3,4,5]], [], [[1],[2],[3]]).
io(225, exact, arith_between, [(q(X) :- between(2,2,X))], q(A), [A-[0,1,2,3,4,5,6]], [], [[2]]).
io(226, exact, arith_between, [(q(X) :- between(2,3,X))], q(A), [A-[0,1,2,3,4,5]], [], [[2],[3]]).
io(227, exact, arith_facts, [cost(a,2), cost(b,2), (q(X) :- (cost(X,Y), (\+ (Y > 5))))], q(A), [A-[a,b]], [], [[a],[b]]).
io(228, exact, arith_facts, [cost(a,8), cost(b,3), cost(c,4), cost(d,7), (q(X) :- (cost(X,Y), (\+ (Y > 8))))], q(A), [A-[a,b,c,d]], [], [[a],[b],[c],[d]]).
io(229, exact, arith_facts, [cost(a,2), cost(b,9), cost(c,8), (q(X) :- (cost(X,Y), (Y =< 7)))], q(A), [A-[a,b,c]], [], [[a]]).
io(230, exact, arith_facts, [cost(a,2), cost(b,1), (q(X) :- (cost(X,Y), (\+ (Y > 7))))], q(A), [A-[a,b]], [], [[a],[b]]).
io(231, exact, arith_three, [(q(X,Y,Z) :- (Z =:= max(X,Y)))], q(A,B,C), [A-[0,1,2,3], B-[0,1,2,3], C-[0,1,2,3,4,5,6]], [], [[0,0,0],[0,1,1],[0,2,2],[0,3,3],[1,0,1],[1,1,1],[1,2,2],[1,3,3],[2,0,2],[2,1,2],[2,2,2],[2,3,3],[3,0,3],[3,1,3],[3,2,3],[3,3,3]]).
io(232, exact, arith_three, [(q(X,Y,Z) :- (Z =:= max(X,Y)))], q(A,B,C), [A-[0,1,2], B-[0,1,2], C-[0,1,2,3,4]], [], [[0,0,0],[0,1,1],[0,2,2],[1,0,1],[1,1,1],[1,2,2],[2,0,2],[2,1,2],[2,2,2]]).
io(233, exact, arith_three, [(q(X,Y,Z) :- (Z =:= min(X,Y)))], q(A,B,C), [A-[0,1,2], B-[0,1,2], C-[0,1,2,3,4,5,6]], [], [[0,0,0],[0,1,0],[0,2,0],[1,0,0],[1,1,1],[1,2,1],[2,0,0],[2,1,1],[2,2,2]]).
io(234, exact, arith_three, [(q(X,Y,Z) :- (Z =:= min(X,Y)))], q(A,B,C), [A-[0,1,2,3], B-[0,1,2,3], C-[0,1,2,3,4]], [], [[0,0,0],[0,1,0],[0,2,0],[0,3,0],[1,0,0],[1,1,1],[1,2,1],[1,3,1],[2,0,0],[2,1,1],[2,2,2],[2,3,2],[3,0,0],[3,1,1],[3,2,2],[3,3,3]]).
io(235, exact, arith_recursion, [edge(a,b), edge(a,c), edge(b,c), (steps(X,Y,N) :- (edge(X,Y), (N is 1))), (steps(X,Y,N) :- (edge(X,Z), (steps(Z,Y,M), (N is (M + 1)))))], steps(A,B,C), [A-[a,b,c], B-[a,b,c], C-[1,2,3]], [depth(5)], [[a,b,1],[a,c,1],[a,c,2],[b,c,1]]).
io(236, exact, arith_recursion, [edge(b,c), (steps(X,Y,N) :- (edge(X,Y), (N is 1))), (steps(X,Y,N) :- (edge(X,Z), (steps(Z,Y,M), (N is (M + 1)))))], steps(A,B,C), [A-[a,b,c], B-[a,b,c], C-[1,2,3]], [depth(5)], [[b,c,1]]).
io(237, exact, arith_recursion, [edge(a,b), (steps(X,Y,N) :- (edge(X,Y), (N is 1))), (steps(X,Y,N) :- (edge(X,Z), (steps(Z,Y,M), (N is (M + 1)))))], steps(A,B,C), [A-[a,b], B-[a,b], C-[1,2,3]], [depth(4)], [[a,b,1]]).
io(238, exact, arith_recursion, [edge(a,b), (steps(X,Y,N) :- (edge(X,Y), (N is 1))), (steps(X,Y,N) :- (edge(X,Z), (steps(Z,Y,M), (N is (M + 1)))))], steps(A,B,C), [A-[a,b,c,d], B-[a,b,c,d], C-[1,2,3]], [depth(6)], [[a,b,1]]).
io(239, exact, arith_recursion, [edge(a,b), edge(b,d), (steps(X,Y,N) :- (edge(X,Y), (N is 1))), (steps(X,Y,N) :- (edge(X,Z), (steps(Z,Y,M), (N is (M + 1)))))], steps(A,B,C), [A-[a,b,c,d], B-[a,b,c,d], C-[1,2,3]], [depth(6)], [[a,b,1],[a,d,2],[b,d,1]]).
io(240, exact, arith_recursion, [edge(a,c), (steps(X,Y,N) :- (edge(X,Y), (N is 1))), (steps(X,Y,N) :- (edge(X,Z), (steps(Z,Y,M), (N is (M + 1)))))], steps(A,B,C), [A-[a,b,c], B-[a,b,c], C-[1,2,3]], [depth(5)], [[a,c,1]]).
