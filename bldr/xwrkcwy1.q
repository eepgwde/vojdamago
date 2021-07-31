// weaves
// @file xwrkcwy1.q

// Assets to defects

wrkcwy1: value select by i from wrk1

// Treat assets like trades and quotes like works
// find closest quote to trade

// some re-classifying - use wt0 - worktype0
`n xdesc select n:count i by worktype from wrkcwy1
update wt0:` from `wrkcwy1;
update wt0:`inlay2 from `wrkcwy1 where worktype in `inlay`surfacing`surf;
update wt0:`dress2 from `wrkcwy1 where (null wt0), worktype in `dress`treat`recon ;
update wt0:`micro2 from `wrkcwy1 where (null wt0), worktype in `micro`overlay ;
update wt0:`patch2 from `wrkcwy1 where (null wt0), worktype in `patch ;

wrk2: `cwy0`date0 xasc select wrkid:i, wrks:count i, wrkdt0:first date0 by cwy0, date0, wt0 from wrkcwy1 where not null wt0

worktypes0: `n xdesc select n:count i by wt0, worktype from wrkcwy1 where not null wt0
.csv.t2csv[`worktypes0]

// For dfctcwy1

select distinct status i by ntype1, ntype3 from dfctcwy1

// Looking backward: defects are fixed by works, defects indicate last works are failing


// Annual activity by asset
// Drop anything not worked on, drop anything superceded by jobs

dfctcwy2: `cwy0`date0 xasc select dfcts:count i, dfctdt0:last date0 by cwy0, date0 from dfctcwy1 where (status = `$"Action Required"), stscode <> 120

// TODO Bathtub fault curve within 30 days of wrk?

// Assign a defect to be specific to its worktype.

wrk2s: `cwy0`wrkdt0 xasc ungroup select by wrkid from wrk2 
// wrk2s: `cwy0`wrkdt0 xasc select by cwy0, date0, wt0 from wrk2 
wrk2s: update wrkdt1: next wrkdt0 by cwy0 from wrk2s
wrk2s: update wrkdt1:`date$0w from wrk2s where null wrkdt1

// TODO
// Should I? add a default defect on the first day for all cwy0. Then a lot more records will have
// ddays1?

// Day after the work, add a defect.

count dfctcwy2

dfctcwy00: select cwy0, dfctdt0:date0+1 from wrk2

x1: { x0: (x[`cwy0];x[`dfctdt0];0j;x[`dfctdt0]); x0 } each 0!dfctcwy00 ;

{ upsert[y;x] }[;`dfctcwy2] each x1 ;

dfctcwy2: `dfctdt0 xasc dfctcwy2

// Over 10k of records
count dfctcwy2

// Add a blank and add the worktype the defect is about.
update wt0:` from `dfctcwy2 ; 
{ update wrkid:x[`wrkid], wrkdt0:x[`wrkdt0], wt0: x[`wt0] from y where (cwy0 in x[`cwy0]), dfctdt0 within (x[`wrkdt0];x[`wrkdt1]) }[;`dfctcwy2] each 0!wrk2s ;

// Disregard defects not belonging to a work
delete from `dfctcwy2 where null wrkid ;

select count i by wt0 from dfctcwy2

count (exec distinct cwy0 from dfctcwy2 where null wrkid) except (exec distinct cwy0 from wrk2)

// as-of join by cwy worktype and date
dfctcwy2: 0!dfctcwy2
wrk2: 0!wrk2

select count i, count dfctdt0 by wrkid from dfctcwy2

// s1s: aj[`cwy0`wt0`date0;dfctcwy2;wrk2]
// s1s: delete from s1s where null wt0

// Overwrite this now, have its information
// wrkcwy1: dfctcwy2 lj `cwy0`dfctdt0`wt0 xkey s1s

wrkcwy1: dfctcwy2

update days0: dfctdt0 - wrkdt0 from `wrkcwy1 ;

// * More metrics

select count i, avg days0, sdev days0 by wt0 from wrkcwy1

f: .sch.cpfk[`wrkcwy1;;`cwy0]

f each `distance`width`area`isdist`pri`iscls`pri2`isslip`isshared`isdual`issingle`isoneway`isround`lanes`lanes2`rh0`mtraffic`spdlimit`surftype`siteid ;

wrkcwy1: wrkcwy1 lj select by cwy0 from delete siteid from cwy2

// Add a fake date for now for the weather
update dfctdt0:.z.D from `wrkcwy1 where null dfctdt0 ;

// add some weather
// weather metrics up to time of defect

mswthr: select count i by `month$wrkdt0, `month$dfctdt0 from wrkcwy1
update dfctdt0:`month$.z.D from `mswthr where null dfctdt0 ;

ms0: asc raze value exec `month$min dfctdt0, `month$max dfctdt0 from mswthr

// Final look-up with be like this
// Temperature last month: tmin0
// last temp delta: dtmin0
// average: since works, or
// average: last 10 years

update dtmin:deltas tmin from `month0 xasc `weather1 ;

// some testing

.hcc.weather2[(2009.01m;2010.10m);`weather1;120]

// select { 0N!x; .hcc.weather2[x;y] }[;`weather1] each flip (wrkdt0;dfctdt0) from mswthr

select { .hcc.weather2[x;y;10*12] }[;`weather1] each flip (wrkdt0;dfctdt0) by i from 10#mswthr


select tmin0: weather1[([]month0:(`month$dfctdt0) - 1);`tmin], dtmin0: weather1[([]month0:`month$dfctdt0);`dtmin], tmin:{ .hcc.weather2[x;y;10*12] }[;`weather1] each flip (`month$wrkdt0;(`month$dfctdt0)-1) by i from `wrkcwy1 

// Finally, update the main table
update tmin0: weather1[([]month0:(`month$dfctdt0) - 1);`tmin], dtmin0: weather1[([]month0:`month$dfctdt0);`dtmin], tmin:{ .hcc.weather2[x;y;10*12] }[;`weather1] each flip (`month$wrkdt0;`month$dfctdt0) by i from `wrkcwy1 ;


// Leave the date in for now.
// update dfctdt0:`date$0N from `wrkcwy1 where dfctdt0 = .z.D ;

// Some bad records
delete from `wrkcwy1 where or[null mtraffic;null surftype] ;

