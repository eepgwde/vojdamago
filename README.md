* Control

weaves

* The Carriageway Damage Project

** Overview

This has a complete project that loads data from a set of CSV and XLS
files. This system uses Python and q/kdb for the pre-processing and some of
the feature engineering.

The source data is for highways and insurance claims for faults on the highways.

It then uses GNU-R for the analysis; there are three forms of analysis:

 - Time-series analysis of Key Performance Indicators using the Generalized
   Additive Method.

 - A fault prediction classifier using operational features.

 - Regression analysis to predict Mean Time Between Failure for

** Loading

*** top.mk

The top-level directory is this one. It has a helper script hcc.sh and uses
a script file hcc

The source files are stored in cache/bak. The top.mk file calls the other
make files.

 make -f top.mk all
 make -f top.mk install

do all the work

**** trns/ and ldr/ and defs.mk

The directory trns and ldr are the same. It is just a naming convenience.
It contains the defs.mk file that specifies the files to process.

**** trns/ and trns.mk to cache/in

This performs the translation. It uses the source script hcc.sh in the
top-level directory and Python scripts to populate cache/in with CSV files.

You need a Python that has Pandas and some other date utilities.

**** ldr/ and ldr.mk to cache/csvdb

The q/kdb+ database is then loaded up and tables are written to cache/csvdb
using the CSV files. This directory contains the loader files for q/kdb+
and produces splay tables.

**** mkr/ and mkr.mk to cache/csvdb

The mkr directory contains many ad-hoc feature manipulation scripts written
in q/kdb+. These typically load a splay table and simplify, merge and
codify the splay tables to produce single file tables.

Many operational parameters are stored in workspace files; these are
prefixed "ws".

**** bldr/ and bldr.mk and dstr.mk to cache/out

The bldr directory builds the datasets. These are then output as CSV files
in cache/out.

The dstr.mk file is included by bldr.mk and produces a distribution Zip file.

** Analysis

The three pieces of analysis are then run from these directory:

 - e2c is the time-series analysis 
 - br is the fault prediction classifier
 - a2d is the regression analysis 

*** Time-series

This uses GAM to evaluate differently constructed models.

 make -C e2c -f e2c.mk all

*** Fault Prediction

This performs some recursive partition tree analysis.


** Notes

This is a log of the modifications I've had to make.

*** dfct fields

This failed to produce xncas1.csv and xncas1w.csv. Tracing back to
samples1.q and then samples1c.q. .dfct.status1 didn't exist. Re-ran dfct1.q


*** This file's Emacs file variables

[  Local Variables: ]
[  mode:text ]
[  mode:outline-minor ]
[  mode:auto-fill ]
[  fill-column: 75 ]
[  coding: iso-8859-1-unix ]
[  comment-column:50 ]
[  comment-start: "[  "  ]
[  comment-end:"]" ]
[  End: ]
