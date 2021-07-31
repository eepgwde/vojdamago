// weaves
// @file salting1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key  against ftre

// Don't delete these keys yet, by doing this.
// update asset: ftre1[([]feature_id);`aid] from `fwylsoa1;

// FWY

// See if we can add an asset id to fwy1lsoa1
// re-key ftre1 on feature_id ie. aid0
ftre1: .sch.keyembed[ftre;`aid0;`feature_id]
ftre2: `feature_id xkey ungroup select asset_id:asset by feature_id from ftre1
// load the splay and join
fwylsoa1: value select by i from fwylsoa
fwylsoa1: (0!fwylsoa1) lj ftre2

// These aren't in fwy or cwy. I've looked.
.lsoa.fwyfeatures4assetnulls: exec distinct feature_id from fwylsoa1 where null asset_id

// Still using feature_id
// Only feature_id is available - this feature id doesn't have /LU
// so we use aid0
fwylsoa1: select by feature_id from fwylsoa1

t0: (0!ftre1) lj fwylsoa1
update fwy0:0b from `t0;
update fwy0:1b from `t0 where not null name;

select count i by type0, fwy0 from t0

t0: select feature_id, asset_id, name, type0 from t0 where fwy0

// Let's try aid from ftre
// ftre1: .sch.keyembed[ftre;`aid;`feature_id]
// 
// t0x: (0!ftre1) lj select by feature_id from t0 where not fwy0
// update fwy0:1b from `t0x where not null name;

// CWY

cwylsoa1: select by asset_id from cwylsoa
// re-key ftre1
ftre1: .sch.keyembed[ftre;`asset;`asset_id]

t1: (0!ftre1) lj cwylsoa1
update cwy0:0b from `t1;
update cwy0:1b from `t1 where not null name;

select count i by type0, cwy0 from t1

t1: select feature_id, asset_id, name, type0 from t1 where cwy0

// FWY + CWY
// The type0 field clashes with cwy0, because some LSOA appear as fwy

lsoa1: t0,t1

lsoa1: `featureid`assetid`lsoa`lsoa0 xcol 0!lsoa1
lsoa1: `featureid`lsoa0 xkey lsoa1

.lsoa.doubles: exec distinct featureid from (select n: count i by featureid from lsoa1) where 1 < n

// Mostly double are cwy and fwy.
// but some double keys
x1: `featureid xasc select from lsoa1 where featureid in .lsoa.doubles

// Force the first to be used.
t0: `featureid`lsoa0 xkey select first assetid, first lsoa, first lsoa0 by featureid from lsoa1 where lsoa0 = `fwy;
t1: `featureid`lsoa0 xkey select first assetid, first lsoa, first lsoa0 by featureid from lsoa1 where lsoa0 = `cwy;
// and rejoin using the key
lsoa1: t0,t1


// And a test against cwy0 using the explicit cwy key
x0: select featureid, lsoa0:`cwy, ward from cwy0
x1: x0 lj select from lsoa1

.lsoa.nulls: exec distinct featureid from x1 where null lsoa
count .lsoa.nulls

// Same discarding the key
// They match in missing counts.
x0: select featureid, ward from cwy0
x1: x0 lj select from 1!0!lsoa1

.lsoa.nulls1: exec distinct featureid from x1 where null lsoa
count .lsoa.nulls

a2: ungroup select distinct ward by lsoa from x1 where not null lsoa

lsoa2ward: select by lsoa from a2

// For imputation the count of lsoa by ward is useful.
x0: delete lsoa from select nlsoa:count distinct lsoa by ward from lsoa2ward

lsoa2ward: lsoa2ward lj x0

.lsoa.cwy: select by `cwy0$feature_id from cwylsoa where feature_id in raze value flip key cwy0

// Save
save `:./lsoa1
save `:./lsoa2ward

`:./wslsoa set get `.lsoa ;

// Save the error workspace for reference.

// And load it again like this.
// `.lsoa set get `:./wslsoa

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