// Check what is left

count wrkcwy1

count select from wrkcwy1 where null tmin

count select from wrkcwy1 where null wrkdt0

count select from wrkcwy1 where null dfctdt0

// Add some imputed state

.wrkcwy.minwrkdt0: first 0!`wrkdt0 xasc select min wrkdt0 by wt0 from wrkcwy1 where not null wt0

update wrks:1, wrkdt0: .wrkcwy.minwrkdt0[`wrkdt0], wt0: .wrkcwy.minwrkdt0[`wt0], impute1:`wrkdt0, dfctdt0:.z.D from `wrkcwy1 where null wt0 ;

update days0:dfctdt0 - wrkdt0, dfcts:1 from `wrkcwy1 ;

// Add a wear metric.

// mtraffic determines the lifetime
// In any month, the road performance has degraded to x% from it's last 100% reset
// a major work - resurface/dress etc.

select count i by yrs:(365 xbar days0), { .sch.logbin[x;1] } each mtraffic from wrkcwy1

// too compute intensive to repeatedly logbin the mtraffic
// make a look-up table for its wear
x0: select mtrf0:`float$0N by mtraffic from cwy0
update mtrf0:`float${ .sch.logbin[x;1] } each mtraffic by i from `x0 ;
delete from `x0 where (null mtraffic)|(null mtrf0) ;

wrkcwy1: wrkcwy1 lj x0

// Get a reasonable lifetime, take the longest average by model traffic. Add a bit of an sdev.
.wrkcwy.sdev0: 2.0f
.wrkcwy.lives: select by wt0 from 0!`days0 xasc select n:count i, avg days0 + .wrkcwy.sdev0 * sdev days0 by wt0, mtrf0 from wrkcwy1 where (not null days0),(not null mtrf0)
.wrkcwy.lives

show .wrkcwy.lives

.wrkcwy.mtrf0: raze value exec min mtrf0, max mtrf0 from wrkcwy1

// Assume the busiest road is 1 and decays in lifetime.
// All less busy roads are mtrf0/max mtrf0 and last longer (less than full wear)
update mtrf1: mtrf0 % max mtrf0 from `wrkcwy1 ;

// use a log wear function
ld0: 1f
// ld0 <= 1; ld0 < 1 has a longer lifetime than ld0 = 1
// avoid the zero at the end of the series by doubling the last.
.f.wear0: { [ld0;lifetime] ld0: $[null ld0; 1f; ld0]; l1: floor lifetime * 1 % ld0; l0: 1 + til l1; m0: max l0; l0:-1_l0; y0: log[m0 - l0]; y0:y0 % max y0; y0:y0, -1#y0 }
// test

.wrkcwy.lives[`dress2;`days0]
.f.wear0[1f; .wrkcwy.lives[`dress2;`days0]]

// stock a lookup table

.wrkcwy.wears: select wear0:`float$() by mtrf1, wt0 from wrkcwy1

select first .wrkcwy.lives[([]wt0);`days0] by wt0 from `.wrkcwy.wears

update wear0: { .f.wear0[x;y] }[;first .wrkcwy.lives[([]wt0);`days0]] each mtrf1 by wt0 from `.wrkcwy.wears ;

// Add a look-up function that repeats the last value if index too large.
.f.wear1: { [wear0;days0] x0: wear0 @ days0; $[ null x0; -1#wear0; x0 ] }

// Test
10#select mtrf1, wt0, .wrkcwy.wears[([]mtrf1;wt0);`wear0] by i from wrkcwy1 where (not null days0), not null mtrf1

