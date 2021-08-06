// weaves
// @file imputes1.q

// Using q/kdb+ for the db.

// Simple re-format for the imputes1 file

\l hcc.q

imputes1: select by smpl0 from imputes0

save `:./imputes1

// Save the error workspace for reference.

// `:./wsimputes1 set get `.imputes1

// And load it again like this.
// `.imputes1 set get `:./csvdb/wsimputes1

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
