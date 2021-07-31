// weaves
// @file salting1.q

// Using q/kdb+ for the db.

// Some inspection and correction.

// -- Key  against cwy

.salting.cols: (cols salting) where { x like "*salt*" } each string cols salting

// Just take prior years which I think are in salttype

salting1: delete objectid from select by oid:objectid from salting where not null salttype

salting2: select oid:`salting1$oid from salting1
update salttype:oid.salttype from `salting2;

ftre1: .sch.keyembed[ftre;`asset;`assetid]
update asset: ftre1[([]assetid:oid.assetid);`asset] from `salting2;

ftre1: .sch.keyembed[ftre;`aid;`featureid]
update aid: ftre1[([]featureid:oid.featureid);`aid] from `salting2;

// aid0 is a split and there is no aid00
update said: { "/" vs x } each string oid.featureid from `salting2;
update nsaid: count raze said by i from `salting2;
update aid0: `$first said by i from `salting2;

// check: no nsaid > 2 here.
select count i by nsaid from salting2

ftre1: .sch.keyembed[ftre;`aid00;`aid01]
update aid0: ftre1[([]aid01:aid0);`aid00] from `salting2;

delete said, nsaid, x from `salting2;

delete from `salting2 where or[(null asset);(null aid)];


// * summary

.salting.summary: select count i by oid.salttype from salting2
.salting.summary

save `:./salting1
save `:./salting2

// Save the error workspace for reference.

`:./wssalting set get `.salting

// And load it again like this.
// `.salting set get `:./csvdb/wssalting

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
