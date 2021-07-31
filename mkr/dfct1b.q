// @file dfct1b.q
// @author weaves

// Events for dfcts

// This processes the dfct1 superseded records.
// And assigns the originating/root/first record to the field dfct00.
// This is then used to spot the inspection (when the code changes) and
// the work.

.sys.qreloader enlist "hcc.q"

// All those that have have a supersede

a00:select dfct0, supersedes from dfct1 where not null supersedes
a00:`dfct0 xasc `dfct0 xkey a00

back0: .hcc.supercede[`dfct1;;`supersedes]

// ** batch

roots0: ([] dfct00:`int$() ; spr0:() )

keys0: raze value flip key a00

// Takes a long time
{ [x;tbl] ss0: back0 @ x; tbl insert (first ss0;1_ss0); }[;`roots0] each keys0 ;

// Not unique records, merge them
roots1: select spr1:distinct raze spr0 by dfct00 from roots0
roots2: `spr1 xkey ungroup roots1
roots2: `dfct0`dfct00 xcol roots2

dfct1: dfct1 lj roots2

update dfct00:dfct0 from `dfct1 where null dfct00;

// Re-organise the columns

c0: `dfct0`dfct00`featureid`dt0`ntype1`ntype3`ntype2`cat0`resp0`type0`type0name`jobnumber`action0`status0`status1`prioritycode`priorityname`statusname
c1: (cols dfct1) except c0

// Count the number of records in the dfct00 and append
a01: `dfct00`dfct0 xasc `dfct0 xkey (c0,c1) xcols 0!dfct1
a03: `nenq xdesc select nenq:count i by dfct00 from a01
a04: `nenq`dfct00 xdesc `dt0 xasc a01 lj a03

dfct1: `nenq`dfct00 xdesc `dt0 xasc a04

.dfct.action1: `completed`closed`repaired`safed`audit

// TODO
// 2013 and 2014 do not record actions in dfctrisk?

update action1:0b by dfct0 from `dfct1;

update action1:1b by dfct0 from `dfct1 where (status0 in .dfct.action1),(not null jobnumber);

a01:select count i by yr0:`year$dt0, action1, status0 from dfct1 

// Processing status0

// if report and a job number maybe also inspected.

// if a job number then
// and in 

.dfct.inspct0: `future`accepted`nofault`defer`unable`raised`inspected`cancel`unfound`refer`duplicate`client

update inspct0:0b by dfct0 from `dfct1;
update inspct0:1b by dfct0 from `dfct1 where (status0 in .dfct.inspct0), (not null jobnumber);

// If it's in .dfct.action1 and only one dfct, it must have be inspct0

select count i by action1, status0 from dfct1 where (status0 in .dfct.action1),(not null jobnumber)

update inspct0:1b by dfct0 from `dfct1 where (status0 in .dfct.action1), (not null jobnumber), (1 = nenq);

a00: `dfct0 xasc dfct1

// Tag the referalls

update rfr0:0b by dfct0 from `dfct1;
update rfr0:1b by dfct0 from `dfct1 where (not status0 in .dfct.inspct0), (not status0 in .dfct.inspct0);


// Check coverage

select count i by action1, status0 from dfct1 where (status0 in .dfct.action1),(not null jobnumber)

select count i by inspct0, status0 from dfct1 where (status0 in .dfct.inspct0),(not null jobnumber)


`x xdesc select count i by action0, inspct0, action1, status0 from dfct1 where (not null jobnumber), (1 = nenq)

select count i by action1, status0 from dfct1 where (1 = nenq), action1

select count i by action1, inspct0 from dfct1


// These reports are duplicates

a07: `nenq`dfct00 xdesc `dt0 xasc select by dfct0 from dfct1 where (status0 = `report),(not null jobnumber)

select count i by statusname from a07

a08: exec distinct jobnumber from dfct1 where (status0 <> `report), not null jobnumber

a09: exec distinct jobnumber from a07

a09 inter a08 

roots0: roots1: roots2: ()
delete roots0, roots1, roots2 from `.;
a00: a01: a03: a04: ()
delete a00, a01, a03, a04 from `.;

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
