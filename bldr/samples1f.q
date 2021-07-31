// @file samples1e.q
// @author weaves

// Monthly weighed history for assets within enquiries

// For each asset generated an exponentially time-weighted average of the number
// of times it has appeared in the Enquiries

// .tmp.n0 is a list: window size, when to start window.
n0: first .tmp.n0
ddt: last .tmp.n0

tag1: .samples.catns[n0]

t0: select count i by siteid, date0 from samples1

// Quite a lot of activity - multiple reports in same period.

t1: select distinct siteid by date0 from t0

// Dates to process
kt1: raze value flip key t1

t1[first kt1;`siteid]

// mstr0 is samples with cwy as the feature-id
// cwys0 is the keyed table of date to cwys (t1) with siteid as the feature-id field.

// To refine the samples1 table
refiner0: { [x;cwys0;mstr0] cwys: cwys0[x;`siteid]; x0:select from mstr0 where siteid in cwys }

r0: { [dt0;mstr0;n0;tag0;cwys0;ddt] tbl: refiner0[dt0 - ddt;cwys0;mstr0]; .hcc.ssmpl2risk1[tbl; dt0; n0; tag0; ddt] }[;samples1;n0;tag1;t1;ddt] each kt1

// r0 is a list of keyed tables, they have be unkeyed, joined, and aggregated
// to cwy0 and date0
r0: { 0!x } each r0
a00: `siteid`date0 xasc raze r0;

.samples.prmt: a00

// Clean up
a00: a02: r0: t1: t2: kt1: ();

delete a00, a02, r0, t1, t2, kt1 from `.;


/

// Test

.tmp.n0: 30 0

refiner0: { [x;cwys0;mstr0] cwys: cwys0[x;`siteid]; x0:select from mstr0 where siteid in cwys }

x0: refiner0[;t1;samples1] each 5#kt1

r0: { [dt0;mstr0;n0;tag0;cwys0;ddt] tbl: refiner0[dt0 - ddt;cwys0;mstr0]; .hcc.smpl3risk1[tbl; dt0; n0; tag0; ddt] }[;samples1;n0;"";t1;ddt] each -5#kt1


tsym:samples1
dt0: last kt1
n0: 90 ; ddt: 30
dts: dts: (asc dt0, dt0 - n0) - ddt;
dt00: dt0

wts: n0#.hcc.ewma1[(1,n0#0);10]

x1: `siteid`date0 xasc select by smpl0 from tsym where date0 within dts;

s0: ungroup select distinct smpl0 by siteid from tsym where date0 within dts; /  in period

s0: distinct s0[;`smpl0];

// And get those
g1: select by smpl0 from tsym where smpl0 in s0;

// calculate risk

n1: abs `float$n0;

g2: select smpl1:count i, ddts: dt00 - date0, ddts1: 0^wts[dt00 - date0], smplwt1: (0^wts[dt00 - date0]) wsum (count i)#1, smplrisk1: (0^wts[dt00 - date0]) wsum (count i)#1 wsum priority by siteid from g1;

select from g2 where cwy0 = `$"0U151/10"


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
