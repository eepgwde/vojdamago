// @author weaves
// @file hcc.q
// Utility methods for hcc


\d .hcc

// date to season

// keyed table of seasons is flipped to a dictionary
i.ssns: ([mm0: `int$(1 + til 12) ] seasony:(4#`wintry),(4#`summery),(3#`autumny),`wintry)
i.ssns1: (raze value flip key .hcc.i.ssns) ! raze value flip value .hcc.i.ssns

// list-ready mapper: month number to season
// f @ 1 ; f @ 4 5 6 ; 
// ( [] a:1 2 ; b:.hcc.ssny3[ 2016.01.01 2017.01.01 ] )
// select mm0:`mm$distinct lossdate, ssn:.hcc.ssny3[distinct lossdate] by i from clm2

// for integers
ssny2: { [x] .hcc.i.ssns1 @ x }

// for dates
ssny: { [d0] .hcc.ssny2 @ `mm$d0 }

// lookup table on integer
ssny4: { [x] ([] mm0: (`int$$[0 > type x; enlist x; x]))#.hcc.i.ssns }
// lookup table on date
ssny3: { [d0] .hcc.ssny4 @ `mm$d0 }

// fakedate - from year and month

fdt: { [yy0;mm0;dd0] "D"$"." sv (string yy0;string mm0; dd0) }
fdt1: fdt[;;"01"]
fdt2: { [month0;dd0] .hcc.fdt[`year$month0; `mm$month0; dd0] }

// Calculates the permit risk
//
// The tsym is a permits table (permits2)
// dt0 is the date to look back from.
// n0 is the number of days to look back by.
// tag0 is an optional string for the suffix to the column names.
// @note
// This has to be by site-id - it should be scaled by the number of assets in
// the site-id
// @note
// You can look forward with a negative n0

prmtrisk1: { [tsym;dt0;n0;tag0;ddt] dt00:dt0; dts: asc (dt0, dt0 - n0) - ddt;
	    s0: ungroup select distinct permit0 by siteid from tsym where or[(sdt0 within dts);(edt0 within dts)]; /  in period
	    s0,: ungroup select distinct permit0 by siteid from tsym where (sdt0 < min dts),(edt0 > max dts); /  across period
	    s0: distinct s0[;`permit0];
	    g1: select from tsym where permit0 in s0;
	    // Adjust start dates to be min if further back. Recalculate days.
	    g1: update sdt0: min dts from g1 where sdt0 <= min dts;
	    g1: update edt0: max dts from g1 where edt0 >= max dts;
	    g1: update ddt0:1 + edt0 - sdt0 from g1;
	    // calculate risk
	    n1: abs `float$n0;
	    g2: select dt0:dt00, prmt1:count i, prmtwcat1: avg permit0.wcat1, prmtddt1: abs sum ddt0, prmtrisk1: abs permit0.wcat1 wsum ddt0 % n1 by siteid, ptype0 from g1;
	    // adjust columns
	    c0: cols g2;
	    tag0: $[0 = count tag0; $[0 < n0; "b"; "f"], string n1; tag0 ];
	    c1: `${ [x;y] ssr[x;"1";y] }[;tag0] each string c0;
	    g2: `siteid`dt0 xkey c1 xcol g2;
	    g2 }

prmtrisk: .hcc.prmtrisk1[;;;;0]

// Calculates the dfct risk
// @deprecated
// The tsym is a dfct table (dfct0)
// dt0 is the date to look back from.
// n0 is the number of days to look back by.
// tag0 is an optional string for the suffix to the column names.
// @note
// This is by site-id and is now deprecated.
// @note
// You can't aggregate with a foreign key. You can count, but not sum.
// @note
// You can look forward with a negative n0

