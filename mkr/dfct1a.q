// @file dfct1a.q
// @author weaves

// Monthly history for dfcts.

// We can simplify to just date and siteid

.sys.qreloader enlist "hcc.q"

dts: asc raze value exec min dt0, max dt0 from dfct2 /  min and max from issue date

n0: first 1_deltas asc `month$dts		  /  number of months

dts0: (`month$dts[0]) + til n0			  /  months in range
dts0: (`date$dts0) - 1				  /  convert back to date and take from last day.

// Months have different day counts
t0: ([] dt0:dts0; n0:`dd$dts0)
t0: `dt0 xkey t0

// Quite a lot of activity - multiple reports in same period.

r0: { [x;y;z] .hcc.dfctrisk[y; x[0];x[1];z] }[;dfct2;"1m"] each flip exec (dt0;n0) from t0 ;

r0: { 0!x } each r0

.dfct.risk: `siteid`dt0 xasc raze r0;

\

// Problem with using foreign keys - you can't sum - must be a 64 bit/32 bit issue.

dt1x: 2#(0!t0)[;`dt0]
dt1x: dt1x[1]

r0: .hcc.dfctrisk[dfct0;dt1x;30;"1m"]

r0

select sum dfctinspct1m, sum dfctaction1m from r0

r1: exec dfct0 from dfct0 where dt1 <= dt1x ;
r2: select from dfct1 where dfct0 in r1

r3: `mm0 xasc select count action1, count inspct0, sum action1, sum inspct0 by mm0:`month$dt0, siteid from dfct1 where not null siteid

select count action1, count inspct0, sum rfr0, sum action1, sum inspct0 from dfct1 where (dt0 within 2013.01.01 2013.01.31), (ntype1 = `cwy), (featureid in kcwy)

a01: select first action1, first inspct0, first rfr0, first phase0, first status2 by dfct0 from dfct1 where (dt0 within 2013.01.01 2013.01.31), (ntype1 = `cwy), (featureid in kcwy)

select count dfct0.action1, count dfct0.inspct0, rfr0:sum dfct0.rfr0, sum dfct0.action1, sum dfct0.inspct0 from dfct0 where dt0 within 2013.01.01 2013.01.31
				       

select count action1, count inspct0, sum rfr0, sum action1, sum inspct0 from dfct0 where dt0 within 2013.01.01 2013.01.31

										     
select count dfct0.action1, count dfct0.inspct0, rfr0:sum dfct0.rfr0, sum dfct0.action1, sum dfct0.inspct0 from dfct0 where dt0 within 2016.01.01 2016.01.31
				       

/  Local Variables: 
/  mode:kdbp
/  minor-mode:q 
/  q-prog-args: "-p 5000 -c 200 120 -C 2000 2000 -load ../cache/csvdb help.q -verbose -halt -quiet"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
