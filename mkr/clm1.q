// weaves
// @file clm1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key  against cwy

// For each date, the count
.clm.dts: `dt xdesc select n:count i by dt:`date$lossdate0 from clm

// New table, with locator in xref0
clm1: value select by i from clm

// bad claimnumber keys

delete from `clm1 where null claimnumber;

t0: select n0:first { sum " " = x } each string claimnumber by claimnumber from clm1
t1: select claimnumber from t0 where 0 < n0

delete from `clm1 where claimnumber in (0!t1)[;`claimnumber];

// bad record(s)

delete from `clm1 where (`year$lossdate0) = 1995;

// clean up the roadidfeatureid

// number of sub-strings


update said: { " " vs x } each roadidfeatureid from `clm1;

update n1:count each said by i from `clm1;

// missing
update xref0:` from `clm1;

update xref0: `single from `clm1 where (null xref0),(1 = n1);

// add key derivatives
update aid:`, aid0:`, aid00:` from `clm1;

update said0: count raze first said by i from `clm1 where `single = xref0 ;

// very useful
update said1: { "/" vs x } each roadidfeatureid from `clm1;

update xref0:`null by i from `clm1 where (`single = xref0),0 = said0 ;

update aid:`$upper first raze said by i from `clm1 where (`single = xref0),(1 = n1);

update xref0:`multi, aid:`$first raze said by i from `clm1 where (null xref0),(2 <= n1);

update said2: { "/" vs x } each string aid by i from `clm1;

update n2:count each said2 by i from `clm1;


select aid0: `$upper first raze said2 by i from `clm1 where (n2 = 1),(xref0 in `single`multi)

// Put it back together
select aid, aid0: `$upper "/" sv 2# raze said1 by i from `clm1 where (2 < n2),(xref0 in `single`multi)

update aid0: `$upper first raze said1 by i from `clm1 where (xref0 in `single`multi);
update aid0: `$upper "/" sv 2# raze said1 by i from `clm1 where (2 < n2),(xref0 in `single`multi);

update aid00: `$upper first raze said2 by i from `clm1 where xref0 in `single`multi;

// Key to cwy0

clm3: select from clm1 where xref0 in `single`multi

// clm3: delete n1, said, said2, n2 from clm1

// * checks on classes

select count claimnumber by xref0 from clm1

clm3: select by i from clm1 where null xref0

// * keying validate with lookups

kftre: select type0 by aid from ftre
kftre0: select type0 by aid0 from ftre
kftre00: select type0 by aid00 from ftre

// add the lookups on aid
update xref1: kftre[([]aid);`type0] from `clm1;

// find the claim numbers of the matches
// check this select - null in all xref1
t0:value select first claimnumber, roadidfeatureid, first aid, null0:all raze null xref1, first xref0, xref1 by i from clm1
t0

// mark the failures				      
t1: ungroup value select claimnumber, null0 by i from t0 where xref0 in `single`multi
t1

t2: select claimnumber, null0 from t1 where null0
t2

// and update on the key				    
// trap ISTP/2008/0072 TP/2008/0047
// reset aid to `

update aid:` by i from `clm1 where claimnumber in (0!t2)[;`claimnumber];

select xref0, roadidfeatureid from clm1 where (null aid), xref0 in `single`multi

// * aid0 - trap S56

clm1: update xref1: kftre0[([]aid0);`type0] from clm1

// find the claim numbers of the matches
// check this select - null in all xref1
t0:value select first claimnumber, roadidfeatureid, first aid0, null0:all raze null xref1, first xref0, xref1 by i from clm1
t0

// mark the failures				      
t1: ungroup value select claimnumber, null0 by i from t0 where xref0 in `single`multi
t1

t2: select claimnumber, null0 from t1 where null0
t2

// and update on the key				    
// trap ISTP/2008/0072 TP/2008/0047
// reset aid0 to `

update aid0:` by i from `clm1 where claimnumber in (0!t2)[;`claimnumber];
select xref0, roadidfeatureid, xref1 from clm1 where (null aid0), xref0 in `single`multi

// * aid00

clm1: update xref1: kftre00[([]aid00);`type0] from clm1

// find the claim numbers of the matches
// check this select - null in all xref1
t0:value select first claimnumber, roadidfeatureid, first aid00, null0:all raze null xref1, first xref0, xref1 by i from clm1
t0

// mark the failures				      
t1: ungroup value select claimnumber, null0 by i from t0 where xref0 in `single`multi
t1

t2: select claimnumber, null0 from t1 where null0
t2

// and update on the key				    
// trap ISTP/2008/0072 TP/2008/0047
// reset aid00 to `

update aid00:` by i from `clm1 where claimnumber in (0!t2)[;`claimnumber];
select xref0, roadidfeatureid, xref1 from clm1 where (null aid00), xref0 in `single`multi

// cwy0: keying again: clm has both cwy and fwy

kcwy: raze value flip key cwy0
kclm: distinct clm1[;`aid]

.clm.badkeys: kclm except kcwy

update cwy:`cwy0$aid from `clm1 where not aid in .clm.badkeys;

kfwy: raze value flip key fwy0
kclm: .clm.badkeys

.clm.badkeys1: kclm except kfwy

update fwy:`fwy0$aid from `clm1 where aid in .clm.badkeys;

// * check

select sum not null aid, sum not null aid0, sum not null aid00 by xref0 from clm1

select sum not null aid, sum not null aid0, sum not null aid00 by xref0, inspectionfrequency from clm1

// * Data fixing

select by inspectionfrequency from select distinct inspectionfrequency, if0: `$lower string inspectionfrequency from clm1

update if0: `$lower string inspectionfrequency from `clm1;

select sum not null aid, sum not null aid0, sum not null aid00 by xref0, if0 from clm1

select count i by coveragegroup from clm1
select count i by covertype from clm1

select count i by risktype from clm1
select count i by cause from clm1

select count i by detailcause from clm1

// Trivial
update detailcause:`Animals by i from `clm1 where detailcause = `$"Animals/Pests";

// TODO
select count i by detailcause from clm1

// Simplification

clm3: select from clm1 where not null lastinspectiondatebeforeincident

// TODO
// Some extra classification, but bulk are null outcome
select count i by outcome from clm1


// TODO
// This could decide fwy or cwy
// Also new class `tree
// Highway Incident - Pedestrian - is mostly accidents, but "Branches" is tree
// damage
select count i by cause from clm1

update n0: count raze customerenquiryreference by i from `clm1;

clm3: select from clm1 where 0 < n0

// FYI: is dominated
select count i by cause from clm1

// FYI: is dominated
select count i by covertype from clm1

// FYI: is dominated
select count i by status from clm1

// FYI: dominated by null and next-to-no use
select count i by sitecode from clm1

// FYI

clm3: `cost xdesc select n:count i, cost:sum incurredtotal by cause, detailcause, year0:`year$lossdate from clm1

// Drop intermediate fields and re-order columns

select count i by status from clm1
select count i by risktype from clm1

// TODO simplify
select count i by locationlevelf from clm1

// * Structuring

// ** Schema changes:
// best to use a new table with a key back to my derived table
// keep both.

// key and rename
clm1: `claimnumber xkey clm1
clm1: `claim0 xcol clm1

// Important fields

clm2: select `clm1$claim0, lossdate, xref0, aid, aid0, aid00, inspect1:if0 from clm1

update inspect0:claim0.lastinspectiondatebeforeincident, yy0:`year$lossdate, month0:`month$lossdate, mm0:`mm$lossdate from `clm2;

delete n0, xref1, said2, n2, said1, said0, n1, said, lossdate0  from `clm1;

// ** Set some numerics to null and aggregate to a single column.

update paidtotal:`real$0N from `clm1 where 0 >= paidtotal ;
update osreservetotal:`real$0N from `clm1 where 0 >= osreservetotal ;
update incurredtotal:`real$0N from `clm1 where 0 >= incurredtotal ;

update cost0: max [paidtotal,osreservetotal,incurredtotal] by i from `clm1;
update cost0: `real$0N from `clm1 where cost0 = -0w;

select cost0, paidtotal,osreservetotal,incurredtotal from clm1

a00: select outcome0: first string distinct outcome by outcome from clm1

a01: update outcome1: first { "-" vs x } each outcome0 by i from a00

a01: update outcome1: `$first { " " vs x } each outcome1 by i from a01

a01: update outcome1:`Misc from a01 where outcome1 in `No`Not`Incident`Paid`Ringway;
a01: update outcome1:`Settled from a01 where outcome1 = `Settlement;

clm1: clm1 lj delete outcome0 from a01

select count i by outcome1 from clm1

update outcome1:`Settled from `clm1 where not null cost0;

select count i by status, outcome1 from clm1

update outcome1:`Repudiated from `clm1 where (null outcome1),status = `Final;
update outcome1:`Pending from `clm1 where (null outcome1),status = `Open;

// Check the assetid to USRN mapping




// * Ad-hoc analyis

clm3:select month0, cost, deltas cost from `cost xdesc select cost: sum claim0.incurredtotal by month0:`month$lossdate from clm2


// * Inspection

clm3: select n0:count i, costm:avg claim0.incurredtotal, cost:sum claim0.incurredtotal, sdcost: sdev claim0.incurredtotal by yy0 from clm2
clm3: update risk0: sdcost % costm from clm3

clm3: update costo: 1+i from `cost xdesc clm3
clm3: update n0o: 1+i from `n0 xdesc clm3

// Typical year metric from rankings
clm3: update costt: abs costo - n0o by i from clm3

clm3: `cost xdesc clm3

.clm.years: clm3

.clm.cor: flip select corr0: cor[costo; n0o] from clm3 
.clm.corx: flip select corr0: cor[costo; n0o] from clm3 where (1 < costo)

clm3: `incurredtotal xdesc select sum claim0.paidtotal, sum claim0.incurredtotal by claim0.detailcause, claim0.cause from clm2

clm3:select n0, month0, cost, deltas cost from `cost xdesc select n0:count i, cost: sum claim0.incurredtotal by month0:`month$lossdate from clm2

// * summary

.clm.summary: select count i by xref0 from clm2
.clm.summary

select sum not null aid, sum not null aid0, sum not null aid00 by xref0 from clm2

// Check if we have a sitecode

select count i by sitecode from clm1 where null aid

// This is fiddly processing. Conditional optional. Only adds a few extra records.

.sys.qreloader enlist "clm1a.q"

select count i by siteid from clm1

// Do we have valid siteid, if not overwrite it.

t0: `siteid xkey select siteid, siteid0 from .sch.keyembed[usrn2aid;`siteid;`siteid0]

update siteid: t0[([]siteid);`siteid0] from `clm1;

update siteid: `usrn2aid$siteid from `clm1;

// Adjacency joins around permits

`.permit set get `:./wspermit;

// Adjacency joins

a00: 0!`siteid`dt0 xasc select from .permit.risk 
a00: update dtprmt:dt0 from a00

a01: ungroup select dtloss:lossdate by claim0, siteid, dt0:lossdate from clm1 where (not null siteid),(2012.01.01 < lossdate)
a01: `siteid`dt0 xasc a01

a02: aj[`siteid`dt0;a00;a01];

// The same claim may be fixed by any of the following permits
.clm.prmt.response: a02: delete dt0 from `siteid`dt0 xasc a02;

a03: `claim0 xkey ungroup select cost0, outcome1 by claim0 from clm1

.clm.prmt.response: a03: .clm.prmt.response lj a03

// * end

a02: aj[`siteid`dt0;a01;a00]

a02: delete dt0 from `siteid`dt0 xasc a02

.clm.prmt.cause: a02

// Write and exit

save `:./clm1

// Save the error workspace for reference.

`:./wsclm set get `.clm

// And load it again like this.
// `.clm set get `:./csvdb/wsclm

.sys.exit[0]

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