dfctrisk1: { [tsym;dt0;n0;tag0;ddt] dt00:dt0; dts: (asc dt0, dt0 - n0) - ddt;
	    // Get the keys of the defects in the period.
	    s0: ungroup select distinct dfct0 by siteid from tsym where dt0 within dts; /  in period
	    s0: distinct s0[;`dfct0];
	    // And get those
	    g1: select by dfct0 from tsym where dfct0 in s0;
	    // calculate risk
	    n1: abs `float$n0;
	    g2: select dfct1:count i, dfctrfr1: sum dfct0.rfr0, dfctinspct1: sum dfct0.inspct0, dfctaction1: sum dfct0.action1, dfctcat1: avg dfct0.cat0, dfctrisk1: avg dfct0.phase0 wsum 1 % dfct0.resp0 by siteid, dfct0.status1 from g1;
	    // This date is adjusted to be the date of summary.
	    g2: update dt0:dt00 from g2;
	    // adjust columns
	    c0: cols g2;
	    tag0: $[0 = count tag0; $[0 < n0; "b"; "f"], string n1; tag0 ];
	    c1: `${ [x;y] ssr[x;"1";y] }[;tag0] each string c0;
	    g2: `siteid`dt0 xkey c1 xcol g2;
	    g2 }

dfctrisk: .hcc.dfctrisk1[;;;;0]

// Calculates the dfct risk
// 
// The tsym is a dfct table (dfct0)
// dt0 is the date to look back from.
// n0 is the number of days to look back by.
// tag0 is an optional string for the suffix to the column names.
// @note
// This is by site-id and is now deprecated.
// @note
// You can't aggregate with a foreign key. You can count, but not sum.
// @note
// You can look forward with a negative n0

dfct2risk1: { [tsym;dt0;n0;tag0;ddt] dt00:dt0; dts: (asc dt0, dt0 - n0) - ddt;
	    // Get the keys of the defects in the period.
	    s0: ungroup select distinct dfct0 by cwy from tsym where dt0 within dts; /  in period
	    s0: distinct s0[;`dfct0];
	    // And get those
	    g1: select by dfct0 from tsym where dfct0 in s0;
	    // calculate risk
	    n1: abs `float$n0;
	    g2: select dfct1:count i, dfctrfr1: sum rfr0, dfctinspct1: sum inspct0, dfctaction1: sum action1, dfctcat1: avg cat0, dfctrisk1: avg phase0 wsum 1 % resp0 by cwy, status1 from g1;
	    // This date is adjusted to be the date of summary.
	    g2: update dt0:dt00 from g2;
	    // adjust columns
	    c0: cols g2;
	    tag0: $[0 = count tag0; $[0 < n0; "b"; "f"], string n1; tag0 ];
	    c1: `${ [x;y] ssr[x;"1";y] }[;tag0] each string c0;
	    g2: `cwy`dt0 xkey c1 xcol g2;
	    g2 }

dfct2risk: .hcc.dfct2risk1[;;;;0]

// Calculates the smpl risk by feature-id
// 
// The tsym is not a sym, but the the samples1 table (smpl0)
// dt0 is the date to look back from we don't subtract our own date
// this saves imputing.
// n0 is the number of days to look back by.
// tag0 is an optional string for the suffix to the column names.
// This exponentially weights. Looking back older events are less important.
// Looking forward nearer events are more important.
// @note
// You can't aggregate with a foreign key. You can count, but not sum.
// @note
// You can look forward with a negative n0

