// @file clm1a.q
// @author weaves

// More hand look-up errors

// clm1 - more asset codes

// Check if we have a sitecode

select count i by sitecode from clm1 where null aid

a00: select claim0, aid, siteid:"I"$string sitecode, sitecode from clm1 where (not null sitecode),(null aid)
a01: update desc0: { " " vs x } each string sitecode from a00 where null siteid

// Nothing by space.

a02: select claim0, desc0 from (select desc0, x0:count first desc0, x1: count desc0 by claim0 from a01) where or[(0 < x0);1 < x0]

a02: update desc1: first raze desc0 by i from a02

a02: update desc2: { "/" vs x } each desc1 from a02

a02: update desc3: first desc2 by i from a02


// Spot the site codes and join in, remove from our holding table.
a03: ungroup value select claim0, siteid:"I"$desc3 by i from a02 where 8 = { count x } each desc3;

a00: a00 lj `claim0 xkey a03

a02: delete from a02 where claim0 in exec claim0 from a03

// Delete what can't be mapped
a03: select claim0, desc3, n:{ x like "*[0-9]*" } each desc3 from a02
a00: delete from a00 where claim0 in exec claim0 from a03 where 0 = n

// The remainder should be aid or aid0

a01: update desc0: { "/" vs x } each string sitecode from a00 where null siteid

a02: `claim0 xkey value select by i from a01 where 1 <= count each desc0

a03: ungroup value select claim0, aid0:`$first raze desc0 by i from a02

a00: a00 lj `claim0 xkey a03

a03: select claim0, aid:sitecode from `claim0 xkey value select by i from a01 where 2 = count each desc0

a03: `claim0 xkey a03

a00: a00 lj a03

// Put any missing sitecodes in where we have an aid

a04: select first siteid by aid:featureid from usrn2aid

a05: `claim0 xkey select claim0, siteid:a04[([]aid);`siteid] from a00 where (not null aid)

a00: a00 lj a05

// And join back in

a01: delete sitecode from `claim0 xkey a00

select count i from clm1 where null aid

clm1: clm1 lj a01

a07: `claim0 xkey select claim0, aid, siteid:a04[([]aid);`siteid] from clm1 where (null siteid),(not null aid)

clm1: clm1 lj a07
