// weaves
// @file wear1.q

// Wear matrix for the assets

// Load our files

// Find the date range

x00: 0!select src0:`dfct, n:count i, nassets:count distinct assetid by month0:`month$defectdate from dfct
x00,: 0!select src0:`clm1, n:count i, nassets:count distinct `$roadidfeatureid by month0:`month$lossdate from clm
x00,: 0!select src0:`permits, n:count i, nassets:count distinct usrn by month0:`month$noticeissuedate from permits
x00,: 0!select src0:`rci, n:count i, nassets:count distinct centralassetid by month0:`month$surveyfeatend0 from rci1
x00,: 0!select src0:`enq, n:count i, nassets:count distinct assetid by month0:`month$enquirytime0 from enq

d0: exec min modifiedda from traffic0
t00: update modifiedda:d0 from traffic0 where null modifiedda

x00,: 0!select src0:`traffic, n:count i, nassets:count distinct featureid by month0:`month$modifiedda from t00

dates0: exec min month0, max month0 from (select tag0: 4 <= count src0, sum n by month0 from x00) where tag0
dates0: asc raze value dates0

// Only those with mtraffic records. Take keys
cwys: 5#raze value flip key select by featureid from  cwy0 where not null mtraffic

// Make groups of months
nmnth: (-/) reverse dates0
m0: (first dates0) + til nmnth

// Keyed table: keys and groups of months
t0: ([cwy0:cwys] dt0: (count cwys)#enlist m0 )
t0: ungroup t0

// Join in the mtraffic date
t1: t0 lj `cwy0 xkey `cwy0 xcol select first mtraffic where not null mtraffic by featureid from cwy0

\

// deltas on value
// fourth power

.wear.axle: 4
.wear.dpm: 30
.wear.lfmnths: `int$floor (10*12) * 1 + 0.08

wealths: ([] mtraffic: asc distinct (0!cwy0)[;`mtraffic])

wealths: update mtraffic1: .wear.lfmnths * .wear.axle * (log .wear.dpm) + log mtraffic by mtraffic from wealths

.wear.min: exec min mtraffic1 from wealths where (not null mtraffic),(0 < mtraffic) 

wealths: update mtraffic1: .wear.min by i from wealths where or[(null mtraffic);(0 >= mtraffic)] 




.wear.df: { [mttl] 1 + log  (reverse 1 + til mttl) % mttl }

.wear.df: { [mttl] x:(log mttl) + log  (reverse 1 + til mttl) % mttl; x % max x }



t3: update mtraffic2: .wear.df[count i] by cwy0 from t2

t4: update mtraffic3: mtraffic1 * mtraffic2 from t3

t4: update mtraffic4: sums mtraffic1 - mtraffic3 by cwy0 from t4

.wear.wv: { [age;iwlth;

// test

.wear.f[12 * 10]



\

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
