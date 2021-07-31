// @author weaves
// @file enq1a.q
// Function script : splitting assetid to calculate aid and aid0 lookups in ftre
//
// Globals: eg. split on .tmp.str look for .tmp.xref0 refine to .tmp.xref1
// .tmp.str: "/"
// .tmp.xref0: `slash
// .tmp.xref1: `xslash

sl0: select distinct assetid from enq1 where xref0 = .tmp.xref0;

update assetid, aid: { .tmp.str vs x } each string assetid, sl:{ count x ss .tmp.str } each string assetid by i from `sl0;

select distinct sl from sl0

select from sl0 where 1 < sl

update aid0: { `$first x } each aid, aseg0: { `$x[1] } each aid by i from `sl0;

// keyed lookup.
idx1:.enq.sl1: ([] aid0:sl0[;`aid0])#ftre1

// assetid where not known aid0 in ftre (for slash)
idx1: ungroup select assetid by aid0 from sl0 where aid0 in exec aid0 from idx1 where null aid

// these become xslash
update xref0:.tmp.xref1 from `enq1 where (xref0 = .tmp.xref0), assetid in idx1[;`assetid];

idx1:.enq.sl1

idx1: select first aid0 by assetid from sl0 where aid0 in exec aid0 from idx1 where not null aid

update ftre1:idx1[([]assetid);`aid0] from `enq1 where xref0 = .tmp.xref0;
