---
layout: page
title: Overview
permalink: /overview/
navigation_weight: 1
---
# The Carriageway Damage Project

This is the web-site for a software project that uses Python, R and q/kdb+
to investigate the root-causes of road damage done to vehicles over 7 years.

This document describes the build system. The analyses carried out is described
in more detail within dedicated pages.

The analytic work is generally applicable to many systems that perform asset
management. The emphasis is to improve the scheduling of the business' operations.

## Summary

This is a complete project that loads data from a set of CSV and XLS
files. This system uses Python and q/kdb for the pre-processing and some of
the feature engineering.

The source data is for highways and insurance claims for faults on the highways.

It then uses GNU-R for the analysis; there are three forms of analysis:

 - Time-series analysis of Key Performance Indicators using the Generalized
   Additive Method. This provides a predictor that estimates repairs given
   environmental factors.

 - A fault Predictor (a classifier) that uses asset and operation features and
   is used to improve the design of an Imputer. This Imputer is then used
   operationally to classify asset maintenance priority.

 - Regression analysis to predict Mean Time Between Failure for carriageways
   that gives an effective lifetime for a road that can be used operationally to
   provide maintenance schedules.
 
Other analyses are carried out - recursive partition trees, cluster analysis -
on the assets. There are also some statistical tests to test assertions.

## Extraction

This has been done for us. The dataset consists of broadly two categories:
Descriptive and Operational.

### Descriptive Information for the Assets

The assets are the road (or carriageways) under management. They are keyed
by the asset code.

 - Inventory files: these list the roads managed by the organization
 
 - Properties: lots of reference files for the roads, these include speed
   limits, length, width, road material
 
 - Environment: more reference files that describe socio-demographic data
   for the roads

### Operational Information for the actions on the Assets

These are Event files, keyed by asset code and date and time.

  - These list the insurance claims on the roads
  - The faults reported
  - The repairs carried out

## Loading

The source data is copyrighted to its owners. You may be able to get copies
if you were to ask them. That means that there is no data in this distribution.

### top.mk

The top-level directory is this one. It has a helper script hcc.sh and uses
a script file hcc. (This script is a script loader. It is available from
another repository.)

The source files are stored in cache/bak. The top.mk file calls the other
make files. These two operations do all the work.

```
  make -f top.mk all
  make -f top.mk install
```

That is with the proviso that you have the data and a working environment.

To set up a working environment, there are README files in each of the
directories.

The data flow is from the cache/bak/ directory, to the cache/in/ directory.
The q/kdb+ database is loaded and its table appear in cache/csvdb/. These
are then output as CSV files to cache/out/.

R then performs its analyses using the CSV files in cache/out/. The results
of the analyses are stored in the directories where the analysis is done.

#### trns/ and ldr/ and defs.mk

The directory trns and ldr are the same. It is just a naming convenience.
It contains the defs.mk file that specifies the files to process.

#### trns/ and trns.mk to cache/in

This performs the translation. It uses the source script hcc.sh in the
top-level directory and Python scripts to populate cache/in with CSV files.

You need a Python that has Pandas and some other date utilities.

#### ldr/ and ldr.mk to cache/csvdb

The q/kdb+ database is then loaded up and tables are written to cache/csvdb
using the CSV files. This directory contains the loader files for q/kdb+
and produces splay tables.

#### mkr/ and mkr.mk to cache/csvdb

The mkr directory contains many ad-hoc feature manipulation scripts written
in q/kdb+. These typically load a splay table and simplify, merge and
codify the splay tables to produce single file tables.

Many operational parameters are stored in workspace files; these are
prefixed "ws".

#### bldr/ and bldr.mk and dstr.mk to cache/out

The bldr directory builds the datasets. These are then output as CSV files
in cache/out.

The dstr.mk file is included by bldr.mk and produces a distribution Zip file.

## Analysis

The three pieces of analysis are then run from these directory:

 - e2c is the time-series analysis 
 - rp is the asset characteristics partition trees
 - br is the fault prediction classifier
 - a2d is the regression analysis 

### KPI - Time-series

This uses GAM to evaluate differently constructed models.

```
 make -C e2c -f e2c.mk all
```

### Characteristics - Recursive Partition Trees

This performs some recursive partition tree analysis.

```
 make -C br -f rp.mk all
```

### Predictor - Fault Prediction

This performs a long process for training a classifier, imputation, and training a classifier with SMOTE.

```
 make -C br -f br.mk all
```

### MTBF - Effective Ages

This trains a mathematical model for many different classes of road and
generates an effective age for each class.

```
 make -C a2d -f a2d.mk all
```

## Notes

This is a log of the modifications I've had to make.

### dfct fields

This failed to produce xncas1.csv and xncas1w.csv. Tracing back to
samples1.q and then samples1c.q. .dfct.status1 didn't exist. Re-ran dfct1.q