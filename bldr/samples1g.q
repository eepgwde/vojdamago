// @file samples1g.q
// @author weaves

// Appending monthly histories - enquiries - dfcts and prmts are asset and siteid
// It's just a join. The records include themselves so no need to impute.

// By asset-id

n0: first .tmp.n0

0N!count .samples.dfcts[n0];

b00: `cwy`date0 xkey `cwy`date0 xcol .samples.dfcts[n0]

tsamples1: .tmp.samples1

tsamples1: `date0`cwy0 xasc tsamples1 lj `cwy0 xcol b00


// By site-id

0N!count .samples.prmts[n0];

b00: `siteid`date0 xkey `siteid`date0 xcol .samples.prmts[n0]

// Bit of a problem with this. The site metric includes the asset and if it is the only
// asset, then the ssmpl is the same.

// The double colon is assign to above view.
tsamples1: tsamples1 lj b00

0N!" " sv string reverse cols tsamples1;

.tmp.samples1: tsamples1

tsamples1: ()
delete tsamples1 from `.;


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
