// @author weaves
// @file poi1.q
// Using Points of Interest
// TODO
// Still need to use these.

// Some inspection and correction.

// -- Proximities

.poi.count: count poi
.poi.count

// check

c0: { x like "lt*" } string each cols poi
c0: (cols poi) where c0

.poi.maxitems: (count poi) * count c0

c1: { (sum;x) } each c0

d0: flip ?[poi;();0b;c0!c1]
t0: `lt0 xkey ungroup ([lt0:key d0] val0:value d0)

.poi.max: max t0[;`val0]

update val1:val0 % .poi.max by lt0 from `t0;

n0: count select from t0 where 0.05 > val1

// Error check
if[ 0.25 < n0 % count c0; 0N!"poi: bad load"; .sys.exit[1]]

.poi.counts: t0

// Table of column names to distances
.poi.distances: (cols poi) where { x like "lt*" } each string (cols poi)
.poi.distances

.poi.cols: ([] c0: .poi.distances; i0: { "I"$ssr[x;"lt";""] } each string .poi.distances )

// Check the featureid - is okay
a9: 0!select n:count i by aid:featureid from poi

x0: select first asset, first type0 by aid from ftre where type0 = `cwy;
x0: a9 lj x0

select count i by type0 from x0

.poi.nullcwy: count select from x0 where null type0
.poi.nullcwy

x1: select first asset, first type0 by aid:aid0 from ftre where type0 = `fwy;
x1: (select from x0 where null type0) lj x1

select count i by type0 from x1

.poi.nullfwy: count select from x1 where null type0
.poi.nullfwy

.poi.nulls: exec distinct aid from x1 where null type0


// key against cwy

poi1: select by featureid, category, classification from poi where not featureid in .poi.nulls
update cwy:`cwy0$featureid from `poi1;


/

// Just in case you want to write out the classifications

pois: 0!select count i by category, classification from poi
.sch.t2csv[`pois]

\

// Categories and constants

.poi.classes: `nassets xdesc select nassets:count distinct featureid by classification, category  from poi

.poi.max: exec max i0 from .poi.cols

.poi.step: 25					  /  
.poi.incs: .poi.step * til 1 + floor .poi.max % .poi.step

.poi.limit: floor .poi.max * 2 % 3 			/  maximum distance

.poi.cwy0r: select first featureid by featureid, .poi.step xbar distance from cwy0
update distance: `int$ { $[ .poi.limit >= x ; x; .poi.limit ] } each distance by i from `.poi.cwy0r;

.poi.cwy0r: `featureid xkey .poi.cwy0r

\l hcc.q

.poi.tables0: ()

.sys.qreloader enlist "poi1a.q"

count .poi.tables0

save `:./poi1

// Save the error workspace for reference.

`:./wspoi set get `.poi

// And load it again like this.
// `.inc set get `:./csvdb/wsinc

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