smpl2risk1: { [tsym;dt0;n0;tag0;ddt] dt00:dt0; dts: (asc dt0, dt0 - n0) - ddt;
	    // Get the keys of the defects in the period.
	    s0: ungroup select distinct smpl0 by cwy0 from tsym where date0 within dts; /  in period
	    s0: distinct s0[;`smpl0];
	    // And get those
	    g1: select by smpl0 from tsym where smpl0 in s0;
	    // calculate risk
	     n1: abs `float$n0;
	     // Exponential weighting - reversed if looking forward
	     wts: (`int$n1)#.hcc.ewma1[(1,(`int$n1)#0);10];
	     g2: select smpl1:count i, smplwt1: (0^wts[dt00 - date0]) wsum (count i)#1, smplrisk1: (0^wts[dt00 - date0]) wsum (count i)#1 wsum priority by cwy0 from g1;
	    // This date is adjusted to be the date of summary.
	    g2: update date0:dt00 from g2;
	    // adjust columns
	    c0: cols g2;
	    tag0: $[0 = count tag0; $[0 < n0; "b"; "f"], string n1; tag0 ];
	    c1: `${ [x;y] ssr[x;"1";y] }[;tag0] each string c0;
	    g2: `cwy0`date0 xkey c1 xcol g2;
	    g2 }

smpl2risk: .hcc.smpl2risk1[;;;;0]


// Calculates the smpl risk by site-id
// 
// The tsym is not a sym, but the the samples1 table (smpl0)
// dt0 is the date to look back from.
// n0 is the number of days to look back by.
// tag0 is an optional string for the suffix to the column names.
// This exponentially weights. Looking back older events are less important.
// Looking forward nearer events are more important.
// @note
// You can't aggregate with a foreign key. You can count, but not sum.
// @note
// You can look forward with a negative n0

ssmpl2risk1: { [tsym;dt0;n0;tag0;ddt] dt00:dt0; dts: (asc dt0, dt0 - n0) - ddt;
	     // Get the keys of the defects in the period.
	     s0: ungroup select distinct smpl0 by siteid from tsym where date0 within dts; /  in period
	     s0: distinct (0!s0)[;`smpl0];
	     // And get those
	     g1: select by smpl0 from tsym where smpl0 in s0;
	     // calculate risk
	     n1: abs `float$n0;
	     wts: (`int$n1)#.hcc.ewma1[(1,(`int$n1)#0);10];
	     g2: select ssmpl1:count i, ssmplwt1: (0^wts[dt00 - date0]) wsum (count i)#1, ssmplrisk1: (0^wts[dt00 - date0]) wsum (count i)#1 wsum priority by siteid from g1;
	    g2: update date0:dt00 from g2;
	    c0: cols g2;
	    tag0: $[0 = count tag0; $[0 < n0; "b"; "f"], string n1; tag0 ];
	    c1: `${ [x;y] ssr[x;"1";y] }[;tag0] each string c0;
	    g2: `siteid`date0 xkey c1 xcol g2;
	     g2 }

ssmpl2risk: .hcc.ssmpl2risk1[;;;;0]


// Find columns below integer value
// @external .poi.cols
.hcc.poi0: { [x] exec c0 from .poi.cols where x >= i0 }

// Find valid poi increments
// @external .poi.incs
.hcc.poi1: { [x;r0] (r0 * x) >= .poi.incs }

// Calculate a PoI feature
// Uses exponential weighting and a radial measure.
// @external Relies on the table .poi.cwy0r
.hcc.poiftr: { [tbl;c0;tag0; r0] 
	    tbl: select from tbl where classification in c0;
	    tbl: update dist0: .poi.cwy0r[([]featureid);`distance] from tbl;
	    tbl: update dist1: { .hcc.poi1[x;y] }[;r0] each dist0 from tbl;
	    // Boolean sum
	    tbl: update count0: sum .poi.weights * (raze dist1) * flip deltas flip (lt0;lt25;lt50;lt75;lt100;lt125;lt150;lt175;lt200;lt225;lt250;lt275;lt300;lt325;lt350;lt375;lt400;lt425;lt450;lt475;lt500;lt525;lt550;lt575;lt600;lt625;lt650;lt675;lt700;lt725;lt750;lt775;lt800;lt825;lt850;lt875;lt900;lt925;lt950;lt975) by i from tbl;
	    // finally
	    x0: `featureid xkey (`featureid,tag0) xcol select featureid, count0 from tbl }

// Set a column to zero if null.
// @parm tbl is the value table
// @parm c0 symbol of the column to update.
.hcc.zero0: { [tbl;c0] zero0: (upper (meta tbl)[c0;`t])$"0";
	     t:tbl;
	     c:( enlist (null;c0) );
	     b:0b;
	     a:( (enlist c0)!(enlist (max;zero0) ) );
	     ![t;c;b;a] }



/// Exponentially weighted moving average
/// Always some debate about this. This is the "starting value is one" version.
/// @note
/// In the use of scan, x is the prior and y the current. I've renamed them to make it
/// look like the Wikipedia, they call lambda alpha and here I had to anti the lambda
/// (1-lambda) is passed as a constant 'z' to the interior function for scan.
/// @note
/// You can pass N in place of lambda, if greater than one, it will derive lambda
/// for you. N is a sort of period. It's best to calibrate against a Impulse Response
/// viz. .f00.ewma1[ (1,20#0); 2]
/// @note
/// Calibrated against and, once again, puts it to shame on execution times.

ewma1: { [s0; lambda] 
	lambda: $[lambda >= 1; 2 % lambda + 1; lambda];
	{ [now0;past0;z] past0 + z*(now0 - past0) }[;;1 - lambda] scan s0 }

// Nulls0
nulls0: { [tbl;c0] c1: c0!c0;
	 // make a dictionary
	 d0: .Q.V ?[tbl;();0b;c1];
	 idx: { [x;y] any null y[x] }[;d0] each c0;
	 cnts: { [x;y] sum null y[x] }[;d0] each c0 where idx;
	 null0: ([] col0:c0 where idx; cnt: cnts);
	 null0 }


prmt0: { [type0;stype0;tbl] 
	a00: value delete dt0, found0 from select by i from tbl where ptype0 = type0;
	c0: cols a00; c1: string c0; c2: { [x;y] `$ssr[x;"prmt";"prmt",y] }[;stype0] each c1;
	a00: delete ptype0 from c2 xcol a00;
	`siteid`date0 xkey a00 }

impute0: { [tbl;c0; val0] c:( enlist (null;first c0) ); a:( (c0! val0) ); ![tbl;c;0b;a] }

// Find superceded records
// In customer history files, there is a convention that records are linked by recording their predecessor
// This returns the list of keys of records that have predecessors to d0.
// The order they are found in is reversed, so the first is root
supercede: { [tbl;d0;tag0] ss0:(); while[ not null d0; ss0,:d0; d0: tbl[d0;tag0] ]; reverse ss0 }


coverage0: { [tbl;bar0] c0: last cols tbl; c1: first cols tbl;
	    c0: last cols tbl;
	    c:();
	    b:(enlist `value0)!(enlist ({ y xbar x }[;bar0];c0));
	    a:`n`nassets!((count;`i);({ count distinct x };c1));
	    t0: ?[tbl;c;b;a];
	    t0: ![t0;();(enlist `i)!enlist `i;(enlist `src0)!enlist ({`$x};string c0) ];
	    
	    t0: ?[t0;c;(`value0`src0)!`value0`src0;()] }


