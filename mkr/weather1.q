// weaves
// @file weather1.q

\l hcc.q

// -- weather - met office - Cambridge NIAB

weather1: update month0:{ `month$.hcc.fdt1[x[0];x[1]] } each flip (yyyy;mm) from weather

update yyyy:`year$month0 from `weather1;
update mm:`mm$month0 from `weather1;

update ssn:.hcc.ssny2 @ `int$mm from `weather1;

weather1: `month0 xkey `month0 xdesc weather1;

// -- luton - Luton airport
// frost can be estimated when temperature falls below zero and reaches the dew-point

// date count, change to month and to weekly.
luton1: update month0:`month$date0, mm:`mm$date0, af:0b from luton

update wk0:sums 1 = date0 mod 7 from `luton1;

// Add the ssn
update ssn:.hcc.ssny2[`mm$date0] from `luton1;

// can't get the af figures to get close
luton1: update af:1b from luton1 where (0 >= dplo),(0 >= tlo),(dplo >= tlo)
luton1: update af:1b from luton1 where (0 >= dphi),(0 >= thi),(dphi >= thi)
luton1: update af:1b from luton1 where (0 >= dpmn),(0 >= tmn),(dpmn >= tmn)

luton2: select tmax:`real$avg thi, tmin:`real$avg tlo, `short$first mm, af: `short$sum af by month0 from luton1

dts: raze exec min month0, max month0 from luton2

luton2: luton2 lj `month0 xkey ungroup select rain, sun, ssn by month0 from select by month0 from weather1 where month0 within dts

// Add the ssn again
update ssn:.hcc.ssny2[`mm$month0] from `luton2 where null ssn;

// Null rain for luton lately - use the average
rains: select `real$avg rain by mm:`mm$month0 from luton2
update rain:rains[([]mm:`mm$month0);`rain] from `luton2 where null rain;

// Negate these for a plus join
w2: select from weather1 where month0 within dts
c0: -1_3_cols w2
c1: { (neg;x) } each c0

w3: ![w2;();0b;c0!c1]

// Numeric
l2: `month0 xkey ungroup ?[luton2;();(enlist `month0)!(enlist `month0);c0!c0]
w3: `month0 xkey ungroup ?[w3;();(enlist `month0)!(enlist `month0);c0!c0]

select avg tmax, sdev tmax, avg tmin, sdev tmin, max af, min af, avg af, sdev af from l2 pj w3

// Use the precipitation information
// rn is all types of precipitation
// snw is just snow

p1: `date0 xkey ungroup select rn: { x: lower x; x like "*rain*" | x like "*storm*" | x like "*snow*" } each evnts, snw: { (lower x) like "*snow*" } each evnts by date0,wk0 from luton1

p2: select `short$sum rn, `short$sum snw by month0:`month$date0 from p1 where (`month$date0) within dts

luton2: luton2 lj p2

// Do the same for weekly weather

// TODO - better check this

luton2w: select tmax:`real$avg thi, tmin:`real$avg tlo, `short$first mm, af: `short$sum af by month0, wk0 from luton1
 
// approximate the other weather bits
luton2w: (1!0!luton2w) lj `month0 xkey ungroup select rain % 4, sun % 4, ssn by month0 from select by month0 from weather1 where month0 within dts
 
luton2w: `wk0`month0 xkey luton2w

// Add the ssn again
update ssn:.hcc.ssny2[`mm$month0] from `luton2w where null ssn;

// Null rain for luton lately - use the average
rains: select `float$avg rain by mm:`mm$month0 from luton2w
update rain:rains[([]mm:`mm$month0);`rain] from `luton2w where null rain;

luton2w1: select tmax:`real$avg thi, tmin:`real$avg tlo, `short$first mm, af: `short$sum af, last month0 by wk0 from luton1

x0: select first rain by wk0, month0 from (`month0 xkey luton2w1) lj `month0 xkey luton2w

luton2w: `month0`wk0 xkey luton2w1 lj x0

update fills rain from `luton2w;

p2: select `short$sum rn, `short$sum snw by wk0 from p1 where (`month$date0) within dts

luton2w: luton2w lj p2

save `:./weather1
save `:./luton1
save `:./luton2
save `:./luton2w


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
