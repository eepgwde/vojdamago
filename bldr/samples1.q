// weaves
// @file samples1.q

// Using q/kdb+ for the db.

// Build a de-normalized set of samples.

// -- Key  against cwy

// For each type of file: the count by date

.samples.dts: 0!`dt xdesc select src:`enq, n:count i by dt:`date$enquirytime0 from enq1

.samples.dts,: 0!`dt xdesc select src:`clm, n:count 1 by dt:lossdate from clm1

.samples.dts,: 0!`dt xdesc select src:`dfct, n:count i by dt:`date$dt0 from dfct1

.samples.dts,: 0!`dt xdesc select src:`prmt, n:count i by dt:`date$idt0 from permit2

select count i by src from .samples.dts

.samples.dts1: a00: `mm0 xasc select count i by src, mm0:`month$dt from .samples.dts

.samples.dts2: select src by mm0 from .samples.dts1

.samples.dts3: select mm0 from .samples.dts2 where 4 = { count raze x } each src

.samples.dts0: (first .hcc.fdt2[;"01"] each value exec min mm0, max mm0 from .samples.dts3),(last .hcc.fdt2[;"31"] each value exec min mm0, max mm0 from .samples.dts3)

// Build enq2
// The key to cwy0 is direct. aid0 is just in case.
// Note, if you get trouble here (you cannot assign to enq2) you probably have a
// corrupted sym file in kdb 

enq2: select enq0, claim0:`, cwy0:`, aid0:`, date0:`date$enquirytime0, src0:`enq, isclm0:0b from enq1 where (`date$enquirytime0) within .samples.dts0

// enq1 only

// update ddate0: (`date$enq0.followupdate0) - date0 from `enq2;
// update ddate1: (`date$enq0.loggeddate0) - date0 from `enq2;

clm2: select enq0:`, claim0, cwy0:`, aid0:`, date0:lossdate, src0:`clm, isclm0:1b from clm1 where lossdate within .samples.dts0

ec:enq2, clm2

enq2:clm2: ()
delete enq2, clm2 from `.;

update smpl0:{ $[x[0] = `enq; `$string x[1]; `$string x[2]] } each flip (src0;enq0;claim0) from `ec;


update enq0:`enq1$enq0, claim0:`clm1$claim0, cwy0:`cwy0$cwy0 from `ec;

count ec
count distinct ec[;`smpl0]

ec: `smpl0 xkey `date0 xdesc ec

update ddate0: (`date$enq0.followupdate0) - date0 from `ec;
update ddate1: (`date$enq0.loggeddate0) - date0 from `ec;

update cwy0:enq0.cwy from `ec where src0 = `enq;

update cwy0:claim0.cwy from `ec where src0 = `clm;

// check
select count i by src0 from ec where null cwy0;

// ** Deletions
// Remove footway claims and add aid0 where known

delete from `ec where (src0 = `clm),(null cwy0),(not null claim0.fwy);

a01: select first aid0 by claim0 from clm1 where (claim0 in exec claim0 from ec where (src0 = `clm),(null cwy0)),(not null aid0)

ec: ec lj a01

// Remove all those records that don't have cwy0
delete from `ec where (null cwy0);

// enq is all pothole
// But not clm

delete from `ec where (src0 = `clm),(claim0.detailcause <> `Pothole);

// checks

select count i by claim0.outcome1 from ec

select sum claim0.cost0 by claim0.outcome1 from ec

// ** Building

// ** copy over some classifications from enq1

c1: `emethod1`priority`response`estatus0
f: .sch.cpfk[`ec;;`enq0]

f each c1;


// General things that I can add later for both enq and clm
// but will test here.
//
// Add the weather - we don't have any sunshine within our range. See later.
update month0: `month$date0 from `ec;
ec: ec lj weather1

update month00: (`month$date0) - 1 from `ec;

// Add in the previous month's weather
c0:cols weather1
c0: `${ x,"0" } each string c0
weather00: c0 xcol weather1
ec: ec lj weather00

// Add a simple integer key.
update id0:i from `ec;

// Add lsoa
// I've sorted on lsoa0 to match cwy first
// Join table
.tmp.lsoa: `cwy0 xcol `lsoa0 xasc 1!0!delete assetid from select from lsoa1 

ec: ec lj .tmp.lsoa

// * check
select count distinct cwy0, count i by lsoa0 from ec where not null cwy0

// * LSOA

// Add cars and pop1

a10: `smpl0 xasc ec

a10: (`lsoa xkey a10) lj cars1
a10: a10 lj delete ward from imd1
a10: a10 lj pop1

count cols a10

// Add rci1rag
ec: `smpl0 xkey a10

x0: `cwy0`month0 xkey `cwy0`month0 xcol rci1rag

ec: `rn xdesc ec lj x0

// IMPUTATION

