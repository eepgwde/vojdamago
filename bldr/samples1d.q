// @file samples1d.q
// @author weaves

// Adjusting forward dfcts

.sys.qreloader enlist "hcc.q"

// Store the local default results as a CSV ready for R.

.csv.t2csv[`samples1]

// Try just longer roads
samples2: 0!select by smpl0 from samples1 where 502 <= distance ;
.csv.t2csv[`samples2]
samples2: ()

// And short ones
samples3: 0!select by smpl0 from samples1 where 502 > distance ;
.csv.t2csv[`samples3]
samples3: ()


// Try rural and urban

samples4: 0!select by smpl0 from samples1 where not isurban
.csv.t2csv[`samples4]
samples4: ()

samples5: 0!select by smpl0 from samples1 where isurban
.csv.t2csv[`samples5]
samples5: ()

samples6: select by smpl0 from samples1 where (502 <= distance),(null ln),isurban

idx: -1000?count samples6			  /  use of deal

samples6: (0!samples6)[idx;]

.csv.t2csv[`samples6]

samples6: ()
								       

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

