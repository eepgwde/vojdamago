// weaves
// @file cwy2.q

// Using q/kdb+ for the db.

// simplified view of the carriageways with some LSOA data in it.

`.cwy set get `:./wscwy ;
`.lsoa set get `:./wslsoa ;

// Write these two new keyed tables as files in the directory.

cwy2: select cwy0:`cwy0$featureid, siteid, isurban: `Urban = urbanrural from cwy0 ;

cwy2: cwy2 lj `cwy0`lsoa xcol delete asset_id from .lsoa.cwy

update imd:imd1[([]lsoa);`imd] from `cwy2 ;

cwy2: cwy2 lj cars1

select count i by imd0:null imd from cwy2

x0: select count i by lsoa from cwy2 where null imd
x0: x0 lj lsoa2ward
x0: delete x, nlsoa from `ward xkey x0

x1: select `real$avg imd by ward from imd1

cwy2: delete ward, nlsoa from cwy2 lj `lsoa xkey x0 lj x1


x0: select count i by lsoa from cwy2 where null ncars00
x0: x0 lj lsoa2ward


x0: (`ward xkey x0) lj cars1w
c0: 1_cols cars1w
x1: select first nlsoa by ward from x0

// Use a dictionary and a global
.t.d0: .Q.V x0
{ .t.d0[x]: `int$.t.d0[x] % .t.d0[`nlsoa] } each c0;
.t.d0: flip .t.d0
// set columns
c1: (cols .t.d0) except c0
c2: c1, 1 _ cols cars1
.t.d0: c2 xcol .t.d0
x2: `lsoa xkey delete nlsoa, ward, x from .t.d0

cwy2: cwy2 lj x2

save `:./cwy2

// And load it again like this.
// `.rci set get `:./csvdb/wsrci

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