// 10# `wear1 xasc select mtrf1, days0, wear1: .f.wear1[first mtrf1.wear0;first days0] by i from wrkcwy1 where (not null days0), not null mtrf1

// Update the main table.
update wear1: .f.wear1[ first .wrkcwy.wears[([]mtrf1;wt0);`wear0]; first days0] by i from `wrkcwy1 where (not null days0), not null mtrf1 ;

// Add the tcars0 figure as a time-series scale by area

w0: select n:count distinct feature_id by name from cwylsoa

w1: ungroup select feature_id by name from delete asset_id from value select by i from cwylsoa

w2: w1 lj w0

w3: select first n by feature_id from w2

areas: select sum cwy0.area by lsoa from cwy2

update tcars1: tcars0 * area % areas[([]lsoa);`area] from `wrkcwy1 ;

// Cumulative sums of defects.
// Reset by work - except for patch

w0: select days0, dfcts by cwy0, wrkdt0, dfctdt0 from wrkcwy1

top0: raze value flip key 10#`n xdesc select n:count i by cwy0 from w0

// delta the days, cumsum the defects
// Prototype
// update the main table - ddays0 and dfcts are prescient wrt to days0
update ddays0: deltas days0, dfcts: sums dfcts by cwy0, wrkdt0, wt0 from `wrkcwy1 ;

a00: `cwy0`wrkdt0`wt0 xasc select by cwy0, wrkdt0, wt0 from wrkcwy1 where cwy0 in top0

update impute0:` from `wrkcwy1 ;

// so look-back time that is the lifetime, if not known
update ddays1: prev ddays0, dfcts1: prev dfcts by cwy0, wrkdt0 from `wrkcwy1 ;

update impute0:`ddays1, ddays1: `int$floor first .wrkcwy.lives[([]wt0);`days0] from `wrkcwy1 where null ddays1 ;

update dfcts1: 1j from `wrkcwy1 where null dfcts1 ;

select ddays0 * tcars1 from wrkcwy1

// Build a logit
.f.logit: { [v] 1 % 1 + exp (1 % count v) * neg sum v }

.wrkcwy.maxs: ()!()

.wrkcwy.maxs[`pri]: `float$first exec max pri from wrkcwy1

.wrkcwy.maxs[`spdlimit]: `float$first exec max spdlimit from wrkcwy1

// put road qualities into one logit
update wear2: .f.logit @ ((pri % .wrkcwy.maxs @ `pri);iscls;isdist;lanes2;isurban;(spdlimit % .wrkcwy.maxs @ `spdlimit)) by i  from `wrkcwy1 ;

// Use the prescient variable ddays0 to calculate it, it should mask it.
update wear3: ddays0 * tcars1 * wear2 from `wrkcwy1 ;
// bucket it down to be wear3
update wear3: .sch.logbin[sums wear3;2] by cwy0, wrkdt0 from `wrkcwy1 ;

a00: `cwy0`wrkdt0`dfctdt0 xasc 0!select by cwy0, wrkdt0, dfctdt0 from wrkcwy1 where cwy0 in top0

// Check - some correlation between dfcts and wear2
select count i, avg dfcts, sdev dfcts by wt0, 0.02 xbar wear2 from wrkcwy1

select count i, avg dfcts, sdev dfcts by wt0, 0.5 xbar wear3 from wrkcwy1

// Genuine records only have ddays1 and impute0 and impute1 are both null

select min wrkdt0, count i by wt0 from wrkcwy1 where null impute0

// Mark some samples for prediction

update sset0:` from `wrkcwy1 ;

update sset0:`oct2017 by cwy0, wt0, wrkdt0 from `wrkcwy1 where ((`month$dfctdt0) = `month$2017.10.01),(null impute0), (null impute1) ;

// Still some bad records

delete from `wrkcwy1 where (null wear3)|(null tmin) ;

a00: `wrkid`dfctdt0 xasc value select by i from wrkcwy1 where cwy0 in top0

.csv.t2csv[`wrkcwy1]

save `:./wrkcwy1

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


