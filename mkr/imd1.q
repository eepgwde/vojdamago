// weaves
// @file imd1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key against cwy

count imd

// Just a few fields are useful.

imd1: `lsoa xkey ungroup select imd:imdscore, imdk:hertsimdrankoutof703, wealthk: hertswealthrankoutof703 by lsoa:lsoaname2011 from imd

imd1: imd1 lj lsoa2ward

// A check: only look-up works: target is x1
// Join featureid to lsoa1 for the LSOA name.
x1: select lsoa0:`cwy, featureid, ward from cwy0
x1: x1 lj lsoa1
.lsoa.nulls: exec distinct featureid from x1 where null lsoa
count .lsoa.nulls

// won't key, will it look up
update imd: imd1[([]lsoa);`imd] from `x1;
update imdk: imd1[([]lsoa);`imdk] from `x1;
update wealthk: imd1[([]lsoa);`wealthk] from `x1;

x1: `wealthk xdesc x1

.lsoa.nullfeatures: exec distinct featureid from x1 where null imd

cwy1: select from cwy0 where featureid in .lsoa.nullfeatures

// , imd1: imd1[([]lsoa);`hertsimdrankoutof703] from `x1;

// IMPUTATION
// Let's assume wards are close to LSOA, use lsoa2ward

imd2ward: select avg imd, avg imdk, avg wealthk by ward from imd1

// * summary

.imd.summary: x1
.imd.summary

save `:./imd1
save `:./imd2ward

// Save the error workspace for reference.

`:./wsimd set get `.imd

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
