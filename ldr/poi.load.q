/ 2018.02.04T00:34:51.013 j1 weaves
/ q poi.load.q FILE [-bl|bulkload] [-bs|bulksave] [-js|justsym] [-exit] [-savedb SAVEDB] [-saveptn SAVEPTN] [-savename SAVENAME] 
/ q poi.load.q FILE
/ q poi.load.q
/ q poi.load.q -help
FILE:LOADFILE:`$":in/poi.csv"
o:.Q.opt .z.x;if[count .Q.x;FILE:hsym`${x[where"\\"=x]:"/";x}first .Q.x]
if[`help in key o;-1"usage: q poi.load.q [FILE(default:in/poi.csv)] [-help] [-bl|bulkload] [-bs|bulksave] [-js|justsym] [-savedb SAVEDB] [-saveptn SAVEPTN] [-savename SAVENAME] [-exit]\n";exit 1]
SAVEDB:`:csvdb
SAVEPTN:`
if[`savedb in key o;if[count first o[`savedb];SAVEDB:hsym`$first o[`savedb]]]
if[`saveptn in key o;if[count first o[`saveptn];SAVEPTN:`$first o[`saveptn]]]
NOHEADER:0b
DELIM:","
\z 0 / D date format 0 => mm/dd/yyyy or 1 => dd/mm/yyyy (yyyy.mm.dd is always ok)
LOADNAME:`poi
SAVENAME:`poi
LOADFMTS:"SSSHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
LOADHDRS:`featureid`category`classification`lt0`lt25`lt50`lt75`lt100`lt125`lt150`lt175`lt200`lt225`lt250`lt275`lt300`lt325`lt350`lt375`lt400`lt425`lt450`lt475`lt500`lt525`lt550`lt575`lt600`lt625`lt650`lt675`lt700`lt725`lt750`lt775`lt800`lt825`lt850`lt875`lt900`lt925`lt950`lt975
if[`savename in key o;if[count first o[`savename];SAVENAME:`$first o[`savename]]]
SAVEPATH:{` sv((`. `SAVEDB`SAVEPTN`SAVENAME)except`),`}
LOADDEFN:{(LOADFMTS;$[NOHEADER;DELIM;enlist DELIM])}
POSTLOADEACH:{x}
POSTLOADALL:{x}
POSTSAVEALL:{x}
LOAD:{[file] POSTLOADALL POSTLOADEACH$[NOHEADER;flip LOADHDRS!LOADDEFN[]0:;LOADHDRS xcol LOADDEFN[]0:]file}
LOAD10:{[file] LOAD(file;0;1+last(11-NOHEADER)#where 0xa=read1(file;0;20000))} / just load first 10 records
JUSTSYMFMTS:"SSS                                        "
JUSTSYMHDRS:`featureid`category`classification
JUSTSYMDEFN:{(JUSTSYMFMTS;$[NOHEADER;DELIM;enlist DELIM])}
CHUNKSIZE:25000000
DATA:()
k)fs2:{[f;s]((-7!s)>){[f;s;x]i:1+last@&0xa=r:1:(s;x;CHUNKSIZE);f@`\:i#r;x+i}[f;s]/0j}
BULKLOAD:{[file] fs2[{`DATA insert POSTLOADEACH$[NOHEADER or count DATA;flip LOADHDRS!(LOADFMTS;DELIM)0:x;LOADHDRS xcol LOADDEFN[]0: x]}file];count DATA::POSTLOADALL DATA}
PRESAVEEACH:{x}
SAVE:{(r:SAVEPATH[])set PRESAVEEACH .Q.en[`. `SAVEDB] x;POSTSAVEALL r;r}
BULKSAVE:{[file] .tmp.bsc:0;fs2[{.[SAVEPATH[];();,;]PRESAVEEACH t:.Q.en[`. `SAVEDB]POSTLOADEACH$[NOHEADER or .tmp.bsc;flip LOADHDRS!(LOADFMTS;DELIM)0:x;LOADHDRS xcol LOADDEFN[]0: x];.tmp.bsc+:count t}]file;POSTSAVEALL SAVEPATH[];.tmp.bsc}
JUSTSYM:{[file] .tmp.jsc:0;fs2[{.tmp.jsc+:count .Q.en[`. `SAVEDB]POSTLOADEACH$[NOHEADER or .tmp.jsc;flip JUSTSYMHDRS!(JUSTSYMFMTS;DELIM)0:x;JUSTSYMHDRS xcol JUSTSYMDEFN[]0: x]}]file;.tmp.jsc}
if[any`js`justsym in key o;-1(string`second$.z.t)," saving `sym for <",(1_string FILE),"> to directory ",1_string SAVEDB;.tmp.st:.z.t;.tmp.rc:JUSTSYM FILE;.tmp.et:.z.t;.tmp.fs:hcount FILE;-1(string`second$.z.t)," done (",(string .tmp.rc)," records; ",(string floor .tmp.rc%1e-3*`int$.tmp.et-.tmp.st)," records/sec; ",(string floor 0.5+.tmp.fs%1e3*`int$.tmp.et-.tmp.st)," MB/sec)"]
if[any`bs`bulksave in key o;-1(string`second$.z.t)," saving <",(1_string FILE),"> to directory ",1_string` sv(SAVEDB,SAVEPTN,SAVENAME)except`;.tmp.st:.z.t;.tmp.rc:BULKSAVE FILE;.tmp.et:.z.t;.tmp.fs:hcount FILE;-1(string`second$.z.t)," done (",(string .tmp.rc)," records; ",(string floor .tmp.rc%1e-3*`int$.tmp.et-.tmp.st)," records/sec; ",(string floor 0.5+.tmp.fs%1e3*`int$.tmp.et-.tmp.st)," MB/sec)"]
if[any`bl`bulkload in key o;-1(string`second$.z.t)," loading <",(1_string FILE),"> to variable DATA";.tmp.st:.z.t;BULKLOAD FILE;.tmp.et:.z.t;.tmp.rc:count DATA;.tmp.fs:hcount FILE;-1(string`second$.z.t)," done (",(string .tmp.rc)," records; ",(string floor .tmp.rc%1e-3*`int$.tmp.et-.tmp.st)," records/sec; ",(string floor 0.5+.tmp.fs%1e3*`int$.tmp.et-.tmp.st)," MB/sec)"]
if[`exit in key o;exit 0]
/ DATA:(); BULKLOAD LOADFILE / incremental load all to DATA
/ BULKSAVE LOADFILE / incremental save all to SAVEDB[/SAVEPTN]
/ DATA:LOAD10 LOADFILE / only load the first 10 rows
/ DATA:LOAD LOADFILE / load all in one go
/ SAVE LOAD LOADFILE / save all in one go to SAVEDB[/SAVEPTN]
