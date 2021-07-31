// weaves
// @file traffic1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key  against cwy

// For each date, the count
.traffic.qs: `n xdesc select n:count i by roadtype from traffic0

// New table, with key back to traffic1
// Make a keyed table of the splay.
// Check the percentages of traffic

traffic1: select by oid:objectid from traffic0

// TODO
// I've used aadtcomb, rather than aadtini.
// But they vary hugely.

// IMPUTATION
update aadtcomb:aadtini from `traffic1 where (aadtcomb = 0),(aadtini <> 0);

// Remove the zero traffic records

delete from `traffic1 where aadtcomb = 0;

// Adjust percentages

update aadpctT:adtpct01 + adtpct02 + adtpct03 + adtpct04 + adtpct05 + adtpct06 from `traffic1;

// There are zeroes, they come through as 0w.
update aadpctT1: 100 % aadpctT from `traffic1;

// Use traffic2 to key back to it

traffic2: select oid:`traffic1$oid from traffic1

ftre1: .sch.keyembed[ftre;`asset;`assetid]
update asset: ftre1[([]assetid:oid.assetid);`asset] from `traffic2;

ftre1: .sch.keyembed[ftre;`aid;`featureid]
update aid: ftre1[([]featureid:oid.featureid);`aid] from `traffic2;

// aid0 is a split and there is no aid00
update said: { "/" vs x } each string oid.featureid from `traffic2;
update nsaid: count raze said by i from `traffic2;
update aid0: `$first said by i from `traffic2;

// check: no nsaid > 2 here.
select count i by nsaid from traffic2

ftre1: .sch.keyembed[ftre;`aid00;`aid01]
update aid0: ftre1[([]aid01:aid0);`aid00] from `traffic2;

delete said, nsaid, x from `traffic2;

// Remove the traffic records where there is no keying aid0

.traffic.nullinfo: select oid, oid.sitename from traffic2 where (null aid0)

// Absolutely nothing can be done with these.
delete from `traffic2 where (null aid),(null aid0);

// These could be imputed.
delete from `traffic2 where null aid;


// Check the keys

trf1: distinct traffic0[;`assetid]
ftre2: ftre[;`asset]

// missing
.traffic.keys: ()!()
.traffic.keys[`asset]: count trf1 except ftre2

// TODO: these roads are missing from the carriageway inventory.
// Assume they are not under HCC control.
.traffic.missing: trf1 except ftre2

trf1: distinct traffic0[;`featureid]
ftre2: ftre[;`aid]

.traffic.keys[`featureid]: count trf1 except ftre2

// Key to the carriageways cwy0
update aid:`cwy0$aid from `traffic2;

// * TODO AADT Average annual daily traffic
update aadt:oid.aadtcomb from `traffic2;

traffic2: `aid xasc traffic2

// Failed to impute: delete records with 0w

.traffic.nopct1: select oid, aid, aid0 from traffic2 where oid.aadpctT1 = 0w

delete from `traffic2 where oid.aadpctT1 = 0w;

// I'm adjusting this the percentages don't add up, so I apply the scaling factor.
// aadpctT1 calculated above. You can see the odd ones in aadpctT.

update aadt, aadt1:aadt * (oid.aadpctT1 * oid.adtpct01 % 100), aadt2:aadt * (oid.aadpctT1 * oid.adtpct02 % 100), aadt3:aadt * (oid.aadpctT1 * oid.adtpct03 % 100), aadt4:aadt * (oid.aadpctT1 * oid.adtpct04 % 100), aadt5:aadt * (oid.aadpctT1 * oid.adtpct05 % 100), aadt6:aadt * (oid.aadpctT1 * oid.adtpct06 % 100 ) from `traffic2;

update oid.aadpctT, aadt0: 1.0e3 < abs aadt - ( aadt1 + aadt2 + aadt3 + aadt4 + aadt5 + aadt6 ) from `traffic2;

delete aadt0 from `traffic2;			  /  just a marker.

// Some sums are empty.

t0:select sum aadt, sum aadt1, sum aadt2, sum aadt3, sum aadt4, sum aadt5, sum aadt6 from traffic2

// TODO: Cross-reference the qualities to the carriageway classes.
// ASSUMPTION: if they match, then find average loads for those classes

// Not this: all LOCAL 2.
select count i by oid.hcchier from traffic2

// but the cwy0 has better descriptions
select aid.assetid, oid.assetid,  oid.aadtini, oid.aadtcomb, oid.hcchier, aid.hierarchy from traffic2

// Not all traffic has an cwy asset

// Fixed - is now zero
select from (select aid.assetid, oid.assetid,  oid.aadtini, oid.aadtcomb, oid.hcchier, aid.hierarchy from traffic2) where (assetid = assetid1),(aadtcomb = 0)

// Some assets don't match 
select count i from (select aid.assetid, oid.assetid,  oid.aadtini, oid.aadtcomb, oid.hcchier, aid.hierarchy from traffic2) where assetid <> assetid1


select aid.assetid, oid.assetid,  oid.aadtini, oid.aadtcomb, oid.hcchier, aid.hierarchy from traffic2

// Look into carriageway for things


select count i by roadtype, roadtypehw from cwy0

select count i by oid.roadtype from traffic2

// roadhierarchy

select count i by roadhierarchy from cwy0

// * summary

.traffic.summary: select count i by aid.roadtype,aid.roadtypehw from traffic2
.traffic.summary


save `:./traffic1
save `:./traffic2

// Save the error workspace for reference.

`:./wstraffic set get `.traffic

// And load it again like this.
// `.traffic set get `:./csvdb/wstraffic

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
