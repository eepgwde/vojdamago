// weaves
// @file pop11.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key against lsoa and gender

count pop

// Just a few fields are useful.
pop1: value select by i from pop
delete lat, long from `pop1;

// Use a shorter name
pop1: .sch.rename1[cols pop1;`lsoaname;`lsoa] xcol pop1

// String matches
update desc0: string each genderandage by i from `pop1;
update male0: first { x like "Male*" } each desc0 by i from `pop1;
update male1:` from `pop1;
update male1:`male from `pop1 where male0;
update male1:`female from `pop1 where not male0;

// Some total tables
popT: select  age00: sum population by lsoa, male1 from pop1
popTx: select  age00: sum population by lsoa from pop1

// Flatten-classifications and keep pop1
update age0: population * first { x like "*0 to 15*" } each desc0 by i from `pop1;
update age1: population * first { x like "*16 to 24*" } each desc0 by i from `pop1;
update age2: population * first { x like "*25 to 49*" } each desc0 by i from `pop1;
update age3: population * first { x like "*50 to *" } each desc0 by i from `pop1;
update age4: population * first { x like "*and Over*" } each desc0 by i from `pop1;

// Prep to do the same by ward
popw: pop1

// pop2: Summarize by lsoa and gender
// join in the totals
pop2: select sum age0, sum age1, sum age2, sum age3, sum age4 by lsoa, male1 from pop1;
pop2: pop2 lj popT
// By gender, Population total and percentages thereof, no percentages
// update age0 % age00, age1 % age00, age2 % age00,  age3 % age00, age4 % age00 by i from `pop2;

// pop3: Summarize by lsoa
pop3: select sum age0, sum age1, sum age2, sum age3, sum age4 by lsoa from pop1;
pop3: pop3 lj popTx
// No percentages
// update age0 % age00, age1 % age00, age2 % age00,  age3 % age00, age4 % age00 by i from `pop3;


// for pop2: split men and women and add as columns
//

pop2f: select by lsoa, male1 from pop2 where male1 = `female;
c0: .sch.rename[cols pop2f; 2; "f"]
pop2f: c0 xcol pop2f
delete male1 from `pop2f;
`lsoa xkey `pop2f;

pop2m: select by lsoa, male1 from pop2 where male1 = `male;
c0: .sch.rename[cols pop2m; 2; "m"]
pop2m: c0 xcol pop2m
delete male1 from `pop2m;
`lsoa xkey `pop2m;

// for pop3
pop2t: select by lsoa from pop3;
c0: .sch.rename[cols pop2t; 1; "t"]
pop2t: c0 xcol pop2t

pop1: pop2t lj pop2m lj pop2f

delete pop2m, pop2t, pop2f from `.;

// * summary

.pop.summary: count pop1
.pop.summary

// * By ward

popx: popw lj lsoa2ward

popT: select  age00: sum population by ward, male1 from popx
popTx: select  age00: sum population by ward from popx

// pop2: Summarize by ward and gender
// join in the totals
pop2: select sum age0, sum age1, sum age2, sum age3, sum age4 by ward, male1 from popx;
pop2: pop2 lj popT
// By gender, Population total and percentages thereof, no percentages
// update age0 % age00, age1 % age00, age2 % age00,  age3 % age00, age4 % age00 by i from `pop2;

// pop3: Summarize by ward
pop3: select sum age0, sum age1, sum age2, sum age3, sum age4 by ward from popx;
pop3: pop3 lj popTx
// No percentages
// update age0 % age00, age1 % age00, age2 % age00,  age3 % age00, age4 % age00 by i from `pop3;

// And column join

// for pop2: split men and women and add as columns
//

pop2f: select by ward, male1 from pop2 where male1 = `female;

c0: .sch.rename[cols pop2f; 2; "f"]
pop2f: c0 xcol pop2f
delete male1 from `pop2f;
`ward xkey `pop2f;

pop2m: select by ward, male1 from pop2 where male1 = `male;
c0: .sch.rename[cols pop2m; 2; "m"]
pop2m: c0 xcol pop2m
delete male1 from `pop2m;
`ward xkey `pop2m;

// for pop3
pop2t: select by ward from pop3;
c0: .sch.rename[cols pop2t; 1; "t"]
pop2t: c0 xcol pop2t

pop1w: pop2t lj pop2m lj pop2f

delete pop2m, pop2t, pop2f from `.;

// * summary

.pop.summaryw: count pop1w
.pop.summaryw

save `:./pop1
save `:./pop1w

// Save the error workspace for reference.

`:./wspop set get `.pop

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
