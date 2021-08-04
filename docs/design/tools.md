---
layout: page
title: Tools
permalink: /analyses/tools
navigation_weight: 6
---

{::comment}
This text is completely ignored by kramdown - a comment in the text.
{:/comment}

# Workflow

This project had a workflow as follows:

 - Extract: Databases and Websites delivered CSV, 95%, JSON, <2%,  and XML, <2%
 - Transform: Python transformations to standardise the following and output CSVs
   + date formats
   + foreign language content
   + numerical formats
 - Load: CSV files were loaded into an analytics database: q/kdb+
 - More Transformation: 
   + aggregations
   + foreign keys to reference tables
   + time windows with weighting
   + geographical weighting
 - Extract, transform and load to the machine learning system, which was R
 - Results were generated in 
   + image form, JPEG and PDF
   + text file capture of internal processing

## The Process

The data engineering phase of a data science has three stages, often combined
into one acronym: the ETL (Extract, Transform and Load) stage.

More completely, there is an initial ETL phase where the source data is loaded
into an analytics system. Then there is a another stage of transformation 
where new metrics are generated. Then there is another stage of ETL where the
data in the analytics system is made available to the machine learning systems.

 - Extract/Acquisition: getting the data you need
 - Transformation: pre-processing the data so that it can be loaded
 - Loading: putting it into an analytics system
 - More transformation: generating metrics within the analytics system
 - Extract, Transform and Load for the machine learning tools
 
It might be claimed that the last two stages are not needed with some
tool-chains. This can only be said of projects where the problem-solving has
been done. It can be said that there is a iterative development loop around the
whole process and there is a smaller loop around the last two stages.

### Big Data Systems

This project was relatively small, but Big Data systems like Apache Spark have a
two stage process: one loads data in text or log file format; one is then able
to use Spark's text processing tools to post-process the data so that numerical
parsers can load fields. These fields are then populated and become attributes
of records in data frames which hold the datasets.

### Most Systems

Although it is convenient to work in one programming language, it is very often
the case that there are considerably better tools for the different stages of the
process. One of the reasons why those tools are so good is because they have
a dedicated programming language. 

### Technology Profile: This System

Here is the technology profile for this system.

 - The hardware was an Intel i5 with 8 GBytes of RAM. With this it could take as
   much as 4 hours to run the very demanding Gradient Boosted Method. 

 - The host systems were all Debian GNU/Linux. A lot of job-control scripts
   written in BASH were used with the make utility to implement the work-flows.

 - Python was used as the first transformation system. It has replaced PERL as
   the data processing language. Like PERL, it has many modules for string to
   date conversions and dealing with different formats of CSV file, (the embedded
   comma of Microsoft generated CSVs). It also reads Excel sheets.
   
 - q/kdb+ was used for the transformation stage for metric generation. q is the
   programming language for the kdb+ database. kdb is a columnar database and
   operates almost entirely in memory, using the vector processor to make data
   processing extraordinarily fast. Developing metrics is made easy by the q
   language, it is a functional one and has been adapted to temporal data types.
   
 - R was used for the machine learning and statistical testing. It has been the
   statistics languages for decades and it is the open-source implementation of
   S. Many reference implementations of machine-learning algorithms were
   prototyped and developed with R. This means the implementations have more
   controls and logging than in other systems.
   
### Python-based Systems
   
Python is now used widely for data science. The language has a simple syntax
that makes it easy to learn and use for analysts. The metric generation stage
would use the Python Pandas modules. This is comparable to q/kdb+ because it is
also internally a columnar database using the vector processor. It is not as
sophisticated as q/kdb+ nor quite as performant. The Python scikit modules have
also re-implemented many of R's packages, but often lacking the diversity, the
control and the logging.

Python Pandas accesses its dataframes in a very similar way to R.

## Prototyping and Production

### Organising People

It is critical for important production jobs that machine learning systems be
validated and often this involves re-implementing parts of it in another
system and use its languages.

Often the best route is to let the lead/senior data scientist develop a
prototype with their tools and experience and to have a junior validate and
re-implement the system for production in the business' preferred corporate
system and language.

In this way, the junior learns the methods referring to a working system. The
senior can correct the code and use his intuition to fix mistakes.

Eventually, the junior will be able to replace the senior for the next
generation of technology.

### Organising Systems

[Python](https://docs.anaconda.com/anaconda/packages/pkg-docs/) and now
[R](https://docs.anaconda.com/anaconda/packages/r-language-pkg-docs/) can be
managed under Anaconda. 

And to use a version control system like Git.

As always, it is useful to work on VMs. These can be easily cloned and archived.
And they can be used as a part of Continuous Integration and Development system
with a Development, Test and Production suite of machines.


