// @author weaves
// @file tables0.q
//
// Special tables.

// write to the cache directory

\l hcc.q

`.dcover set get `:./wsdcover ;

.dcover.dates0

// Get a list of written tables now

tbls: tables `.

// Do the specials

// * Incidence breakdown

y0: select count i by cwy from dfct2
y1: distinct raze value flip key y0

x0: select distinct cwy0 by outcome1 from samples1

u0: raze value x0[`noaction;]

r0: raze value x0[`repudiated;]
s0: raze value x0[`settled;]

count each (y1;u0;r0;s0)

count u0 except y1

count r0 except u0
count s0 except u0

c0: `cwy0`date0 xdesc ungroup select type0:`claim, date0 by cwy0 from samples1 where (cwy0 in s0), isclm0
update cdate0:date0 from `c0;

e0: `cwy0`date0 xdesc ungroup select type1:`enq, date0:`date$enquirytime0 by cwy0:cwy from enq1 where not null cwy
update xdate0:date0 from `e0;

c2e: aj[`cwy0`date0;c0;e0]
update type1: fills type1, xdate0: fills xdate0 by cwy0 from `c2e ;
update xdate0: `date$0N by i from `c2e where cdate0 <= xdate0 ;
update type1:` from `c2e where null xdate0 ;

c2e: `cwy0`date0 xasc c2e

count select count i by cwy0 from c2e where null type1

d0: `cwy0`date0 xdesc ungroup select type1:`dfct, date0:dt1 by cwy0:cwy from dfct2 where not null cwy
update xdate0:date0 from `d0;

c2d: aj[`cwy0`date0;c0;d0]
update type1: fills type1, xdate0: fills xdate0 by cwy0 from `c2d ;
update xdate0: `date$0N by i from `c2d where cdate0 <= xdate0 ;
update type1:` from `c2d where null xdate0 ;
c2d: `cwy0`date0 xasc c2d 

w0: `cwy0`date0 xdesc ungroup select type1:`wrk, date0 by cwy0 from wrk1 where (not null cwy0), not worktype in `other`verge

update xdate0:date0 from `w0;

c2w: aj[`cwy0`date0;c0;w0]
update type1: fills type1, xdate0: fills xdate0 by cwy0 from `c2w ;
update xdate0: `date$0N by i from `c2w where cdate0 <= xdate0 ;
update type1:` from `c2w where null xdate0 ;

c2w: `cwy0`date0 xasc c2w

c2a: `cwy0`xdate0`cdate0 xasc delete date0 from c2d,c2e,c2w ;

c2b: delete type0 from distinct c2a

c2x: `cwy0`xdate0`cdate0 xasc (select from c2b where null type1) lj select by cwy0, cdate0 from c2b where not null type1

e2c: `cwy0`xdate0`type1`cdate0 xcols c2x
update ddays:cdate0 - xdate0, pri:cwy0.pri, distance:cwy0.distance, e0:1i from `e2c ;

x0: 0!select type1: first type1, n:sum e0, avg ddays by cwy0 from e2c where type1 = `dfct ;
x0,: 0!select type1: first type1, n:sum e0, avg ddays by cwy0 from e2c where type1 = `enq ;
x0,: 0!select type1: first type1, n:sum e0, avg ddays by cwy0 from e2c where type1 = `wrk ;
x0,: 0!select type1: first type1, n:sum e0, avg ddays by cwy0 from e2c where null type1 ;

x1: select by cwy0, type1 from x0
update pri:cwy0.pri, distance:cwy0.distance, lanes:cwy0.lanes, nassets:cwy0.nassets, mtraffic:cwy0.mtraffic from `x1 ;

update ddays:{ .sch.logbin[x;1] } each ddays, distance: 0.5 xbar { .sch.logbin[x;1] } each distance, mtraffic: 0.5 xbar { .sch.logbin[x;1] } each mtraffic, nassets: 0.5 xbar { .sch.logbin[x;1] } each nassets  from `x1 ;

update type1:`clm, ddays:0f from `x1 where null ddays;

