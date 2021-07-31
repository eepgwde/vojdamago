// weaves
// @file dfct1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key  against cwy

// For each date, the count
.dfct.dts: `dt xdesc select n:count i by dt:`date$defectdate0 from dfct

// New table, with locator in xref0
dfct1: value select by i from dfct
update xref0:` from `dfct1;

ftre0: select by assetid:aid from ftre

update xref0:ftre0[([]assetid);`type0] from `dfct1;


ftre0: select type1:`aid00 by aid00 from ftre

update aid00: `$first { "/" vs x } each string assetid by i from `dfct1;

dfct1: delete said, aid00 from update xref0: ftre0[([]aid00);`type1] from dfct1 where null xref0

dfct1: `defectnumber xkey dfct1
dfct1: `dfct0 xcol dfct1
delete defectdate from `dfct1;

// Change column names

c0: cols dfct1

c1: string each c0

c1: { ssr[x;"defect";""] } each c1
c1: { ssr[x;"date";"dt"] } each c1
c1: { ssr[x;"type";"type0"] } each c1

c1: { ssr[x;"assetid";"featureid"] } each c1

dfct1: (`$c1) xcol dfct1

dfct1: `featureid`dt0`dfct0 xcols 0!dfct1

// Some duplicates by featureid and defect date so add a minor time adjustment to the second one.

a00: select dfct0 by featureid, dt0 from dfct1

a00: update n: count raze dfct0 by featureid, dt0 from a00

a01: select from a00 where 1 < n

dds: value exec (raze dfct0)[1] by featureid, dt0 from a01

// A tenth of a second.
.dfct.f0: 1 % (24 * 60 * 60 * 10)

dfct1: update dt0:dt0 + .dfct.f0 from dfct1 where dfct0 in dds

dfct1: `dfct0 xkey dfct1

.dfct.cwycount: select count i from dfct1 where xref0 = `cwy
.dfct.fwycount: select count i from dfct1 where xref0 = `fwy

// Foreign keys - split off the footway keys, make a second table with foreign key back to dfct1

kcwy: raze value flip key cwy0
kdfct: (0!dfct1)[;`featureid]

kncwy: kdfct except kcwy;

// ** cleaning

// Some are floats.

update jobnumber:"I"$string each jobnumber from `dfct1;
update assetnumber:"I"$string each assetnumber from `dfct1;

update supersedes:"I"$string each supersedes from `dfct1;

// ** classifying

select count i by status from dfct1

// action0 is whether Action Required appears in status.
update action0:0b from `dfct1;
update action0:1b from `dfct1 where status = `$"Action Required";

select count i by action0 from dfct1

// defecttype and defectypename - type0 and type0name
.tmp.dfct: dfct1
.sys.qreloader enlist "dfct1c.q"
dfct1: .tmp.dfct

select count i by ntype3 from dfct1

dfct1: `dfct0 xasc dfct1

select count i by ntype3 from dfct1

// After the enquiry is logged, it is a candidate for inspection.
// inspct0 is set by using supersede 

// cat0 and resp0 are the priority of response and the response days
// cat0 is 1 emergency/CAT1, 2 CAT2(High|Low|Medium), 2 Urgent, 2 Cat2, 3 Permanent, 6 No code allocated.

/

// This is the original file for priority dfctpriority

t0:0!select count i by priorityname,prioritycode from dfct1

.sch.t2csv[`t0]

\

.dfct.priority1: ("SSH F"; enlist ",") 0: `:../in/dfctpriority.csv
.dfct.priority1: delete priorityname from select by prioritycode from .dfct.priority1

dfct1: dfct1 lj .dfct.priority1

// statuscode statusname 
// are simplified to status0 status1 phase0 all joined in

// status is the ongoing state of the job.

/

// This is the original file for dfctstatus.csv

t1: 0!select count i by statuscode, statusname from dfct1
.sch.t2csv[`t1]

\

// Load in the version with status0, status1 and phase0
// Use both keys because of the NCA type

.dfct.status: ("HSSSH"; enlist ",") 0: `:../in/dfctstatus.csv
.dfct.status: select by statuscode, statusname from .dfct.status

// Add a quantification of status1
// Use a decimal scheme
.dfct.status1: `status1 xkey ([] status1:`nothing`noaction`permit`action; status2:1 10 100 1000) 

dfct1: dfct1 lj .dfct.status
dfct1: dfct1 lj .dfct.status1

// The first stage of a enquiry is a report with no jobnumber and a status0 of report.
// Then a job is allocated. There is only one job for each defect.

// inspct0 has yet to be set see dfct1b.q
// 
// valid reports: cancel close refer

// superseded records are dealt with in dfct1b.q
// Just flag them for now.

a00: raze value flip key select count i by supersedes from dfct1

a01: select from dfct1 where dfct0 in a00

// delete from `dfct1 where dfct0 in a00;

update superseded:0b from `dfct1;
update superseded:1b from `dfct1 where dfct0 in a00;

// Add siteid a lookup of usrn to make keying easier

// Not good matching with this.
select usrn, usrn2aid[([]siteid:usrn);`siteid] from dfct1

// Try to use the featureid
t0: select first siteid by featureid from usrn2aid
dfct1: dfct1 lj t0
// and then re-key
update siteid:`usrn2aid$siteid from `dfct1;

// New table with keys: carriageway table

dfct2: select dfct0:`dfct1$dfct0, dt0, dt1:`date$dt0, siteid from dfct1 where featureid in kcwy
update dfct0:`dfct1$dfct0 from `dfct2;
update cwy:`cwy0$dfct0.featureid from `dfct2;

dfct2: `dfct0 xasc select by dfct0 from dfct2

// 30 day defect count
// All need to be classified
select count dt0 by 30 xbar `date$dt0, cwy from 0!dfct2

// Key it for date searchs

dfct2: `dt0`cwy xasc `cwy`dt0 xkey dfct2

.dfct.dfct0: "Carriageway only"

// Checking types
x0: 0!select priority:count i by dfct0.type0, dfct0.type0name from dfct2

// Supersedes records
// Oops! This screws up all the dates!

.sys.qreloader enlist "dfct1b.q"

dfct2: `dfct0 xasc 0!dfct2

// TODO
// An issue with aggregating with foreign keys means that dfctrisk has to be changed
// to use direct values - but does work with rfr0

a01: `dfct0 xasc select first action1, first inspct0, first cat0, first resp0, first rfr0, first phase0, first status1, first status2 by dfct0 from dfct1 

dfct2: `dfct0 xasc dfct2 lj a01

// Summary metrics
// This seems to break the system. Maybe the .dfct.risk is too big?

.sys.qreloader enlist "dfct1a.q"

a01:select count i by yr0:`year$dt0, action1, status0 from dfct1 

count .dfct.risk

// * summary

`n xdesc select n:count i by cwy from dfct2

.dfct.summary: select count i by xref0 from dfct1
.dfct.summary

// Write out

save `:./dfct1
save `:./dfct2

// Save the error workspace for reference.

`:./wsdfct set get `.dfct

// And load it again like this.
// `.dfct set get `:./csvdb/wsdfct

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
