---
layout: page
title: Predictor
permalink: /analyses/br
navigation_weight: 4
---

# Predictor and Imputer

In this section, a Predictor is developed that would allow the business to
prioritize inspections and repairs for the roads. It will be seen that an
Imputer is also needed for a key operational field.

It will become clear that the Imputer is the most important innovation. The
Predictor is used to improve the design of the Imputer. It should not be
forgotten that the business needs tools to improve its operation: it is not
enough for an analyst to state that all the work is seasonally driven; or to
state that most insurance claims come from suburban areas. The analyst must
design metrics that reflect operational activity and to design classification
tools that can prioritize the actions of the business.

For the business, they expect the Predictor to show that if the correct priority
is assigned to a fault report and if it is investigated and remedied in time, it
will not result in an insurance claim and, conversely, if the wrong priority is
assigned or no work is done, then it will result in a claim.

Before moving on to discuss the metrics and the model used, the dataset is have
enquiry records that are fault reports for roads and there are insurance claim
reports that need to be integrated into the dataset.

## Designing a Training dataset - Claims are transformed to Enquiry Records

The fault reports (known as *enquiry* records) are used as the dataset for the
classifier and a boolean field is added to indicate if the fault resulted in a
claim or not.

When a fault report is made, a priority is assigned to it for further action.
This is a human operator action - given the nature of the damage reported and
the characteristics of the road, a priority is assigned following the
recommendations given in an operations manual.

Practically all the records in the *enquiry* records did not result in a claim
being made, so the *claim* field was reset to *false*.

The *claim* records were then augmented with any deducible information and added to
the dataset - they would have their *claim* field set to *true*. Unfortunately,
these records were incomplete in that they did not have a priority value. It
would have been very difficult to have these claim records classified by hand -
there were just over 4000 claims in the past 7 years.

Therefore operational priority of the claim record had to be imputed. There were
two subsets of claim records:

 - For those few claims records that were preceded by a fault report, they were
   assigned the same priority as the preceding fault report. Only 300 or so of the
   4000 insurance claims had had earlier faults reported for them.
   
 - The remainder of the claims records had to have an operational priority
   imputed to them.

### Confirmation Bias

A confirmation bias has been introduced. If priorities are imputed, then the
priority assigned is an estimate of how likely the claim record is to produce an
insurance claim.

These records with their imputed priority field are then used to produce a
classifier that will be used as a Predictor to evaluate how likely any enquiry
record, which could be an augmented claim record, is to result in a claim.

So the Predictor will confirm the findings of the Imputer. Usually, it is
considered a design error to use the same dataset for imputation and
classification - for the both the Imputer and the Predictor.

In this case, there are distinct changes made to the dataset for the Imputer and
the method used will optimize the performance of the Predictor which
demonstrates the the Imputer has been improved.

The next sections explain how the Imputer's dataset is made different from the
Predictor. This uses the underlying time-periods of the policy with a measure of
operational effectiveness.

## Business Policy - Operational Priority and Claim Records

The operational priority for a fault report recommends a future action. The
first future action is an inspection. An inspection can be 

 - immediate or next day : the delay is 1 day
 - within the next 7 days, so a 7 day delay
 - within the next calendar month, 28 days
 - assigned to the pool, which might result in an inspection within 3 months: on
   average about 60 days
 
For a claim record that reports a claim on a particular calendar day, the priority
is imputed that states there should be an enquiry record prior to the claim 1,
7, 28 or 60 days before.

The claim record is then moved from its date of incidence back to the day after
its imputed priority states that it will be inspected.

The effect of this is that claim record is now an enquiry record demanding an
inspection in 1, 7, 28 or 60 days.

To give an example, an insurance claim states that on April 30th someone damaged
their car on that day. Given the details of the road, the Imputer uses the those
and other factors - the weather and socio-demographic features - and the
priority is imputed and assigned. In this case, assume it is a 28 day priority.

The claim record is now converted into an enquiry record with the *claim* field
set to *true* and the date of the enquiry set to 27 days before, or April 4th.

## Metrics - Repair activity

To help the Predictor and Imputer - we introduce a set of metrics that quantify
what work was done on a carriageway when a fault report is made.

