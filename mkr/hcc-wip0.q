// @file hcc-wip0.q
// @author weaves

.csv.d0: (raze value "\\pwd"),"/../out"
.csv.t2csv: .sch.t2csv3[;"csv";.csv.d0]

a2str: { [tbl;asym] f: { string x }; b: (enlist `i)!enlist `i; a: (enlist asym)!enlist (f;asym); ![tbl;();b;a] }

a2str1: { [tbl;asym] b: (enlist `i)!enlist `i; a: (enlist asym)!enlist (enlist("");asym); ![tbl;();b;a] }

// Convert a table's symbols to strings.
// Uses a global     
t2str: { [tbl] .t.tbl:tbl; v:exec c from (meta .t.tbl) where t = "s"; { .t.tbl::.sch.a2str[.t.tbl;x] } each v; v:exec c from (meta .t.tbl) where t = " "; { .t.tbl::.sch.a2str1[.t.tbl;x] } each v; .t.tbl }

.t.tbl:permit1

v:exec c from (meta .t.tbl) where t = "s"

{ .t.tbl::a2str[.t.tbl;x] } each v

v:exec c from (meta .t.tbl) where t = " "

{ .t.tbl::a2str1[.t.tbl;x] } each v

x0:.t.tbl

.sch.t2csv[`x0]