c0: 8_cols ec
c0: c0 except `ddate0`ddate1

.hcc.nulls0[ec;c0]

// Try some lsoa from ward imputation

// * cars1
// Scale down the ward numbers by the nlsoa factor

x0: select count i by lsoa from ec where null ncars00
x0: x0 lj lsoa2ward

.impute.lsoa.cars1: distinct (0!x0)[;`lsoa]

x0: (`ward xkey x0) lj cars1w
c0: 1_cols cars1w
x1: select first nlsoa by ward from x0

// Use a dictionary and a global
.t.d0: .Q.V x0
{ .t.d0[x]: `int$.t.d0[x] % .t.d0[`nlsoa] } each c0;
.t.d0: flip .t.d0
// set columns
c1: (cols .t.d0) except c0
c2: c1, 1 _ cols cars1
.t.d0: c2 xcol .t.d0
x2: `lsoa xkey delete nlsoa, ward, x from .t.d0
ec: ec lj x2

c0: { `$ssr[x;"w";""] } each string c0

// Still 600 or so.
.hcc.nulls0[ec;c0]

// * imd1
// Average over the ward, much easier

x0: select count i by lsoa from ec where null imd
x0: x0 lj lsoa2ward
x0: delete x, nlsoa from `ward xkey x0
// store.
.impute.lsoa.imd1: distinct (0!x0)[;`lsoa]

x1: select `real$avg imd, `short$avg imdk, `short$avg wealthk by ward from imd1

ec: delete ward, nlsoa from ec lj `lsoa xkey x0 lj x1

// * pop1
// I didn't add "w" to the ward columns

x0: select count i by lsoa from ec where null tage00 
x0: x0 lj lsoa2ward
x0: delete x from `ward xkey x0
// store.
.impute.lsoa.pop1: distinct (0!x0)[;`lsoa]

x0: (`ward xkey x0) lj pop1w
c0: 1_cols pop1w
x1: select first nlsoa by ward from x0

// Use a dictionary and a global
.t.d0: .Q.V x0
{ .t.d0[x]: `int$.t.d0[x] % .t.d0[`nlsoa] } each c0;
.t.d0: flip .t.d0

x2: `lsoa xkey delete nlsoa, ward from .t.d0
ec: ec lj x2

// Still 600 
.hcc.nulls0[ec;c0]


// * rci1rag
// copy left to right if no right and vice-versa
// either set a default or impute from similar roads or from the root road (aid0)

update imp0:` from `ec;
update imp0:`cwy by cwy0 from `ec where null cwy0;
update imp0:`ragnull by cwy0 from `ec where (null imp0), (null rn), (null ln);
update imp0:`ragr by cwy0 from `ec where (null imp0), (null rn), (not null ln);
update imp0:`ragl by cwy0 from `ec where (null imp0), (null ln), (not null rn);

ec: `imp0 xdesc ec

// weird - the right is always the one that is missing

update rn:ln, rreds:lreds, rambers:lambers, rgreens:lgreens from `ec where imp0 = `ragr;

// ** check
select count i by imp0 from ec

// Add some cwy0 information

update aid0:cwy0.aid00 from `ec;

a00: select n:count i by aid0 from ec

kcwy0: raze value flip key a00

a01: select sum distance, avg width, distinct hierarchy, distinct roadclass, distinct roadtypehw, distinct urbanrural, distinct surftype by aid0:aid00 from cwy0 where aid00 in kcwy0

a01: `distance xdesc a01

// record the keys 
.samples.keys: select first smpl0 by id0 from ec

ec: `smpl0 xkey delete id0, lsoa0, imp0 from ec

// Check for nulls in columns
// Ignore first 8 cols and a couple of specials
c0: 8_cols ec
c0: c0 except `ddate0`ddate1

.hcc.nulls0[ec;c0]

// A lot of missing weather, because nothing for that date. Also no date info.

update yyyy:`int$`year$date0, mm:`int$`mm$date0 from `ec where null yyyy;

update ssn:.hcc.ssny2[mm] from `ec where null ssn;

.hcc.nulls0[ec;c0]

// Missing sun measure from weather - use the average.
// Change data type. Calculate and average and use a lookup rather than a join.
sun1: select `real$avg sun by mm from weather1 where not null sun
update sun:sun1[([]mm);`sun] from `ec where null sun;
update sun0:sun1[([]mm:mm0);`sun] from `ec where null sun0;
sun1:(); delete sun1 from `.;

af1: select `short$floor avg af by mm from weather1 where not null af
update af:af1[([]mm);`af] from `ec where null af;
update af0:af1[([]mm:mm0);`af] from `ec where null af0;
af1:(); delete af1 from `.;

select count i by rain, src0 from ec where null rain