These metrics also reflect the priority. If a fault has a 28 day priority,
it is hoped that it will at least inspected in the next 28 day period.

To simplify the data processing, it was observed that the first two priorities
(next day and within 7 days) are rarely used, so only two classifications for
repair activity are calculated one for within 60 days and one for within two
years. These are substantially longer than the priority cut-off of 28 days and
60 days, but proved to be more appropriate because the priority assigned to a
fault was rarely achieved - most inspections of lesser roads were deferred until
the summer months. It was also possible to use some elementary mathematical
modelling to make the metrics represent the time that had passed.

Repair activity was not just inspections for ad-hoc repairs and the repair
itself. It also included resurfacing work which would necessarily involve an
inspection and all ad-hoc repairs to be made - for business reasons, these are
known as Permits, the operation needs a permit to close a road for resurfacing..
These were scheduled months in advance and very often a fault that was assigned
a 28 day priority would not be inspected because of an upcoming resurfacing.

Also with the repair activity metrics, there were two variants:

 - one pair, looked backward in time and recorded what work had been carried out
   on the road.
   
 - a second pair, looked forward in time and recorded what work would be carried
   out on the road.
   
[Here]({{ "/assets/images/br/xroadsc-3-corr-004.jpeg" | relative_url }}) 
are the correlations of the forward repair metrics and 
[here]({{ "/assets/images/br/xroadsc-3-corr-003.jpeg" | relative_url}})
the backward ones.

There is some encoding here: bC1, bC2 and fC1 and fC2 are backward, short
period, long period and then forward, short and long.

There are a number of metric groups

 - dfct for defect
 - dfctinspctf for defect inspection
 - prmt for permit, that means that a permit has been applied for that
   would allow the road to be closed for resurfacing.
 - status is a composite measure of all three of these.
 - smplrisk is a probability measure: what chance of another record?

smplrisk is built on another variable group, called smpl. 

Also if a metric is prefixed with a "d", this means it is a delta with the
previous (or next) value. This captures faults that are a result of a repair:
when a road is resurfaced, damage can be made to cars from the road surface
being loose.

The look-forward pair is an example of a *prescient variable*. Usually variables
like these have inadvertently encoded the final outcome and prove to be accurate
predictors. (A well-known example would be the mistake often made in a loan
application process predictor: the outcome variable would be "Loan Granted", but
there may be another variable "LV", which is overlooked and does not have a
clear definition in the data dictionary and proves to be *Loan Value* and is only
ever non-zero when "Loan Granted" is true. A careless designer might not pick uvp
the correlation between the outcome variable and the prescient variable.)

These repair metrics were quite complicated in design. The operation was either
an inspection, an ad-hoc repair or a resurfacing. These had a base weight which
was then re-weighted with a negative exponential decay over the days to (or
from) the events.

The *smpl* group not so complicated. It is just a counter - is there any record
for this road looking forward (or backward) in time. This variable makes an
appearance later on. It should not be thought of as a prescient variable, it
should be removed.

The prescient pair - the repair metric that looks forward in time - should be
the best predictor for a claim: if a priority is assigned that should see the
road inspected or repaired in some way within 60 days and no work is carried out
subsequent to the enquiry, then, given how claim records are constructed, it
would be very likely that a claim will result.

Both the Predictor and the Imputer will use both the look-backward and
look-forward variants of the repair activity were used. When the Predictor is
reasonably accurate, the dataset with all the prescient metrics can be used to
develop an Imputer.

When a fault is reported on a road the prescient variable should report some
activity for the road in the future. 

 - For enquiry records that are not *claims*, they have had a priority code
   assigned manually; there will be some activity recorded in the prescient
   features.

 - For enquiry records that are *claims*, they will not have a priority. Their
   prescient variables will almost certainly show there was little or no
   activity for that road.
   
In all other features, if a set of roads with no claims have a neighbour that is
a road with a claim, the neighbour will be given an imputed priority that is the
same as its neighbours.

## Prototyping

Do note that this method of modelling this problem was neither the first nor the
only prototype. There were many iterations of this design. The earliest
iterations did not use an Imputer for priority and simply discarded that field
for all records.

