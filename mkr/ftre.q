// weaves
// @file ftre.q

// Using q/kdb+ for the db.

// Some inspection and correction. This should be run before the others.

// After rci1 that makes cwy0

// assets and assets with features

cwy1: select asset:assetid, aid:featureid, x:string featureid, type0:`cwy from cwy0

update seg0:0b from `cwy1;
f: { any "/" = x }
update seg0: { f[x] } each x from `cwy1;

update assetid:x from `cwy1 where not seg0;

update aid0:enlist "" by i from `cwy1;

update y:{ "/" vs x } each x from `cwy1 where seg0;

cwy1: delete y from update aid0:{ first x } each y, aseg0: { raze 1 _ x } each y from cwy1 where seg0

ftre: delete x from cwy1

ftre: delete assetid from update aid0:string aid from ftre where not seg0
ftre: update aseg1: enlist "" by i from ftre
ftre: delete aseg0 from update aseg1: aseg0 by i from ftre where seg0

ftre: .sch.rename1[cols ftre;`aseg1;`aseg0] xcol ftre

ftre: `aid xkey update aid0: `$aid0, aseg0:`$aseg0 from ftre

// Do the same for footways
// Added twist is that footways often have two parts

fwy1: select asset:centralassetid, aid:assetid, aid0:featureidalias from fwy

f: { [x;y] x:string x; y: string y; a:ssr[x;y;""]; a; ssr[a;"/";""] }

x0:value select first aid, aseg0:{ [x;y] f[first x;first y] }[aid;aid0] by i from fwy1

fwy1: x0 lj `aid xkey fwy1

update seg0:1b, type0:`fwy, aseg0:`$aseg0 from `fwy1;
update seg0:0b from `fwy1 where aid = aid0;

fwy1: (cols 0#ftre) xcols fwy1

ftre:fwy1,0!ftre

// Not good enough for footways, another level needed

ftre1: update said: { "/" vs x } each string aid by i from ftre

ftre: delete said from update aid00: `$first said by i from ftre1

// footways catalogue
// Add the aid00 link for ftre.

fwy0: `assetid xkey value select by i from fwy

fwy0: delete said from update aid00:`$first said by i from update said: { "/" vs x } each string assetid by i from fwy0

// Write any new keyed tables as files in the directory.

// Record the distinct keys.

.ftre.keys: `asset`aid`aid0`aid00!(count exec distinct asset from ftre; count exec distinct aid from ftre; count exec distinct aid0 from ftre; count exec distinct aid00 from ftre)

fwy1: ()
delete fwy1 from `.;

cwy1: ()
delete cwy1 from `.;

save `:./ftre
save `:./fwy0

// Save the error workspace for reference.

// `:./wsftre set get `.ftre

// And load it again like this.
// `.ftre set get `:./csvdb/wsftre

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
