// weaves
// @file hcc-val0.q

// Validation and dataset selection/marking

// Enquiries

enq2: update month0:`month$enquirytime0 from enq1

update dt0:(`date$loggeddate0) - `date$enquirytime0, dt1:(`date$followupdate0) - `date$enquirytime0, dt2:(`date$loggeddate0) - `date$followupdate0 from `enq2;

e0: `enquirytime0 xdesc select enquirytime0, loggeddate0, followupdate0 from enq2

e1: `lossdate xdesc value select by i from clm



\

e0: `month0 xdesc select n:count i, nassets: count distinct assetid by subjectname, month0 from enq2

e1: `n0 xdesc select n0:count i by enqstatusname from enq2

e2: `month0 xdesc select n:count i, nassets: count distinct assetid by subjectname, month0 from enq2 where enqstatusname in (`$"This Record has been closed";)

\


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


