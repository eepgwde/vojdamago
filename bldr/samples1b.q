// @file samples1b.q
// @author weaves

// Monthly history for permits.

// We can simplify to just date and siteid

.sys.qreloader enlist "hcc.q"

// .tmp.n0 is now a list

n0: first .tmp.n0
ddt: last .tmp.n0

tag1: .samples.catns[n0]


t0: select count i by cwy0.siteid, date0 from samples1

// Quite a lot of activity - multiple reports in same period.

t1: select distinct siteid by date0 from t0

kt1: raze value flip key t1

t1[first kt1;`siteid]

// To refine the permits table
refiner0: { [x;sts0;mstr0] sites0: sts0[x;`siteid]; x0:select from mstr0 where siteid in sites0 }

r0: { [dt0;mstr0;n0;tag0;sts0;ddt] tbl: refiner0[dt0 - ddt;sts0;mstr0]; .hcc.prmtrisk1[tbl; dt0; n0; tag0;ddt] }[;permit2;n0;tag1;t1;ddt] each kt1

r0: { 0!x } each r0
a00: `siteid`dt0 xasc raze r0;

.samples.prmt: a00

// Clean up
a00: a02: r0: t1: t2: kt1: ();
delete a00: a02, r0, t1, t2, kt1 from `.;


/

// Test

x0: refiner0[;t1;`permit2] each 5#kt1

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
