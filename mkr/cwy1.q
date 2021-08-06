// weaves
// @file rci1.q

// Using q/kdb+ for the db.

// Some inspection and correction. This should be run before the others.

// -- Load some simple CSV files.

.cwy.speeds: ("SF"; enlist ",") 0: `:../in/speeds.csv
.cwy.speeds: `featureid xkey `featureid`spdlimit xcol .cwy.speeds

.cwy.mtraffic: ("SF"; enlist ",") 0: `:../in/mtraffic.csv
.cwy.mtraffic: `featureid xkey `featureid`mtraffic xcol .cwy.mtraffic

// Keyed table

cwy0: select by featureid from cwy

cwy0: delete said from update aid00:`$first said by i from update said: { "/" vs x } each string featureid by i from cwy0

cwy0: cwy0 lj .cwy.speeds
cwy0: cwy0 lj .cwy.mtraffic

1 string count cwy0

// TODO
// Types. There is a network hierarchies file too.
// Also bus routes by the central_asset_id in mail recently.

`x xasc select count i by roadhierarchy from cwy0

`roadtypehw`roadtype xasc select count i by roadtypehw, roadtype from cwy0

`x xasc select count i by roadclass from cwy0

`x xasc select count i by hierarchy from cwy0

// ftre00: select by aid00 from 0!ftre

// And the idea is it will match all roads
// any null exec ftre00[([]aid00);`type0] from cwy0

// Lookup tables

.cwy.hierarchy: 0!select pri: 1h by hierarchy from cwy0
.cwy.hierarchy

