// @author weaves
// @file 2csv.q
// Write all to CSV files

// write to the cache directory

\l hcc.q

// Get a list of tables now

tbls: tables `.

// Do the specials

// Gone to dcover0.q and tables0.q 

// And these are standard

tbls: tbls except `usrn2aid

{ .csv.t2csv[x] } each tbls;

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
