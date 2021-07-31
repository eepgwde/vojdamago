// @file samples1c.q
// @author weaves

// Appending monthly histories
// Aggregate across action type (status1) action, noaction
//
// defects are easy, but permits need a column change.
// The 4pty type introduced is not added. (I think).

// Defects are simple.

n0: first .tmp.n0

tsamples1: .tmp.samples1

count .samples.dfcts[n0]

b00: `cwy`date0 xkey `cwy`date0 xcol .samples.dfcts[n0]

// Store the names, switch over to generic names
c0: cols value b00
c1: `cwy`date0`status1`count0`rfr0`inspct0`action0`cat0`risk0

b00: (c1 xcol 0!b00) lj .dfct.status1

b02: update weight0: count0 * status2 by cwy, date0, status1 from b00

b03: `date0`cwy xasc select sum weight0, sum count0, sum rfr0, sum inspct0, sum action0, avg cat0, avg risk0 by cwy, date0 from b02

// Back to original names, we have lost status, but put weight0 in its place
c2: (`cwy0`date0),c0

b03: `date0`cwy0 xasc c2 xcol b03

tsamples1: `date0`cwy0 xasc tsamples1 lj b03

// Now impute

.samples.dfctimpute: (1j;0j;0i;0i;0i;6f;0.01f)

.samples.dfctimputes[n0]: cols value b03

tsamples1: .hcc.impute0[tsamples1;cols value b03; .samples.dfctimpute ]

// ---- Permits

// Permits are of two kinds.
// So we aggregate across those
// And we have to scale by assets in the siteid

sclrs: select nassets: count i by siteid from usrn2aid

select count i by ptype0 from .samples.prmt

// Change columns

// Use a decimal scheme
.samples.prmtptype0: `status1 xkey ([] status1:`3pty`HA; status2:10 1000) 

b00: `siteid`date0 xkey `siteid`date0 xcol .samples.prmts[n0]

// switch over to generic names
c0: cols value b00

c1: `siteid`date0`status1`count0`cat0`ddt0`risk0

b00: (c1 xcol 0!b00) lj .samples.prmtptype0

b02: update weight0: count0 * status2 by siteid, date0, status1 from b00

b03: select sum weight0, sum count0, avg cat0, sum ddt0, avg risk0 by siteid, date0 from b02

update count0 % sclrs[([]siteid);`nassets], ddt0 % sclrs[([]siteid);`nassets] by siteid from `b03 ;

// Back to original names, we have lost status, but put weight0 in its place
// but ptype0 is now specific to the type
f1: `${ ssr[x;"prmt";"prmtT"] } @ string c0[1]

c2: (`siteid`date0),f1,1_c0

b03: c2 xcol b03

tsamples1: tsamples1 lj b03

.samples.prmtimpute: (1j;0f;0f;0f;0.01f)

tsamples1: .hcc.impute0[tsamples1;cols value b03; .samples.prmtimpute ]

.tmp.samples1: tsamples1

// Clean up
a00: a02: b00: b02: b03: r0: t0: t1: t2: kt1: c0: c1: c2: ();
delete a00, a02, b00, b02, b03, r0, t1, t2, kt1, c0, c1, c2 from `.;

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