// Flip a subset of a table
// tbl is the table where values are keyed by ind0 (the group), and have subsets named by ind.
// nm0 is the name of the group
.hcc.flipper: { [tbl;nm0] s3: select values by ind0, ind from tbl;
	       s4: delete ind0 from ungroup select by ind from s3 where ind0 = nm0;
	       s5: select values by ind from s4;
	       s7: .sch.flipper[s5;`nkey];
	       s8: `int$(raze/) s7[;1#cols s7];
	       s9: delete nkey from ungroup `nkey xkey update nkey:enlist s8 from s7;
	       (-1#(cols s9)) xkey s9 }


// Filter by year as a timestamp.
// xwrkcwy1.q
.hcc.dfctcwy0: { [tsym;yr0] ?[tsym;enlist (<;`dt0;yr0);(`cwy0`dt0)!`cwy0`dt0;()] }

.hcc.dfctcwy1: { [dfcts;wrks;yr0;bd0] t0: .hcc.dfctcwy0[dfcts;yr0];
		t1: .hcc.dfctcwy0[wrks;yr0];
		a00: aj[`cwy0`dt0;t0;t1];
		a00: delete from a00 where null wrkdt0;
		a00: update days0: dfctdt0 - wrkdt0 from a00;
		a00: delete from a00 where or[(days0 <= 0);(days0 < bd0)];
		select first days0, first dfcts, first wt0 by cwy0, wrkdt0, dfctdt0 from a00 }


// weird weather metric. lowest by season
.hcc.weather2: { [rng;tsym;ms0] rng[0]: $[null rng[0]; rng[1]-ms0; rng[0] ]; rng[1]: $[null rng[1]; rng[0]+ms0 ; rng[1] ];
		w0: select avg tmin by ssn from tsym where month0 within asc rng ;
		first asc exec tmin from delete from w0 where null tmin }


\d .

.csv.d0: (raze value "\\pwd"),"/../out"
.csv.t2csv: .sch.t2csv2[;"csv";.csv.d0]


/

// Comment block
// Test block


.hcc.fdt1[2001;1]

update month0:`month${ [x] .hcc.fdt1[ x[0]; x[1] ] } each flip (yyyy;mm) from weather

// by integer
t0: `lossmonth xasc select lossmonth:`mm$lossdate from clm2
t0: select lossmonth:`mm$lossdate from clm2

// by date
t1: `lossdate xasc select distinct lossdate from clm2
t1: select lossdate from clm2


10#select ssn:.hcc.ssny2[lossmonth] from 10#t0

10#select ssn:.hcc.ssny[lossdate] from 10#t1

select count i by .hcc.ssny @ lossdate from 10#t1


// keyed table
.hcc.ssny3 @ (10#t1)[;`lossdate]

.hcc.ssny4 @ (10#t0)[;`lossmonth]

.hcc.ssny4 @ 1 + til 12

/

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
