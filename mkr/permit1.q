// weaves
// @file permit1.q

// Using q/kdb+ for the db.

// Load our files

.permits.ptype: `ptype xkey ("SSH"; enlist ",") 0: `:../in/ptype.csv

\l hcc.q

// Some inspection and correction.

// For each date, the count
.permits.dts: `dt xdesc select n:count i by dt:`month$enddateactual from permits
.permits.count: count permits
.permits.count

.permits.nulldates: exec count i from permits where null enddateactual

p1: value select by i from permits

update dtm0:noticeissuedate + noticeissuetime from `p1;
delete noticeissuedate, noticeissuetime from `p1;

// Not unique on workheader
count distinct p1[;`workheader]

a00: select n:count i by workheader from p1

idx0: raze exec workheader from a00 where 1 < n

// Multiple records by workheader alone.
a01: `workheader xasc select from p1 where workheader in idx0

count p1

count select count i by workheader, seqno from p1

count select count i by workheader, worksreference, seqno from p1

count select count i by workheader, dtm0, seqno from p1

// This only loses a few records and the enddateactual is more useful.
count select count i by workheader, enddateactual, seqno from p1

p1: `enddateactual`workheader`seqno xasc select by workheader, enddateactual, seqno from p1

// ** Cleaning

delete from `p1 where 2012.11.01 >= enddateactual ;

.permits.dts1: `dt xdesc select n:count i by dt:`month$enddateactual from p1

// Permits

// Empty fields.

p2: delete workingdays, responsecode, notificationleadtimeinitialapplication, enddateestimated, coordinatortimevalue, startdateproposed from p1;

// Shorter names

p2: `work0`edt0`seq0 xcol p2

c0: cols p2

c0: .sch.rename1[c0;`startdateactual;`sdt0]
c0: .sch.rename1[c0;`promotername;`pnm]

c0: .sch.rename1[c0;`organisationname;`onm]
c0: .sch.rename1[c0;`organisationcode;`oid]

c0: .sch.rename1[c0;`workscategory;`wcat0]
c0: .sch.rename1[c0;`streetcategory;`scat0]
c0: .sch.rename1[c0;`promotertype;`ptype]

c0: .sch.rename1[c0;`promoterutility;`putil]

c0: .sch.rename1[c0;`worksstate;`wstate0]

c0: .sch.rename1[c0;`trafficsensitive;`trfsens]
c0: .sch.rename1[c0;`trafficmanagement;`trfmgmt]

p2: c0 xcol p2

// traffic sensitivity: a boolean
update trfsens: trfsens = `TS from `p2;

// siteid = usrn - record invalid ones

t0: select siteid:first siteid by usrn:siteid from usrn2aid

p2: p2 lj t0

update xtype0:`usrn from `p2 where siteid <> usrn;

.permits.xtype0.usrn: exec usrn from p2 where xtype0 = `usrn;

update siteid:`usrn2aid$siteid from `p2;

.permit.usrn1: (exec count distinct usrn from p2 where xtype0 = `usrn),(exec count distinct usrn from permits)

// workscategory - wcat0 - numericize

select count i by wcat0 from p2

t0: `wcat0 xkey ([] wcat0:`Immediate`Major`Minor`Standard; wcat1:reverse `short$1 2 3 4)

.permit.wcat0: t0

p2: p2 lj t0

// promotertype - ptype; pnm and onm

p2: p2 lj .permits.ptype

.permits.hcc0: `$"HCC Works"
.permits.hcc: `Ringway`Hertfordshire,.permits.hcc0

// I used to process Transport separately, but so few.

.permits.transport: (`$"LONDON TRANSPORT"),`$"TRANSPORT FOR LONDON"
update ptype0:`Transport from `p2 where pnm in .permits.transport;

// And rejoin to set the rankings

p2: p2 lj select first ptype1 by ptype0 from .permits.ptype

p1: p2
p2:()
delete p2 from `.;

// Make a simpler key

p1: `work0`edt0`seq0 xasc p1

p1: `permit0 xkey update permit0:`${ "P", string x } each i by i from p1

permit1: p1
p1:()
delete p1 from `.;

// Record the ptype in use.
.permit.ptype: key exec count i by ptype0 from permit1


p2: `sdt0`edt0 xasc select first sdt0, first edt0, first ptype0, first siteid by permit0:`permit1$permit0 from permit1 where not null siteid
update idt0: `date$permit0.dtm0 from `p2;

p2: select by permit0 from p2 
p2: update ddt0:edt0 - sdt0 from p2

permit2: p2

a00: raze value flip key 10#p2

a01: select from permit1 where permit0 in a00

select edt0 - `date$dtm0 from a01

// Permit histories going back a year at sites.
.sys.qreloader enlist "permit1a.q"

count .permit.risk

// Write and exit

save `:./permit1
save `:./permit2

// Save the error workspace for reference.

`:./wspermit set get `.permit

// And load it again like this.
// `.permit set get `:./csvdb/wspermit

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
