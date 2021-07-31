// @file permit1a.q
// @author weaves

// Monthly history of permits. Never seem to get more than one permit per period.

.sys.qreloader enlist "hcc.q"

dts: asc raze value exec min idt0, max idt0 from permit2 /  min and max from issue date

n0: first 1_deltas asc `month$dts		  /  number of months

dts0: (`month$dts[0]) + til n0			  /  months in range
dts0: (`date$dts0) - 1				  /  convert back to date and take from last day.

// Months have different day counts
t0: ([] dt0:dts0; n0:`dd$dts0)
t0: `dt0 xkey t0

r0: { [x;y;z] .hcc.prmtrisk[y; x[0];x[1];z] }[;`permit2;"1m"] each flip exec (dt0;n0) from t0 ;

.permit.risk: `siteid`dt0 xasc raze r0;

r0:()
delete r0 from `.r0;

// Test

\l hcc.q

r1: .hcc.prmtrisk[`permit2;2016.12.31;365;"0t"]

select count i by prmt0t from r1

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
