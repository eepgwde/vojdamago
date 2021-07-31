// weaves
// @file cars1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key against lsoa

// carsinhousehold is a symbol

count cars

// Just a few fields are useful.
cars1: value select by i from cars
delete lat, long from `cars1;

// Use a shorter name
cars1: .sch.rename1[cols cars1;`lsoaname;`lsoa] xcol cars1
cars1: .sch.rename1[cols cars1;`carsinhousehold;`ncars] xcol cars1
cars1: .sch.rename1[cols cars1;`numberofhouseholds;`nhhs] xcol cars1

cars1: select first nhhs by lsoa, ncars from cars1

// String matches
update desc0: string each ncars by i from `cars1;

// update ncars0: { `short$"I"$first " " vs x } each desc0 from 10#reverse `cars1

update ncars0: { `short$"I"$first " " vs x } each desc0 from `cars1;

delete ncars, desc0 from `cars1;

cars1: 0!select sum nhhs by lsoa, ncars0 from cars1

update ncars: { `$"ncars", string x } each ncars0 from `cars1;

cars1: select sum nhhs by lsoa, ncars from cars1

// TODO
// stacking: I once wrote a script to do this.
// Note: first and sum are the same here
t0: select ncars0:sum nhhs by lsoa from cars1 where ncars = `ncars0 ;
t0: t0 lj select ncars1:sum nhhs by lsoa from cars1 where ncars = `ncars1;
t0: t0 lj select ncars2:sum nhhs by lsoa from cars1 where ncars = `ncars2;
t0: t0 lj select ncars3:sum nhhs by lsoa from cars1 where ncars = `ncars3;
t0: t0 lj select ncars4:sum nhhs by lsoa from cars1 where ncars = `ncars4;
t0: t0 lj select ncars00: sum nhhs by lsoa from cars1;

// A check that summing is fine.
// a1: update x0:ncars0 + ncars1 + ncars2 + ncars3 + ncars4 by lsoa from t0

// Store in a9 for now. No percentages
// a9: update ncars0: ncars0 % ncars00, ncars1: ncars1 % ncars00, ncars2: ncars2 % ncars00, ncars3: ncars3 % ncars00, ncars4: ncars4 % ncars00 by lsoa from t0;
a9: t0
a9: `ncars4 xdesc a9

// By ward and use sum!

cars2:delete lsoa from 0!cars1 lj lsoa2ward

t0: select ncars0w:sum nhhs by ward from cars2 where ncars = `ncars0 ;
t0: t0 lj select ncars1w:sum nhhs by ward from cars2 where ncars = `ncars1;
t0: t0 lj select ncars2w:sum nhhs by ward from cars2 where ncars = `ncars2;
t0: t0 lj select ncars3w:sum nhhs by ward from cars2 where ncars = `ncars3;
t0: t0 lj select ncars4w:sum nhhs by ward from cars2 where ncars = `ncars4;
t0: t0 lj select ncars00w: sum nhhs by ward from cars2;

// A check that summing is fine.
// a1: update x0:ncars0w + ncars1w + ncars2w + ncars3w + ncars4w by ward from t0

// Store in a9 for now, no percentages
// a8: update ncars0w: ncars0w % ncars00w, ncars1w: ncars1w % ncars00w, ncars2w: ncars2w % ncars00w, ncars3w: ncars3w % ncars00w, ncars4w: ncars4w % ncars00w by ward from t0;
a8: t0
a8: `ncars4w xdesc a8

// * summary

.cars.summary: count a9
.cars.summary

// * summary

.cars.summaryw: count a8
.cars.summaryw

// tcars by lsoa

tcars1: value select by i from tcars

delete lat, long, lsoacode from `tcars1;

tcars1: `lsoa xkey `lsoa`tcars0 xcol tcars1

a9: a9 lj tcars1

// tcars by ward
a7: tcars1 lj lsoa2ward
a7: select tcars0w: sum tcars0 by ward from a7

a8: a8 lj a7

// Finally copy over

cars1: a9
cars1w: a8

// Missed some types

update tcars0:`int$tcars0 from `cars1;
update tcars0w:`int$tcars0w from `cars1w;

// And write

save `:./cars1
save `:./cars1w

// Save the error workspace for reference.

`:./wscars set get `.cars

// And load it again like this.
// `.inc set get `:./csvdb/wsinc

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
