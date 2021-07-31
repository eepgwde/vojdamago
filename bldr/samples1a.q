// @file samples1a.q
// @author weaves

// Histories for dfcts.

// We can simplify to just date and siteid

// .tmp.n0 is a list: window size, when to start window.
n0: first .tmp.n0
ddt: last .tmp.n0

tag1: .samples.catns[n0]


t0: select count i by cwy0, date0 from samples1

// Quite a lot of activity - multiple reports in same period.

t1: select distinct cwy0 by date0 from t0

// Dates to process
kt1: raze value flip key t1

t1[first kt1;`cwy0]

// mstr0 is dfct2 with cwy as the feature-id
// cwys0 is the keyed table of date to cwys (t1) with cwy0 as the feature-id field.

// To refine the defects table
refiner0: { [x;cwys0;mstr0] cwys: cwys0[x;`cwy0]; x0:select from mstr0 where cwy in cwys }

r0: { [dt0;mstr0;n0;tag0;cwys0;ddt] tbl: refiner0[dt0 - ddt;cwys0;mstr0]; .hcc.dfct2risk1[tbl; dt0; n0; tag0; ddt] }[;dfct2;n0;tag1;t1;ddt] each kt1

// r0 is a list of keyed tables, they have be unkeyed, joined, and aggregated to siteid and dt0
r0: { 0!x } each r0
a00: `cwy`dt0 xasc raze r0;

.samples.dfct: a00

// Clean up
a00: a02: r0: t1: t2: kt1: ();

delete a00, a02, r0, t1, t2, kt1 from `.;


/

// Test

x0: refiner0[;t1;dfct2] each 5#kt1

count each x0

\


/  Local Variables: 
/  mode:kdbp
/  minor-mode:q 
/  q-prog-args: "-p 5000 -c 200 120 -C 2000 2000 -load ../cache/csvdb help.q -verbose -halt -quiet"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