rain1: select `real$avg rain by mm from weather1 where not null rain
update rain:rain1[([]mm);`rain] from `ec where null rain;
update rain0:rain1[([]mm:mm0);`rain] from `ec where null rain0;
rain1:(); delete rain1 from `.;

select count i by tmax, src0 from ec where null tmax

tmax1: select `real$avg tmax by mm from weather1 where not null tmax
update tmax:tmax1[([]mm);`tmax] from `ec where null tmax;
update tmax0:tmax1[([]mm:mm0);`tmax] from `ec where null tmax0;
tmax1:(); delete tmax1 from `.;

tmin1: select `real$avg tmin by mm from weather1 where not null tmin
update tmin:tmin1[([]mm);`tmin] from `ec where null tmin;
update tmin0:tmin1[([]mm:mm0);`tmin] from `ec where null tmin0;
tmin1:(); delete tmin1 from `.;

// *** summary

.hcc.nulls0[ec;c0]

// LSOA and cars data missing for about 600. null lsoa

// Red-Amber-Green: 86k missing. null ln

// ** cwy0 - copy over some values from cwy0

f: .sch.cpfk[`ec;;`cwy0]

f each `distance`width`area`isdist`pri`iscls`pri2`isslip`isshared`isdual`issingle`isoneway`isround`lanes`lanes2`rh0`mtraffic`spdlimit`surftype`siteid;

update isurban:0b from `ec;
update isurban:1b from `ec where cwy0.urbanrural = `Urban;

c0: 8_cols ec
c0: c0 except `ddate0`ddate1

.hcc.nulls0[ec;c0]

update surftype:`OTHR from `ec where null surftype;

// end: IMPUTATION

// And there are aggregates for aid00

c0: cols cwy0
idx0: { x like "a0X*" } each string c0
c1: `nassets, c0 where idx0
f: .sch.cpfk[`ec;;`cwy0]

f each c1;

// Add type of claim