The final iterations were the extension of the dataset by adding the repair
metrics incrementally. The final iteration with the *sample* metrics gave a
usable Predictor that was dominated by the expected operational metrics: the
priority assigned to fault and the work that was done on it. 

These greatly improved the performance of the Imputer and eventually the
Predictor.

# The Imputer

As noted above, one does not usually use the same dataset for imputation as for
classification because it can introduce confirmation bias.

The Imputer does not use the *claim* field because it is implicit. The records
that need an imputed priority are the claim records. The imputer also uses the
look-forward metrics, because these should be the only features that differ
between the roads that have claims and those that do not, because they were
repaired in the future.
   
The imputation process was a *k-nearest neighbours*. This is notoriously slow,
so with a great deal of trial and error, a great many features were removed. The
core set that produced a reasonable Imputer proved to be the repair metrics, the
permits, most of the road characteristics (long, narrow, urban, local-road,
traffic and so on) and a few socio-demographic features, number of cars per
household proved to more accurate.

Once the imputations for priority have been made, the Predictor should be more
accurate. The Predictor is then run without the prescient variables and the
priority feature should dominate because it is now a proxy for the prescient
features.

# The Predictor

The Predictor is used to validate the design of the repair metrics and the
Imputer. This makes demands on the classification algorithm. It will be a
supervised technique: the dataset can be split into training and test. And,
because the dataset is very imbalanced, an upsampling method will be needed.

When the Predictor is sufficiently accurate, the prescient features can be
removed from the dataset and the imputed priority should act as a proxy for
them.

## Classification Algorithm - GBM

An algorithm is needed that can quickly evaluate if a feature is dominating and,
it is argued, the dominant features should be the repair metrics and the
priority assigned to the enquiry.

A classification algorithm that uses aggregation should be avoided. In
particular, do not use Random Forest, because it aggregates across different
random sub-spaces of features, it can lessen the importance of the key metrics.

This implementation made use of a Gradient Boosted Method, which can be thought
of as a succession of recursive partitions which are pursued until no
noticeable change in response is observed. If a small sub-set of metrics are
dominating, then this will quickly become evident.

The important feature of GBM is that it quickly prioritizes the *prescient
variables*. 

## Upsampling Method - SMOTE

This is an imbalanced dataset, less than 1% of the dataset were settled claims.
This was increased by adding the *repudiation* records, those claims that were
applied for but not settled. These were mostly rebuttals that lacked evidence
and the claimant chose not to pursue the claim. There were some fraudulent
claims as well. The *repudiation* records proved to have sufficiently similar
characteristics to the settled claims, so they could be used as part of positive
outcome dataset. So records with *repudiation* and *claim* were both made part
of the positive outcome set and this increased the percentage to 5%.

Adding the repudiations is an example of upsampling. A deduction method is to
use SMOTE - the Synthetic Minority Over-sampling TechniquE. This creates
new records in the minority group, by introducing synthetic neighbours to
existing records. These have minor variations in their feature values. 

# Results

Firstly, the Predictor with no upsampling and prescient features is shown. Then
the improvement in the Predictor with only upsampling will be shown. Then the
Imputer's results are added to the claim records, the prescient features are
removed, and the accuracy of that system can be compared to the system with
prescient records and no imputations.

## Predictor - no imputation

### No SMOTE upsampling

This is the variable importance plot for the basic Predictor with the
*repudiation* records included, but no SMOTE.

![Predictor]({{ "/assets/images/br/xroadsc-5-ml-001.jpeg" | relative_url }})

Although it appears that one measure dominates all the others, *smplriskbC1* it
will be seen that its contribution is relatively small - in the scale, it is
only 2500. The *priority* field is still an important predictor even though it
has partial coverage: the *claim* records were given the minimum value, the 60
day pool. All of the important variables are repair metrics.

The density plots show how confused the system is and the smaller number of
*claim* records.

![Density plot]({{ "/assets/images/br/xroadsc-5-ml-002.jpeg" | relative_url }})

Most of the *noclaim* records can be discriminated, but the *claim* records, the
cyan coloured entries off to the right are scattered all through the
distribution.

