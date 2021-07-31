// weaves
// @file enq1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key  against cwy

// For each date, the count
.enq.dts: `dt xdesc select n:count i by dt:`date$enquirytime0 from enq

// Some keys to search for 

cwy2: raze (value flip key cwy0)		  /  featureid *not* assetid
fwy2: distinct fwy[;`assetid]

fiad2: distinct fwy[;`featureidalias]

// New table, with locator in xref0
enq1: value select by i from enq
update xref0:` from `enq1;

// Tag carriageways
update xref0:`cwy from `enq1 where assetid in cwy2;

// Tag footways
update xref0:`fwy from `enq1 where (null xref0), assetid in fwy2;

// Tag as featureidalias
update xref0:`fiad from `enq1 where (null xref0), assetid in fiad2;

// Tag as null
update xref0:`null from `enq1 where (null xref0), null assetid ;

// Tag as nositename
update xref0:`nositename from `enq1 where (null xref0), sitename = `None;

// dashes and colons, slashed but no match, 

idx0: { 0 < count x ss "-" } each exec string assetid from enq1 where null xref0
idx1: (select from enq1 where null xref0)[where idx0;`assetid]
update xref0:`dash from `enq1 where (null xref0), assetid in idx1;

idx0: { 0 < count x ss ":" } each exec string assetid from enq1 where null xref0
idx1: (select from enq1 where null xref0)[where idx0;`assetid]
update xref0:`colon from `enq1 where (null xref0), assetid in idx1;

idx0: { 0 < count x ss "/" } each exec string assetid from enq1 where null xref0
idx1: (select from enq1 where null xref0)[where idx0;`assetid]
update xref0:`slash from `enq1 where (null xref0), assetid in idx1;

// remnants are left as null

.enq.remnants: select from enq1 where null xref0

// * colon dash slash
// This reference table is used as a key table for dash and slash
ftre1: select count aid, aseg0 by aid0 from ftre;
// Add space for a key to ftre1
// Add a parent reference to aid0 from ftre1 for those assetid that do match
update ftre1:` from `enq1;

// *slash see if I can do anything with the slashed ones
// note: I add trailing semi-colons because of issues with my editor!

.tmp.str: "/"
.tmp.xref0: `slash
.tmp.xref1: `xslash

.sys.qreloader enlist "enq1a.q"

// *dash see if I can do anything with the dashed ones

.tmp.str: "-"
.tmp.xref0: `dash
.tmp.xref1: `xdash

.sys.qreloader enlist "enq1a.q"

// *colon see if I can do anything with the colon

.tmp.str: ":"
.tmp.xref0: `colon
.tmp.xref1: `xcolon

.sys.qreloader enlist "enq1a.q"

/

// This is the original file for priority estatus0

t0:0!select count i by enqstatusname from enq1

.sch.t2csv[`t0]

\

.enq.priority: `enqstatusname xkey ("S S"; enlist ",") 0: `:../in/estatus0.csv
enq1: enq1 lj .enq.priority


// * summary

select count i by xref0 from enq1

select count i by xref0, ftre1 from enq1

// nothing with sitename
n0: any not null exec ftre1 from select ftre1:idx1[([]assetid);`aid0] from enq1 where xref0 = `nositename;
n0

.enq.unmatched0: ``null`xdash`xslash`xcolon`nositename

t0: select type0:`unmatched, count assetid, count distinct assetid by xref0 from enq1 where xref0 in .enq.unmatched0
t1: select type0:`matched, count assetid, count distinct assetid by xref0 from enq1 where not xref0 in .enq.unmatched0

.enq.summary: 2!0!t0,t1

.enq.summary1: select count assetid, count distinct assetid, count ftre1, ftre1: count distinct ftre1 by xref0 from enq1 where not null ftre1

.enq.summary1

// Add keys, just the two main classes will be enough.

update cwy:`cwy0$` from `enq1;
update cwy:`cwy0$assetid from `enq1 where xref0 = `cwy;

update fwy:`fwy0$` from `enq1;
update fwy:`fwy0$assetid from `enq1 where xref0 = `fwy;

// Finally we can key this and rename the key field.
enq1: `enquirynumber xkey enq1
enq1: `enq0 xcol enq1
update enq0:`${ "E", string x } each enq0 from `enq1;

// Try using aid00

ftre00: select type1:`aid00, type0, aseg0 by aid00 from ftre

// Add a numeric classification

.enq.priority: `subjectcode xkey ("SSHF  "; enlist ",") 0: `:../in/cph_weaves.csv

enq1: enq1 lj .enq.priority

/

// Original version of emethod0

t0: `n xdesc select n:count i, avg priority by method from enq1
.sch.t2csv[`t0]

\

.enq.method: `method xkey ("S  SH"; enlist ",") 0: `:../in/emethod0.csv

enq1: enq1 lj .enq.method

// Write these two new keyed tables as files in the directory.

save `:./enq1

// Save the error workspace for reference.

`:./wsenq set get `.enq

// And load it again like this.
// `.enq set get `:./csvdb/wsenq

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