update outcome1:`noaction from `ec;
update outcome1:`repudiated from `ec where (src0 = `clm), claim0.outcome1 <> `Settled;
update outcome1:`settled from `ec where (src0 = `clm), claim0.outcome1 = `Settled;

// Isolation is a marker if the road is not part of a larger route.
// If a road is globally isolated then it is isolated
.sample.isolation: select count distinct cwy0 by a0Xisisolated from select cwy0, a0Xisisolated from ec

update mtraffic0: 0.5 xbar { .sch.logbin[x;1] } each mtraffic by i from `ec ;
update distance0: 0.5 xbar { .sch.logbin[x;1] } each distance by i from `ec ;

samples1: ec

// ** PoI Data

`.poi set get `:./wspoi;

// These are effectively cwy descriptions

.poi.join: { [tbl;t0] t0: `cwy0 xcol t0; c0: first (cols t0) except `cwy0; tbl: tbl lj t0; .hcc.zero0[tbl;c0] }

.tmp.tbl: samples1
{ [x] t0: .tmp.tbl: .poi.join[.tmp.tbl;x]; } each .poi.tables0 ;

samples1: .tmp.tbl

// Some more imputing.

c0: 8_cols samples1
c0: c0 except `ddate0`ddate1

.impute.nulls0: .hcc.nulls0[samples1;c0]

// Clean up

a00: a01: a10: x0: x1: x2: ()
delete a00, a01, a10, x0, x1, x2 from `.;

// Only if the imputes1 table exists do this
// note: you need to use R to impute the smpl0 enquiry stata
// and to load the new set, you have to overwrite the base set in imputes1
// using install-local in ldr.mk

samples1: $[any { x like "imputes1" } each string tables `.; 1!(0!samples1) lj imputes1; samples1]

// These are the imputed records
select from samples1 where smpl0 in raze value flip key imputes1

// Add enquiry history
// I'm going to re-use (in advance) the .samples.dfcts and .samples.prmts dictionaries.

.samples.dfcts:()!()
.samples.prmts:()!()

// Set up some history periods: look back- and for- ward, call them C1 and C2.

.samples.cats: (30;-30+3*30)
.samples.catsn: ("C1"; "C2")

x0: ([] cat0s: .samples.cats; name0s: .samples.catsn; tag0s:(count .samples.cats)#enlist "b")

x1: update cat0s: neg cat0s, tag0s:"f"  from x0

x0: update tag1s: { (enlist x[1]), x[0] } each flip (name0s;tag0s) by i from x0,x1
.samples.catns: (x0[;`cat0s])!x0[;`tag1s]


.samples.cat1b: ((first .samples.cats); 0)
.samples.cat2b: ((last .samples.cats); first .samples.cat1b)

.samples.cat1f: ((neg first .samples.cats); 0)
.samples.cat2f: ((neg last .samples.cats); first .samples.cat1b)

.samples.catx0: (.samples.cat1b;.samples.cat1f;.samples.cat2b;.samples.cat2f)

catx0: .samples.catx0

/

// Testing

.tmp.n0: .samples.cat1b
.sys.qreloader enlist "samples1e.q"
count .samples.dfct

.samples.dfcts[first .tmp.n0]: .samples.dfct

.sys.qreloader enlist "samples1f.q"
count .samples.prmt
.samples.prmts[first .tmp.n0]: .samples.prmt

\


// smpls and ssmpls: Iterate over the history windows
// re-use the .samples.dfcts and .samples.prmts dictionaries
// smpls is for each asset; ssmpls for each site-id for each asset.

{ .tmp.n0: x; .sys.qreloader enlist "samples1e.q"; .samples.dfcts[first .tmp.n0]: .samples.dfct } each catx0

{ .tmp.n0: x; .sys.qreloader enlist "samples1f.q"; .samples.prmts[first .tmp.n0]: .samples.prmt } each catx0

/

// Test - check .tmp.samples1

.tmp.samples1: samples1
.tmp.n0: first .samples.cat1b

.sys.qreloader enlist "samples1g.q"

\

// Join the smpls and ssmpls into the sample set.
// Use a global, note the double colon.

.tmp.samples1:: samples1
{ .tmp.n0: x; .sys.qreloader enlist "samples1g.q"; } each catx0
samples1: .tmp.samples1
delete samples1 from `.tmp;


// TODO - quick kludge
// Bit of a problem with this. The site metric includes the asset and if it is the only
// asset, then the ssmpl is the same.
// siteid includes the asset so site to null values

update ssmplbC1:0j, ssmplwtbC1:0f, ssmplriskbC1:0f by i from `samples1 where (ssmplbC1 = smplbC1);
update ssmplfC1:0j, ssmplwtfC1:0f, ssmplriskfC1:0f by i from `samples1 where (ssmplfC1 = smplfC1);

update ssmplbC2:0j, ssmplwtbC2:0f, ssmplriskbC2:0f by i from `samples1 where (ssmplbC2 = smplbC2);
update ssmplfC2:0j, ssmplwtfC2:0f, ssmplriskfC2:0f by i from `samples1 where (ssmplfC2 = smplfC2);

// And impute

.samples.smplimpute: (0j; 0f; 0.01f)

/

// Test
.tmp.n0: first .samples.cat1b
samples1: .hcc.impute0[samples1;cols value 2!.samples.dfcts[.tmp.n0]; .samples.smplimpute ]

\

.tmp.samples1:: samples1
{ n0: first x; .tmp.samples1: .hcc.impute0[.tmp.samples1;cols value 2!.samples.dfcts[n0]; .samples.smplimpute ] } each catx0;
samples1: .tmp.samples1

// End: smpls and ssmpls

// Install the defects histories

// cleanup
.samples.dfcts: samples.prmts: .samples.dfct: .samples.prmt: ()

.samples.dfcts:()!()
.samples.prmts:()!()

/

// Test

.tmp.n0: .samples.cat1b

.sys.qreloader enlist "samples1a.q"
count .samples.dfct

.samples.dfcts[first .tmp.n0]: .samples.dfct

.sys.qreloader enlist "samples1b.q"
count .samples.prmt
.samples.prmts[first .tmp.n0]: .samples.prmt

\

{ .tmp.n0: x; .sys.qreloader enlist "samples1a.q"; .samples.dfcts[first .tmp.n0]: .samples.dfct } each catx0

{ .tmp.n0: x; .sys.qreloader enlist "samples1b.q"; .samples.prmts[first .tmp.n0]: .samples.prmt } each catx0

// Do some aggregation and imputing
// store the fields changed, 
.samples.dfctimputes: ()!()

// Load defects status
`.dfct set get `:./wsdfct;

/

// Test - TODO: missing status2

.tmp.n0: first .samples.cat1b

.tmp.samples1:: samples1

.sys.qreloader enlist "samples1c.q"

\

.tmp.samples1:: samples1
{ .tmp.n0: x; .sys.qreloader enlist "samples1c.q"; } each catx0
samples1: .tmp.samples1

delete samples1 from `.tmp;

// cleanup
.samples.dfcts: samples.prmts: .samples.dfct: .samples.prmt: ()
delete dfcts, prmts, dfct, prmt from `.samples ;

count samples1

// Write the samples out now with variants and reports.
// I do final testing in here too.
.sys.qreloader enlist "samples1d.q"

// Write to disk

save `:./samples1

// Save the workspace for reference.

`:./wssamples set get `.samples
`:./wsimpute set get `.impute

// And load it again like this.
// `.impute set get `:./wsimpute

.sys.exit[0]

/  Local Variables: 
/  mode:kdbp
/  minor-mode:q
/  q-prog-args: "-p 5000 -c 200 120 -C 2000 2000 -load ../cache/csvdb help.q -verbose -halt -quiet"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
