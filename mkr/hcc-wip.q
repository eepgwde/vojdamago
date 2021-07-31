// weaves
// @file hcc-wip.q

luton1: update month0:`month$date0, mm:`mm$date0, af:0b from luton

update wk0:sums 1 = date0 mod 7 from `luton;

luton2w: select tmax:`real$avg thi, tmin:`real$avg tlo, `short$first mm, af: `short$sum af by month0, wk0 from luton1

luton2w: (1!0!luton2w) lj `month0 xkey ungroup select rain % 4, sun % 4, ssn by month0 from select by month0 from weather1 where month0 within dts

luton2w: `month0`wk0 xkey luton2w


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


