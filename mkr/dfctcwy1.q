// weaves
// @file dfctcwy1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key  against cwy

// For each date, the count
.dfctcwy.dts: `dt xdesc select n:count i by dt:`date$date0 from dfctcwy

dfct0: value select by i from dfctcwy

c0: raze exec c from (meta dfctcwy) where t <> "C"
c0: c0 except `easting`northing`supersedes`superseded`street`assetnumber

dfctcwy1: ?[dfct0;();0b;c0!c0]

dfct0: ()
delete dfct0 from `.;

update date0:`date$date0, xref0:` from `dfctcwy1;

ftre0: select by featureid:aid from ftre where type0 = `cwy

update xref0:ftre0[([]featureid);`type0] from `dfctcwy1;

.dfctcwy.badassets: select count i by featureid from dfctcwy1 where null xref0
.dfctcwy.badassets: exec distinct featureid from dfctcwy1 where null xref0

delete from `dfctcwy1 where featureid in .dfctcwy.badassets ;

update cwy0:`cwy0$featureid from `dfctcwy1 ;
delete featureid from `dfctcwy1;

// re-classify

c0: cols dfctcwy1
c0[where c0 = `type]: `type0
c0[where c0 = `typename]: `type0name

dfctcwy1: c0 xcol dfctcwy1

.tmp.dfct: dfctcwy1

.sys.qreloader enlist "dfct1c.q"

dfctcwy1: .tmp.dfct
.tmp.dfct:()
delete dfct from `.tmp;

select count i by ntype1, ntype3 from dfctcwy1

// Some quick insights

select count distinct usrn by `year$date0 from dfctcwy1

select count distinct cwy0 by `year$date0 from dfctcwy1

// * summary

// Write out

save `:./dfctcwy1


// Save the error workspace for reference.

`:./wsdfctcwy set get `.dfctcwy

// And load it again like this.
// `.dfctcwy set get `:./csvdb/wsdfct

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
