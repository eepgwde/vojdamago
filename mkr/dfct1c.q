// @file dfct1c.q
// @author weaves

.sys.qreloader enlist "hcc.q"

// defecttype and defectypename - type0 and type0name
//

select count i by status from .tmp.dfct

// action0 is whether Action Required appears in status.
update action0:0b from `.tmp.dfct;
update action0:1b from `.tmp.dfct where status = `$"Action Required";

select count i by action0 from .tmp.dfct

select count i by type0, type0name from .tmp.dfct

// type1 from type0 is ntype1 is cwy or fwy
update type1:`$1#raze string each type0 by i from `.tmp.dfct;

// type2 from type0 is ntype2 is a priority A B C or T
update type2:`$1#raze reverse each string each type0 by i from `.tmp.dfct;

// type3 from type0 is ntype3 is a type of defect reported 
update type3:`${ x[1] } raze reverse each string each type0 by i from `.tmp.dfct;

select count i by type0,type0name from .tmp.dfct

select count i by type1 from .tmp.dfct
t1:1!([] type1:`C`F`R; ntype1:`cwy`fwy`cwy)

select count i by type2 from .tmp.dfct
t2:1!([] type2:`A`B`C`T; ntype2:1 2 3 4)

select count i by type3 from .tmp.dfct
t3:1!([] type3:`C`D`E`O`P`R`M; ntype3:`crack`trench`drop`other`pothole`trip`wear)

.tmp.dfct: .tmp.dfct lj t1
.tmp.dfct: .tmp.dfct lj t2
.tmp.dfct: .tmp.dfct lj t3

delete type1, type2, type3 from `.tmp.dfct;

.tmp.dfct: `dfct0 xasc .tmp.dfct

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
