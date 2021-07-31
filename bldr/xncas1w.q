// weaves
// @file hcc-wip.q

// Another report: defect inspections and actions (with the NCA count)

dt2w0: 1!0!key select by date0, wk0 from luton1

dfct1w: update date0:`date$dt0 from dfct1
dfct1w: (`date0 xkey dfct1w) lj dt2w0

ncas0: select unsuperseded:sum not superseded, superseded: sum superseded by wk0,mm0:`month$dt0 from dfct1w  where (prioritycode = `NCA)

ncas0: select by wk0 from ncas0 where mm0 within .dcover.dates0

inspct1: select inspct:sum inspct0, action1:sum action1 by wk0, mm0:`month$dt0 from dfct1w
inspct1: select by wk0 from inspct1 where mm0 within .dcover.dates0

clm1w: update date0:`date$lossdate from clm1
clm1w: (`date0 xkey clm1w) lj dt2w0

clms3: select claims:sum `Settled = outcome1, repudns: sum `Repudiated = outcome1 by wk0, mm0:`month$lossdate from clm1w;
clms3: select by wk0, mm0 from clms3 where mm0 within .dcover.dates0


enq1w: update date0:`date$enquirytime0 from enq1
enq1w: (`date0 xkey enq1w) lj dt2w0

enq1a: update tdt0: `date$max (followupdate0;enquirytime0;loggeddate0) by i from enq1w

enq1a: (`tdt0 xkey enq1a) lj `tdt0`wk1 xcol dt2w0

enq2: select enqs: `int$count i by wk0, mm0:`month$enquirytime0 from enq1a

enq2: enq2 lj select enq1s: `int$count i  by wk0, mm0:`month$enquirytime0 from enq1a where 4 > priority ;

enq2: enq2 lj select enq2s: `int$count i by wk0, mm0:`month$enquirytime0 from enq1a where 4 <= priority ;


enq2: enq2 lj select enqrs: sum `repair = estatus0 by wk0:wk1, mm0:`month$tdt0 from enq1a ;

enq2: enq2 lj select enqr1s: sum `repair = estatus0 by wk0:wk1, mm0:`month$tdt0 from enq1a where 4 > priority ;

enq2: enq2 lj select enqr2s: sum `repair = estatus0 by wk0:wk1, mm0:`month$tdt0 from enq1a where 4 <= priority ;

enq2: select by wk0, mm0 from enq2 where mm0 within .dcover.dates0

xncas1w: ncas0 lj inspct1 lj clms3 lj enq2;

update mm1:`mm$mm0, dt0: -1 + `date$(1 + mm0) from `xncas1w ;

// Get weather in our range and a month earlier
// w2: select first tmax, first tmin, first af, first rain by mm0:month0 from weather1 where month0 within (.dcover.dates0[0]-1; .dcover.dates0[1])

w2: `wk0 xkey select wk0, tmax, tmin, af, rain from select by wk0 from luton2w where month0 within (.dcover.dates0[0]-1; .dcover.dates0[1])

f: { [v] dv: (deltas v) % prev v; 0^.sch.inf2v[;1f] @ dv }

c0: `tmax`tmin`rain`af
c1: { (f;x) } each c0

c2: { `$"d",string x } each c0
dc0: `wk0,c2

a:dc0!`wk0,c1

// ?[w2;();0b;(`drain`daf!((f;`rain);(f;`af)))]

w2: w2 lj `wk0 xkey ?[w2;();0b;a]

xncas1w: xncas1w lj w2

c0: (cols xncas1w) except c0,`dt0`mm1`mm0`wk0,c2

// the kpis are also relative to current value
g: { [v] dv: (deltas v) % prev v; 0^.sch.inf2v[;1f] @ dv }

c1: { (g;x) } each c0

dc0: { `$"d",string x } each c0

xncas1w: ![xncas1w;();0b;dc0!c1]

xncas1w: `mm0 xcol delete mm0 from xncas1w

// Change the dt0 to be that of the week
ncas1w: xncas1w lj `mm0 xkey `dt0`mm0 xcol dt2w0
update mm1:mm0 mod 52 from `ncas1w;

.csv.t2csv[`ncas1w]


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