The [confusion matrix]({{ "/assets/images/br/cm-0.txt" | relative_url }}) is
very poor. It displays the beginner's trap for unbalanced datasets - the
accuracy is very high and the sensitivity is very poor.

### With SMOTE upsampling

This is the variable importance plot for the basic Predictor with SMOTE
upsampling.

![Predictor]({{ "/assets/images/br/xroadsc-7-up-001.jpeg" | relative_url }})

The same measure dominates, *smplriskbC1* but it can now be seen to be more
important: the scaled value, is now 20000.

The density plot shows the records are now balanced - a huge number of synthetic
records in the minority group have been added. The confusion appears midway
through the distribution.

![Density plot]({{ "/assets/images/br/xroadsc-7-up-002.jpeg" | relative_url }})

The [confusion matrix]({{ "/assets/images/br/cm-1.txt" | relative_url }}) is
much improved, it shows nearly 90% sensitivity. It also has the characteristic
of upsampled systems that the false positives greatly outnumber the true
positives. In this case, by a factor of two.

#### Summary: Predictor with Upsampling and Prescience

This system predicts well because it has prescient features within it. It
should be the case that these would dominate, but see the discussion later for
an explanation.

It is hoped that the Imputer can give us comparable performance but without the
prescient features - the imputed priority should then dominate.

## Predictor - with Upsampling and Imputation

This shows the importance of the imputed priority variable. Note: there are
still prescient variables in the dataset, but only one *smplf30* is important. 

![Predictor]({{ "/assets/images/br2/xroadsc-7-up-001-X.jpeg" | relative_url }})

The density plot is not as distinct as that with prescient features, there is a
huge overlap between the densities.

![Density plot]({{ "/assets/images/br2/xroadsc-7-up-002.jpeg" | relative_url }})

The [confusion matrix]({{ "/assets/images/br2/cm-1.txt" | relative_url }}) is
not as good as the system with prescient variables, with only 60% sensitivity.
The number of false positives is now over 10 times greater than the true positives.

# Summary

What has been demonstrated here, is that there exists a prioritization scheme that
can more accurately predict if a repair will result in an insurance claim. To do
that, a reasonably accurate Predictor has developed that uses an Imputer to give
a better priority to *claim* records.

This means there should be a better way of prioritizing faults, so this would be
a useful innovation for the business and it should add a facility to its fault
reporting system that generates a priority using this machine classification:
there would then be two priorities: a manual-priority, assigned by a human
operator, and a machine-priority generated by an algorithm.

There are some issues with this:

 - The Imputer uses the manual priorities assigned for *noclaim* records. There
   will be mistakes in classification here; this can be refined over successive
   iterations, using a recursive method: in the next iteration, the
   manual-priority and the last machine-priority will both be recorded
   and used by the imputation process.
   
 - A more difficult issue is that as much as one-fifth of the *repudiation* and
   *claim* records had no defect or repair history other than the *repudiation*
   or *claim* itself. This proved to be something of an anomaly in the dataset:
   one of the best predictors for a claim was that it had no history. This
   explains the importance of the *smpl* variable in the predictor. This
   variable was a counter for the number of times faults were recorded against a
   road. If the value was one, it was an orphan road and would almost certainly
   cause a claim, because the only records for orphan roads were *claim* ones.

It is quite difficult to deal with the orphan road issue. A possible method
might be to add more samples of orphan roads that do not result in a claim. This
would reduce the importance of *smpl* variable for prediction.

When these results were presented to the business, they explained that their
fault system was reactive - they only inspected faults as they were reported. It
was argued that they should instigate a more proactive system that generated
inspection requests for the many orphan roads.

The business said that they had a programme of resurfacing roads that used a
mathematical model for the wear and tear a road might be subject to. This
generated an alert in the resurfacing programme.

Because of this insight into their operations, a further statistical study was
undertaken. Given the mathematical model, could it be adjusted using observed
repairs to calculate an effective age for the road. This would be an input to a
Mean-Time-Between-Failures that would decide which roads should be prioritized
for inspection and resurfacing. This is the final study in this project.

# Discussion

## The Prescient Features Method