m0: exec min mtraffic from x1

update mtraffic:m0 from `x1 where null mtraffic ;

e2c: x1

.csv.t2csv[`e2c]

delete c2x, c2b, c2a, c2e, c2d, c2w, w0, d0, e0, c0, x0, x1 from `.;

// * Reference files, codings

// Enquiries

`.enq set get `:./wsenq ; 

t0: select by priority from .enq.priority
pr0t: `priority xasc (select n:count i by priority from samples1) lj t0
.csv.t2csv[`pr0t]

pr1t: select n: count i, sum isclm0  by priority, response from samples1
.csv.t2csv[`pr1t]

// Carriageways

`.cwy set get `:./wscwy ;

roadtype0: select n:count i, sum isclm0 by cwy0.roadtype, cwy0.lanes2, cwy0.isdual from samples1
.csv.t2csv[`roadtype0]

/

// Test 
roadtypehw0: select n:count i, sum isclm0 by cwy0.roadtypehw, cwy0.isslip, cwy0.isshar, cwy0.isdual from samples1
.csv.t2csv[`roadtypehw0]

\

c0: cols .cwy.roadtypehw

a: `n`isclm0!((count;`i);(sum;`isclm0));
b: (enlist `roadtypehw)!(enlist `cwy0.roadtypehw)

// cwy fields in samples1, construct a by clause, with original cwy category
// aggregate by total in category and claims in category

roadtypehw0: .sch.sums0[c0;a;b;samples1]

.csv.t2csv[`roadtypehw0]


c0: cols .cwy.roadhierarchy
b: (enlist `roadhierarchy)!(enlist `cwy0.roadhierarchy)

// cwy fields in samples1, construct a by clause, with original cwy category
// aggregate by total in category and claims in category

roadhierarchy0: .sch.sums0[c0;a;b;samples1]

.csv.t2csv[`roadhierarchy0]

// pri is in hierarchy

c0: cols .cwy.hierarchy
b: (enlist `hierarchy)!(enlist `cwy0.hierarchy)

// cwy fields in samples1, construct a by clause, with original cwy category
// aggregate by total in category and claims in category

hierarchy0: .sch.sums0[c0;a;b;samples1]

.csv.t2csv[`hierarchy0]


// pri2 

c0: cols .cwy.roadclass

c0: c0 except `pri

b: (enlist `roadclass)!(enlist `cwy0.roadclass)
b,: (enlist `pri2)!enlist `pri

// cwy fields in samples1, construct a by clause, with original cwy category
// aggregate by total in category and claims in category

roadclass0: .sch.sums0[c0;a;b;samples1]

.csv.t2csv[`roadclass0]


// Width report over the years

c0: cols .cwy.roadhierarchy

b: (enlist `width0)!enlist (xbar;3.5;`width)
b,: (enlist `yy)!enlist ({ `year$x };`date0)
b,: (enlist `ssn)!enlist `ssn
     
width0: `n xdesc `yy`rh0 xasc .sch.sums0[c0;a;b;samples1]

.csv.t2csv[`width0]

// correlation to mtraffic
// not as easy as I thought, mtraffic not as exclusive

a0: `width`mtraffic xkey `width xdesc `i`width`mtraffic`n xcols 0!10#select by i: i+1 from `n xdesc select n:count i, width wavg count i by width,mtraffic from cwy0

b0: `width`mtraffic xkey `width xdesc `j`width`mtraffic`n xcols 0!10#select by j: i+1 from `n xdesc select n:count i by (3.5 xbar width), mtraffic from cwy0


a0: select by i: i+1 from `n xdesc ungroup select n:count i, { 3.5 xbar x } each enlist avg width by mtraffic from cwy0
a0: `width`mtraffic xkey `width`mtraffic xdesc `i`width`mtraffic`n xcols 0!a0


b0: select by j: i+1 from `n xdesc select n:count i, avg mtraffic by 3.5 xbar width from cwy0

b0: `width`mtraffic xkey `width`mtraffic xdesc `j`width`mtraffic`n xcols 0!b0

/

// Performance at fixing defects
// Note: no actions for 2013 or 2014 TODO.

x0: 0!select type0:`fC2, count0:count i, mean0:avg dfctfC2 by yr0:`year$date0 from samples1 where (0 < dfctfC2)
x0,: 0!select type0:`fC1, count0: count i, mean0:avg dfctfC1 by yr0:`year$date0 from samples1 where (0 < dfctfC1)

x0,: 0! select type0:`afC1, count0:count i, mean0:avg dfctactionfC1 by yr0:`year$date0 from samples1 where (0 < dfctactionfC1)

x0,: 0! select type0:`afC2, count0:count i, mean0:avg dfctactionfC2 by yr0:`year$date0 from samples1 where (0 < dfctactionfC2)

x0: `yr0`type0 xasc x0

\

// Another report: defect inspections and actions (with the NCA count)

ncas0: select unsuperseded:sum not superseded, superseded: sum superseded by mm0:`month$dt0 from dfct1 where (prioritycode = `NCA)
ncas0: select by mm0 from ncas0 where mm0 within .dcover.dates0

inspct1: select inspct:sum inspct0, action1:sum action1 by mm0:`month$dt0 from dfct1
inspct1: select by mm0 from inspct1 where mm0 within .dcover.dates0

clms3: select claims:sum `Settled = outcome1, repudns: sum `Repudiated = outcome1 by mm0:`month$lossdate from clm1;
clms3: select by mm0 from clms3 where mm0 within .dcover.dates0

enq1a: update tdt0: max (followupdate0;enquirytime0;loggeddate0) by i from enq1

enq2: select enqs: `int$count i by mm0:`month$enquirytime0 from enq1a

enq2: enq2 lj select enq1s: `int$count i  by mm0:`month$enquirytime0 from enq1a where 4 > priority ;

enq2: enq2 lj select enq2s: `int$count i by mm0:`month$enquirytime0 from enq1a where 4 <= priority ;


enq2: enq2 lj select enqrs: sum `repair = estatus0 by mm0:`month$tdt0 from enq1a ;

enq2: enq2 lj select enqr1s: sum `repair = estatus0 by mm0:`month$tdt0 from enq1a where 4 > priority ;

enq2: enq2 lj select enqr2s: sum `repair = estatus0 by mm0:`month$tdt0 from enq1a where 4 <= priority ;

enq2: select by mm0 from enq2 where mm0 within .dcover.dates0

xncas1: ncas0 lj inspct1 lj clms3 lj enq2;

update mm1:`mm$mm0, dt0: -1 + `date$(1 + mm0) from `xncas1 ;

// Get weather in our range and a month earlier
// w2: select first tmax, first tmin, first af, first rain by mm0:month0 from weather1 where month0 within (.dcover.dates0[0]-1; .dcover.dates0[1])

w2: `mm0 xkey select mm0, tmax, tmin, af, rain from select by mm0:month0 from luton2 where month0 within (.dcover.dates0[0]-1; .dcover.dates0[1])

f: { [v] dv: (deltas v) % prev v; 0^.sch.inf2v[;1f] @ dv }

c0: `tmax`tmin`rain`af
c1: { (f;x) } each c0

c2: { `$"d",string x } each c0
dc0: `mm0,c2

a:dc0!`mm0,c1

// ?[w2;();0b;(`drain`daf!((f;`rain);(f;`af)))]

w2: w2 lj `mm0 xkey ?[w2;();0b;a]

xncas1: xncas1 lj w2

c0: (cols xncas1) except c0,`dt0`mm1`mm0,c2

// the kpis are also relative to current value
g: { [v] dv: (deltas v) % prev v; 0^.sch.inf2v[;1f] @ dv }

c1: { (g;x) } each c0

dc0: { `$"d",string x } each c0

ncas1: ![xncas1;();0b;dc0!c1]

.csv.t2csv[`ncas1]

// Last months of weather from luton

weather0: select by month0 from luton2 where month0 >= `month$2017.10.01
.csv.t2csv[`weather0]

// Produce a weekly variant
.sys.qreloader enlist "xncas1w.q"

// action1 and inspct0
// Is action1 a good indicator that a road was patched
// Is inspct0 a good indicator that a road was inspected
// n is the number of records that match that criteria.
// status0 is my intermediate interpretation of statusname.
// superseded is an indicator if the record will be superseded later.

// I use this data to look back at the defect history for any one asset.
// I use it to look forward as well - to see if work has been done.

dfctstatus: 0!`n xdesc select n:count i by statuscode, statusname, superseded, status0, inspct0, action1  from dfct1
.csv.t2csv[`dfctstatus]

// Key features are priority and response within samples - includes imputations

priresp0: select claims:count i by priority, response from samples1 where isclm0
.csv.t2csv[`priresp0];


// Are the defects histories consistent across the years.

`.samples set get `:./wssamples ; 

days0: .samples.catx0[;0]

// Many claims have no prior history as referrals

x00: 0!select type0:`bC1, nday:days0[0], n:count i, rfr0: sum dfctrfrbC1, act0: sum dfctactionbC1, dfct0mn:avg statusbC1, dfct0sd:sdev statusbC1 by yr0:`year$date0, isclm0,outcome1 from samples1 where (0 < dfctbC1)

x00,: 0!select type0:`bC2, nday:days0[1], n:count i, rfr0: sum dfctrfrbC2, act0: sum dfctactionbC2, dfct0mn:avg statusbC2, dfct0sd:sdev statusbC2 by yr0:`year$date0, isclm0,outcome1 from samples1 where (0 < dfctbC2)

x00,: 0!select type0:`fC1, nday:days0[2], n:count i, rfr0: sum dfctrfrfC1, act0: sum dfctactionfC1, dfct0mn:avg statusfC1, dfct0sd:sdev statusfC1 by yr0:`year$date0, isclm0,outcome1 from samples1 where (0 < dfctfC1)

x00,: 0!select type0:`fC2, nday:days0[3], n:count i, rfr0: sum dfctrfrfC2, act0: sum dfctactionfC2, dfct0mn:avg statusfC2, dfct0sd:sdev statusfC2 by yr0:`year$date0, isclm0,outcome1 from samples1 where (0 < dfctfC2)


x00: `yr0`nday xdesc x00
x00

dfctsample0: x00
.csv.t2csv[`dfctsample0];

// And another of activity

dfctsample1: select sum statusbC1, sum dfctbC1, sum dfctrfrbC1, sum dfctinspctbC1, sum dfctactionbC1, avg dfctcatbC1, avg dfctriskbC1, sum prmtTbC1, sum prmtbC1, avg prmtwcatbC1, sum prmtddtbC1, avg prmtriskbC1, sum statusbC2, sum dfctbC2, sum dfctrfrbC2, sum dfctinspctbC2, sum dfctactionbC2, avg dfctcatbC2, avg dfctriskbC2, sum prmtTbC2, sum prmtbC2, avg prmtwcatbC2, sum prmtddtbC2, avg prmtriskbC2, sum statusfC1, sum dfctfC1, sum dfctrfrfC1, sum dfctinspctfC1, sum dfctactionfC1, avg dfctcatfC1, avg dfctriskfC1, sum prmtTfC1, sum prmtfC1, avg prmtwcatfC1, sum prmtddtfC1, avg prmtriskfC1, sum statusfC2, sum dfctfC2, sum dfctrfrfC2, sum dfctinspctfC2, sum dfctactionfC2, avg dfctcatfC2, sum dfctriskfC2, sum prmtTfC2, sum prmtfC2, avg prmtwcatfC2, sum prmtddtfC2, avg prmtriskfC2 by `month$date0 from samples1
.csv.t2csv[`dfctsample1]

.sys.exit[0]

\

/  Local Variables: 
/  mode:kdbp
/  minor-mode:q 
/  q-prog-args: "-p 5000 -c 200 120 -C 2000 2000 -load ../cache/csvdb hcc.q help.q -verbose -halt -quiet"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
