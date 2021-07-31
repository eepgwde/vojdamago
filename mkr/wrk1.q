// weaves
// @file workcwy4.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key  against cwy

// For each date, the count
.workscwy.dts: `dt xdesc select n:count i by dt:`date$eventdate from workscwy2

c0: 1_cols workscwy2

wrk1: ungroup ?[workscwy2;();(enlist `idx)!enlist `i;c0!c0]

// No logic to the codes.

// Make date explicit
c0: (cols wrk1)
c0[where c0 = `eventdate]: `date0
wrk1: c0 xcol wrk1

ftre0: select by featureid:aid from ftre where type0 = `cwy;

update xref0:` from `wrk1 ;

update xref0:ftre0[([]featureid);`type0] from `wrk1;

.workscwy.badassets: select count i by featureid from wrk1 where null xref0
.workscwy.badassets: exec distinct featureid from wrk1 where null xref0

delete from `wrk1 where featureid in .workscwy.badassets ;

wrk1: wrk1 lj select usrn: first siteid by featureid from usrn2aid

update cwy0:`cwy0$featureid from `wrk1 ;
delete xref0, featureid from `wrk1;

// Some quick insights

select count distinct usrn by `year$date0 from wrk1

select count distinct cwy0 by `year$date0 from wrk1

// * summary

// Write out

save `:./wrk1

// Save the error workspace for reference.

`:./wsworkscwy set get `.workscwy

// And load it again like this.
// `.workscwy set get `:./csvdb/wsdfct

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
