%% path.pl - a small graph with a recursive path/2.
%% Compile with:
%%   ?- pl2qc_file('path.pl', path(X, Y), [X-[a,b,c,d], Y-[a,b,c,d]], [depth(6)], O).

edge(a, b).
edge(b, c).
edge(c, d).

path(X, Y) :- edge(X, Y).
path(X, Y) :- edge(X, Z), path(Z, Y).
