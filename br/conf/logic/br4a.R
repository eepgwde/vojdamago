## weaves
##
## NZV to remove
## Can be called either at data-prep or before correlation

## NZV in br0

## Inspect the original source data.

## ppl0 is the source data
## br0 has nzv from earlier stages.

## Mark the ppl1 in the field rm0 to be removed.

x0 <- aggregate(ppl0[, "surftype"], list(surftype=ppl0$surftype), FUN=length)
x0 <- as.character(x0[ order(-x0$x),][1,"surftype"])

## Mark ones to remove.
x.rremove <- rownames(ppl0)[ppl0$surftype != x0]

## Flag for removal.

## These are well-known, but some I keep in (isoneway)

x.cremove <- c("lanes2", "isshared", "surftype", "isdual")

x.cremove <- append(x.cremove, br0[["nzv.names"]]$cwy1)
x.cremove <- append(x.cremove, "a0Xisshared")
x.cremove <- append(x.cremove, c("smplwtf90", "ssmplwtf90", "ssmplriskf90") )

## Logic on dataset

if (br0[["tgt0"]] == "xlocalr") {
    ## local roads are all unclassified
    x.cremove <- append(x.cremove, "iscls")
}
    
if (br0[["tgt0"]] == "xxwintryr") {
    ## local roads are all unclassified
    x.cremove <- append(x.cremove, "ssn")
}
    

## Logic in data input

src0 <- br0[["source"]]

src1 <- as.integer(gsub("[a-z\\\\/\\\\.]+", "", br0[["source"]]))

## Whole sample set
if (src1 == 1) {
    ## no need to remove anything
    ;
}

## Long roads
if (src1 == 2) {
    ## do remove things.
    ;
}

## Short roads
if (src1 == 3) {
    ## do remove things.
    x.cremove <- append(x.cremove, "distance");
}

## rural is 4, urban is 5
## isurban becomes an NZV in either case
if (src1 == 4 || src1 == 5) {
    ## do remove things.
    x.cremove <- append(x.cremove, "isurban");
}


## Remove prescient variables
source("br4a0.R") 

## The forward and backward works are NZV, but I'll leave them in.

## The PoI are also NZV, but I'll leave them in.
