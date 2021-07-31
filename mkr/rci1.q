// weaves
// @file rci1.q

// Using q/kdb+ for the db.

// Some inspection and correction. This should be run before the others.

// -- Append rcib to rcia and key rci against cwy

// For each date, the count
.rci.dtsa: `dt xdesc select n:count i by dt:`date$surveyfeatend0 from rcia
.rci.dtsb: `dt xdesc select n:count i by dt:`date$surveyfeatend0 from rcib

// Counts by asset_id and date.
.rci.n0: 0!select n:count i  by assetid:centralassetid, dt: `date$surveyfeatend0 from rcia

// Just a temp join
rci: (value select by i from rcia),(value select by i from rcib)

// -- Prototyping

// But assetid does not match with that in rci.			  

// rci: See if we can find the A41

rci1: update acode:`cwy0$acode from update acode: `${ 4 _ x } each string featureid from select from rci where { 0 < count x ss "A41" } each string featureid

x0: (string 10#rci[;`featureid])
x0,: (string -10#rci[;`featureid])

{ 0 < count x ss "A41" } each x0

// -- Find bad records

// This direct cast doesn't work. Some miscoding.

// rci1: update acode:`cwy0$acode from update acode: `${ 4 _ x } each string featureid from rci

// Get just the featureid/acode from rci and cwy0 and find the exceptions.

rci1: raze value exec acode: distinct `${ 4 _ x } each string featureid from rci

( count rci1; count key cwy0 )

cwy1: raze (value flip key cwy0)

.rci.bad0: rci1 except cwy1

// -- rci1: Remove bad records and add foreign key.

rci1: update acode: `${ 4 _ x } each string featureid from rci
rci1: delete from rci1 where acode in .rci.bad0

rci1: update acode:`cwy0$acode from rci1

// rci1: simplify the useful attributes

.rci.xspcode: select n:count i by xspcode from rci1

// backup
.rci.rci1: rci1

// keying
// Tricky we have to sub-group, I use the virtual column as a key
// sort by road, left/right, distance
x0: `acode`xspcode`surveyobsstart xasc rci1
// add some keys
update idx0:1, i0:i from `x0;
// easier to check
x0: `acode`xspcode`i0 xcols x0
// sum by group
x1: `acode`xspcode`i0 xkey ungroup select i0:i, sums idx0 by acode, xspcode from x0
x2: x0 lj x1
x2: delete i0 from `acode`xspcode`idx0 xkey x2

// write back to main table
rci1: x2

x0:x1:x2:x3:()
delete x0,x1,x2,x3 from `.;

// simplify surveyobsnotes

x0: select desc0: first string surveyobsnotes by acode,xspcode,idx0 from rci1

x1: select desc1:`$lower first { first ":" vs x } each desc0 by acode,xspcode,idx0 from x0

rci1: rci1 lj x1

rci1: 3!(`acode`xspcode`idx0`desc1`surveyobsvalue`surveyobsnotes) xcols 0!rci1

// rci1rag
// Red-amber-green coverage by left and right lanes

// Coverage is sparse - choose the latest and make a red-amber-green table
y1: 0!select count distinct acode by month0:`month$`date$surveyfeatend0 from rci1

.rci.ragperiod: first exec month0 from y1 where acode = max acode;

x0: select n:count i, reds:sum (`red = desc1), ambers:sum (`amber = desc1), greens:sum (`green = desc1) by acode, xspcode from rci1 where .rci.ragperiod <= `month$`date$surveyfeatend;

// No percentages
// y2: update reds % n, ambers % n, greens % n by acode, xspcode from x0
y2: x0

ragl: delete xspcode from select by acode, xspcode from y2 where xspcode = `CL1;
c0: .sch.rename[cols ragl; 1; "l"]
ragl: c0 xcol ragl
ragl: `acode xkey ragl

ragr: delete xspcode from select by acode, xspcode from y2 where xspcode = `CR1;
c0: .sch.rename[cols ragr; 1; "r"]
ragr: c0 xcol ragr
ragr: `acode xkey ragr

rag: 0!ragl

kn: distinct (0!ragl)[;`acode],(0!ragr)[;`acode]

t0: ([acode: kn] x: til count kn)

t1: (0!t0) lj ragl
t1: delete x from t1 lj ragr

rci1rag: `featureid xcol `acode xkey t1

update month0:`month$.rci.ragperiod from `rci1rag;

rci1rag: `featureid`month0 xkey rci1rag

// and retype for imputation

x0: rci1rag
c0: 2 _ cols x0

// One day I'll find out the q way of doing this.
.t.tbl:x0
{ [x] .t.tbl: .sch.a2retype[.t.tbl;x;"f"] } each c0;

rci1rag: .t.tbl

// and six months of rci

.t.tbl: rci1rag
{ .t.tbl,: update month0:x from .t.tbl } each .rci.ragperiod + til 6 ;
rci1rag: .t.tbl

delete tbl from `.t;
delete x0 from `.;

x0: cwy0 lj 1!0!rci1rag

.rci.rci1ragr: exec count distinct featureid from x0 where not null rn
.rci.rci1ragl: exec count distinct featureid from x0 where not null ln

// Write these two new keyed tables as files in the directory.

save `:./rci1
save `:./rci1rag

// Save the error workspace for reference.

`:./wsrci set get `.rci

// and retrieve it like this
// `.rci set get `:./wsrci

.sys.exit[0]

\

/  Local Variables: 
/  mode:kdbp-mode
/  minor-mode:q-mode
/  q-prog-args: "-p 5000 -c 200 120 -C 2000 2000 -load ../cache/csvdb help.q -verbose -halt -quiet"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
