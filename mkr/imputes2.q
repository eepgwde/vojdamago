// @author weaves
// @file imp0.q
// Load and write some files with imputed values

\l hcc.q

// The factors as symbols
fu2: .sch.a2hsym2["../"; "impute0-imp-003.csv"]
u2: `es1 xkey ("SH"; enlist ",") 0: fu2
u2: `es1`estatus0 xcol u2
u2: `es1 xasc delete from u2 where null es1 

// The samples with imputed values
ft2: .sch.a2hsym2["../"; "impute0-imp-002.csv"]
t2: `smpl0 xkey ("EEEE S"; enlist ",") 0: ft2

// The imputed values mapped to the originals
fs1: .sch.a2hsym2["../"; "impute0-imp-001.csv"]
s1: ("ES"; enlist ",") 0: fs1

// Change columns on the samples
c1: (1#(cols t2)), `${ x,"X" } each string 1_cols t2
t2: c1 xcol (0!t2)

// Change names of values in s1
s2: update ind0:`${ ssr[x;".imp";""] } each string ind , ind: `${ ssr[x;".imp";"X"] } each string ind by i from s1

types0: raze exec distinct ind0 from s2

r0: { .hcc.flipper[s2; x] } each types0

.tmp.tbl: t2
{ .tmp.tbl: .tmp.tbl lj x; } each r0

t3: .tmp.tbl
.tmp.tbl: ()

idx: { x like "*X" } each string cols t3
c1: (cols t3) where idx

// Delete the originals
imputes0: ![t3;();0b;c1]

imputes0: delete estatus0 from update es1:`short$estatus0 from imputes0

imputes0: `smpl0 xkey delete es1 from imputes0 lj u2

imputes0: update emethod1:`short$emethod1, priority:`short$priority, response:`float$response from imputes0

save `:./imputes0

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