The method used here is not a conventional one. Rather than just build
a predictor for classification, this Predictor has been used to
evaluate how effective an imputation process can be. And that
imputation process demonstrates that a better classification system
can be found for the business.

The Predictor was developed by giving it prescient features in the dataset; that
is, features that know the future history of a fault report. These prescient
features used some combination of other features: in this case, a weighted
combination of inspections, defects and repairs. Once it was clear that the
prescient features determined the performance of the Predictor, they were
removed from the feature set and the imputed value acted as a proxy for them.

### Caveats

In this implementation, it has not been possible to follow the method as
described. The prescient features were left in and it was seen that the imputed
priority dominated.

It was noted that there was a problem with orphan roads and it needed to
addressed directly. This involved the MTBF model to provide information on these
orphan roads.

## Other Points

### Repudiations and False Positives

The decision to use the *repudiations* to reduce the imbalance in the dataset
was important but did need to be assessed by making other checks that *claims*
and *repudiations* were sufficiently similar.

The use of SMOTE has an effect of increasing the false positives the Predictor
reports: s much as ten-fold. Within the business model, False positives are not
particularly bad. If one compares the cost of 10 inspections with the cost of an
insurance claim, then these false alarms are a small price to pay.

### What the Predictor also revealed - Unimportant Features

The variable importance charts for the Predictor listed a huge number of
features: distances from points-of-interest, socio-demographic factors as well
as the road characteristics. None of these proved to be important when it came
the propensity for a road to be the subject of a claim.

There was some ad-hoc investigation: the roads in suburban areas with families
and more than one car were marginally more likely to be the subject of a claim,
but there were no *magic bullets*, so often data scientists like to believe
there is an underlying dynamic in a system that has not been discovered.

In this project, it became apparent that the orphan roads were key. The
management was preoccupied with maintaining the major carriageways with high
traffic loads, but most insurance claims originated on local roads. This reveal

### Praxis: knowing the dataset

#### Data Science and Decision Science

In this project, it has been seen how analysis of results from machine learning
have been used to enhance a business' operations. A better classification
algorithm was developed.

A classifier is very often all that a business needs. In finance, one needs a
value for a portfolio: so one develops a quantitative parametric model for every
instrument in a portfolio and then one uses a parametric probabilistic method to
combine the instruments and so value it: a VaR method for example.

For many businesses, a quantitative accounting valuation is not needed. A
classification is sufficient. Stock traders only need to know whether to Buy,
Sell, Hold or Short. In this project, it was only necessary to priotize work to
be carried out: today or tomorrow, within a week, within a month and sometime in
the next year.

Classifiers are easily generated with shallow machine-learning methods and form
a useful tool in Decision Science.

#### Balancing Datasets with non-positive Orphans

Shallow learning methods - supervised classification methods - do provide
insight into the dynamics of a dataset. The issues with upsampling and orphan
roads in this project was another unusual challenge. Imbalanced datasets are the
norm: and one needs good insights and methods to work with them.

In this project, the issue with orphan roads was tested with a smaller dataset.
The claims records and a randomly selected set of smaller roads, the claim field
was removed and replaced with a field *randomly selected*. Needless to say, the
Predictor was very poor.

So a more balanced dataset would have been all the roads managed by the business
with most roads being given an annual event that states *uninspected*.

#### Data Science is an Art

There are people who believe that data science can be a simple process of
putting in all the data one can find, turning the handle on some computational
machine and getting results. This is simply not so. For example, beginners'
mistakes are often to include dates and database identifiers and to hope they
will all drop out in the analysis.

It is important to understand the data dictionary and eliminate uninformative
features. If a set of features are highly correlated, only one core feature is
needed. 

Lots of new business metrics need to be added. One cannot rely on a Principal
Component Analysis to generate a metric that weights inspections, repairs,
resurfacing all in one. Metrics have to be designed that enhance business
knowledge and so can be used by the classification algorithm: time windows are
very useful, a time-decaying weight on events is a common design.

It is also important to be a scientist. Posing questions of the dataset and
testing them with other simpler statistical methods.

But in the end it is an art, intuitons and ideas have to be made real.