.cwy.hierarchy: ([hierarchy: .cwy.hierarchy[;`hierarchy]] isdist:`boolean$ 1 0 0 1 0 1 0 1; pri:`short$ 3 2 4 7 0 6 0 5 )
.cwy.hierarchy

.cwy.roadclass: 0!select `short$1 by roadclass from cwy0
.cwy.roadclass

.cwy.roadclass: ([roadclass: .cwy.roadclass[;`roadclass]] iscls:`boolean$0 1 1 0 1 ; pri:`short$0 4 5 2 3)
.cwy.roadclass

.cwy.roadtypehw: 0!select `short$1 by roadtypehw from cwy0
.cwy.roadtypehw
update desc0: { " " vs x } each string each roadtypehw by i from `.cwy.roadtypehw;
.cwy.roadtypehw

f: { x ~ y }
g: { count ss[x;y] }

.t.tag: "Slip/Feeder"
update isslip: any { f[x;.t.tag ] } each raze desc0 by i from `.cwy.roadtypehw ;
.cwy.roadtypehw

.t.tag: "Slip/Feeder"
update isslip: any { f[x;.t.tag ] } each raze desc0 by i from `.cwy.roadtypehw ;
.cwy.roadtypehw

.t.tag: "Slip/Feeder"
update isslip: any { f[x;.t.tag ] } each raze desc0 by i from `.cwy.roadtypehw ;
.cwy.roadtypehw

.t.tag: "Shared"
update isshared: any { f[x;.t.tag ] } each raze desc0 by i from `.cwy.roadtypehw ;
.cwy.roadtypehw

.t.tag: "Dual"
update isdual: any { f[x;.t.tag ] } each raze desc0 by i from `.cwy.roadtypehw ;
.cwy.roadtypehw

.t.tag: "Single"
update issingle: any { f[x;.t.tag ] } each raze desc0 by i from `.cwy.roadtypehw ;
.cwy.roadtypehw

.t.tag: "Oneway"
update isoneway: any { f[x;.t.tag ] } each raze desc0 by i from `.cwy.roadtypehw ;
.cwy.roadtypehw

.t.tag: "Roundabout"
update isround: any { f[x;.t.tag ] } each raze desc0 by i from `.cwy.roadtypehw ;
.cwy.roadtypehw


l0: `short$0 1 2 3 2 1 2 3 0 1 0 2 3 4 1 2 1 2 2
t0: ([roadtypehw: (0!.cwy.roadtypehw)[;`roadtypehw]] lanes: l0)
t0

.cwy.roadtypehw: delete x, desc0 from .cwy.roadtypehw lj t0
.cwy.roadtypehw: `roadtypehw xkey .cwy.roadtypehw

select n:1h by roadtype from cwy0

.cwy.roadtype: select n:count i by roadtype from cwy0
.cwy.roadtype

.cwy.roadtype: ([roadtype: raze value flip key .cwy.roadtype] lanes2: 0 1 2 3 1 1 2 3 2; isdual:`boolean$0 1 1 1 0 0 0 0 0 )
.cwy.roadtype

.cwy.roadhierarchy: select n:count i by roadhierarchy from cwy0
.cwy.roadhierarchy

.cwy.roadhierarchy: ([roadhierarchy: raze value flip key .cwy.roadhierarchy] rh0: 3h + `short$-3 5 4 3 2 1 0 -1 -1 -2 -2 -2 -2 -2 -2 -2 -2 -2 -3)
.cwy.roadhierarchy

// IMPUTATION

-10#select count i by mtraffic from cwy0

// Too granular

t0: ungroup select featureid by 50 xbar mtraffic from cwy0 where mtraffic within 0 800
t0,: ungroup select featureid by 100 xbar mtraffic from cwy0 where mtraffic within 800 2000
t0,: ungroup select featureid by 500 xbar mtraffic from cwy0 where mtraffic within 2000 10000
t0,: ungroup select featureid by 1000 xbar mtraffic from cwy0 where mtraffic within 10000 20000
t0,: ungroup select featureid by 2000 xbar mtraffic from cwy0 where mtraffic within 20000 40000
t0,: ungroup select featureid by 5000 xbar mtraffic from cwy0 where mtraffic within 40000 0w


t0: `featureid xkey t0

cwy0: cwy0 lj t0

// 

select count i by spdlimit from cwy0

a00: select featureid, aid00 from cwy0 where null spdlimit
a00: `aid00 xkey a00

a01: select 10 xbar avg spdlimit by aid00 from cwy0 where (not null spdlimit), aid00 in exec aid00 from a00
a01: `aid00 xkey a01

a00: a00 lj a01

a02: select featureid, spdlimit, roadtypehw from cwy0 where featureid in exec featureid from a00 where null spdlimit

a03: update spdlimit:70f from (select 10 xbar avg spdlimit by roadtypehw from cwy0) where null spdlimit

a00: `featureid xkey a00

a00: a00 lj `featureid xkey ungroup select roadtypehw by featureid from cwy0

a00: a00 lj a03

cwy0: cwy0 lj `featureid xkey select featureid, spdlimit from a00
											     

// QUANTIFY

t0: .cwy.hierarchy
.t.tag:`isdist
update isdist: t0[([]hierarchy:hierarchy);.t.tag] from `cwy0;
.t.tag:`pri
update pri: t0[([]hierarchy:hierarchy);.t.tag] from `cwy0;

t0: .cwy.roadclass
.t.tag:`iscls
update iscls: t0[([]roadclass:roadclass);.t.tag] from `cwy0;
.t.tag:`pri
update pri2: t0[([]roadclass:roadclass);.t.tag] from `cwy0;

t0: .cwy.roadtypehw
.t.tag: `isslip
update isslip: t0[([]roadtypehw:roadtypehw);.t.tag] from `cwy0;
.t.tag: `isshared
update isshared: t0[([]roadtypehw:roadtypehw);.t.tag] from `cwy0;
.t.tag: `isdual
update isdual: t0[([]roadtypehw:roadtypehw);.t.tag] from `cwy0;
.t.tag: `issingle
update issingle: t0[([]roadtypehw:roadtypehw);.t.tag] from `cwy0;
.t.tag: `issingle
update issingle: t0[([]roadtypehw:roadtypehw);.t.tag] from `cwy0;
.t.tag: `isoneway
update isoneway: t0[([]roadtypehw:roadtypehw);.t.tag] from `cwy0;
.t.tag: `isround
update isround: t0[([]roadtypehw:roadtypehw);.t.tag] from `cwy0;
.t.tag: `lanes
update lanes: t0[([]roadtypehw:roadtypehw);.t.tag] from `cwy0;

t0: .cwy.roadtype
.t.tag:`isdual
update isdual: t0[([]roadtype:roadtype);.t.tag] from `cwy0;
.t.tag: `lanes2
update lanes2: t0[([]roadtype:roadtype);.t.tag] from `cwy0;

t0: .cwy.roadhierarchy
.t.tag:`rh0
update rh0: t0[([]roadhierarchy:roadhierarchy);.t.tag] from `cwy0;

.cwy.minwidth: exec min width from cwy0 where 0 < width

update width:.cwy.minwidth from `cwy0 where (null width);
update width:.cwy.minwidth from `cwy0 where 0 >= width;

.cwy.mindistance: exec min distance from cwy0 where 0 < width

update distance:.cwy.mindistance from `cwy0 where (null distance);
update distance:.cwy.mindistance from `cwy0 where 0 >= distance;

update area: distance * width from `cwy0 ;

// ** aid00 metrics

// select isdist, pri, iscls, pri2, isslip, isshared, isdual, issingle, isoneway, isround, lanes, lanes2 rh0 by aid00 from cwy0 where 1 < count featureid

aid0: select nassets:count distinct featureid, avg distance, avg width, avg area by aid0:aid00 from cwy0

update isisolated:1b from `aid0;
update isisolated:0b from `aid0 where 1 < nassets ;

aid0: `nassets xdesc aid0

//  sum distance, avg width, area: avg distance * width

aid1: select isdist, pri, iscls, pri2, isslip, isshared, isdual, issingle, isoneway, isround, lanes, lanes2, rh0 by aid0:`aid0$aid00 from cwy0 

// Aggregate

update sum `short$isdist, avg pri, any iscls, avg pri2, any isslip, any isshared, sum isdual, sum issingle, sum isoneway, any isround, avg lanes, avg lanes2, avg rh0 by aid0 from `aid1 ;

update rh0:0f from `aid1 where null rh0;

aid1: aid1 lj aid0

update aid0:`$string aid0 from `aid1;

// Remove the key
aid0:()
delete aid0 from `.;

// Prepare for join
aid1: `aid0 xkey `nassets xcols 0!`nassets xdesc aid1

20#aid1

c0: cols aid1
c1: .sch.rename[c0;2;"a0X"]

aid1: c1 xcol aid1

aid1: `aid00 xcol aid1

cwy0: `featureid xkey (`aid00 xkey cwy0) lj aid1

// -- USRN
// Apparently the siteid is the USRN

x0: select distinct sitename by siteid,featureid,aid00 from cwy0
x0: `siteid xkey x0

.cwy.usrn: x0

usrn2aid: .cwy.usrn

cwy0: update siteid:`usrn2aid$"I"$string siteid from cwy0

// Write these two new keyed tables as files in the directory.

save `:./usrn2aid
save `:./cwy0

// Save the error workspace for reference.

`:./wscwy set get `.cwy ;

// And load it again like this.
// `.rci set get `:./csvdb/wsrci

.sys.exit[0]

\

/  Local Variables: 
/  mode:kdbp-mode
/  minor-mode:q
/  q-prog-args: "-p 5000 -c 200 120 -C 2000 2000 -load ../cache/csvdb help.q -verbose -halt -quiet"
/  comment-start: "/  "
/  comment-end: ""
/  fill-column: 75
/  comment-column:50
/  End:
