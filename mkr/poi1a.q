// @file poi1a.q
// @author weaves

// Accumulate some interesting features

.poi.features: (`$"Bus Stops"),(`$"Railway Stations, Junctions and Halts")
.poi.features1: `nbus`nrail

.tmp.tag: `nhospital
.tmp.str: "*Hospital*"
x0: exec classification from .poi.classes where { x like .tmp.str } each string classification
.poi.features,:x0
.poi.features1,:(count x0)#.tmp.tag

.tmp.tag: `nschool
.tmp.str: "*Schools*"
x0: exec classification from .poi.classes where { x like .tmp.str } each string classification
.poi.features,:x0
.poi.features1,:(count x0)#.tmp.tag

.tmp.tag: `nsupermkt
.tmp.str: "*Supermarket *"
x0: exec classification from .poi.classes where { x like .tmp.str } each string classification
.poi.features,:x0
.poi.features1,:(count x0)#.tmp.tag

.tmp.tag: `nhotel
.tmp.str: "*Hotels, *"
x0: exec classification from .poi.classes where { x like .tmp.str } each string classification
.poi.features,:x0
.poi.features1,:(count x0)#.tmp.tag

.tmp.tag: `nhotel
.tmp.str: "*Pubs, *"
x0: exec classification from .poi.classes where { x like .tmp.str } each string classification
.poi.features,:x0
.poi.features1,:(count x0)#.tmp.tag

// Make a table

.poi.features0: ([] cls0: .poi.features; tag0:.poi.features1)

poise: select cls0 by tag0 from .poi.features0
poise

// Apply some weighting, used in the function.

.poi.n0: count .hcc.poi1[100;1]  / any number will do.

.poi.lambda: 10                / down to 0.5 by 10.
.poi.weights: .hcc.ewma1[(1, (.poi.n0 - 1)#0); .poi.lambda] / step response

// assign to a global
.poi.tables0: { [x;y] .hcc.poiftr[poi1;x[1];x[0];y] }[;2] each exec flip (tag0;cls0) from 0!poise

`n xdesc select n:count i by value0: 1 xbar nbus from .poi.tables0[0]


\l hcc.q

.poi.summary: raze { [tbl;bar0] .hcc.coverage0[tbl;bar0] }[;1] each .poi.tables0;

`n xdesc .poi.summary

{ c0: last cols x; sum 0 >= (0!x)[;c0] } each .poi.tables0

/

// Some testing


// Can we weight down?

b0: select from poi1 where (classification = .poi.features[0]),(featureid in `051026A`051024B) ;

v0: .hcc.poiftr[poi1;.poi.features[0];`nbus0;2]

// count v0
// 10#`nbus0 xdesc v0

dist1: .hcc.poi1[975]

a00: select count0: sum (raze dist1) * flip deltas each flip (lt0;lt25;lt50;lt75;lt100;lt125;lt150;lt175;lt200;lt225;lt250;lt275;lt300;lt325;lt350;lt375;lt400;lt425;lt450;lt475;lt500;lt525;lt550;lt575;lt600;lt625;lt650;lt675;lt700;lt725;lt750;lt775;lt800;lt825;lt850;lt875;lt900;lt925;lt950;lt975) by i from b0;

a01: select range0: sum .poi.weights * (raze dist1) * flip deltas each flip (lt0;lt25;lt50;lt75;lt100;lt125;lt150;lt175;lt200;lt225;lt250;lt275;lt300;lt325;lt350;lt375;lt400;lt425;lt450;lt475;lt500;lt525;lt550;lt575;lt600;lt625;lt650;lt675;lt700;lt725;lt750;lt775;lt800;lt825;lt850;lt875;lt900;lt925;lt950;lt975) by i from b0;

a00: `count0 xdesc a00

x0: 0   0    0    0    1     2     2     2     5     5     8     9     10    11    11    12    13    14    15    16    18    19    21    21    23    23    26    29    31    31    31    31    31    32    32    33    35    36    37    37

deltas x0

((0!b0)[;`lt0];(0!b0)[;`lt25])

\