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
ever non-zero when "Loan Granted" is true. A careless designer might not pick up
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

For the Predictor both the look-backward and look-forward variants of the repair
activity were used.

For the Imputer only the look-backward variant was available, with a simplified
form of the look-forward variant: number of days to next scheduled resurfacing -
the prmt variable set.

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

As noted above, one does usually use the same dataset for imputation as for
classification because it can introduce confirmation bias. 

The Imputer does not use these fields or metrics:

 - claim : the most obvious way to introduce more confirmation bias would be to
   introduce the outcome variable.
   
 - look-forward metrics : these would not be available to an operational
   classifier *except* for the Permit fields.
   
The Imputer does use the look-backward repair metrics.

The imputation process was a *k-nearest neighbours*. This is notoriously slow,
so with a great deal of trial and error, a great many features were removed. The
core set that produced a reasonable Imputer proved to be the repair metrics, the
permits, most of the road characteristics (long, narrow, urban, local-road,
traffic and so on) and a few socio-demographic features, family size for
example.

# The Predictor

As noted above, the Predictor is used to validate the design of the repair
metrics and the Imputer. This makes demands on the classification algorithm. It
will be a supervised technique: the dataset can be split into training and test.
And, because the dataset is very imbalanced, an upsampling method will be
needed.

## Classification Algorithm - GBM

An algorithm is needed that can quickly evaluate if a feature is dominating and
that dominant feature should be one of the repair metrics and the priority
assigned to the enquiry.

This means that aggregation algorithms should be avoided. In particular, do not
use Random Forest, because it aggregates across different random sub-spaces of
features, it can lessen the importance of metrics.

This implementation made use of a Gradient Boosted Method, which can be thought
of as a succession of recursive partitions which are pursued until no
noticeable change in response is observed. If a small sub-set of metrics are
dominating, then this will quickly become evident.

Another feature of GBM is that it quickly spots *prescient variables*.

## Upsampling Method - SMOTE

This is an imbalanced dataset, less than 1% of the dataset were settled claims.
This was increased by adding the *repudiations*, those claims there were applied
for but not settled. These were mostly lack of evidence rebuttals and there were
some fraudulent claims. The *repudiations* proved to have sufficiently similar
characteristics to the settled claims, so they could be used as part of postive
outcome dataset. This brought the positive percentage to 5%.

Adding the repudiations was an example of upsampling. A more subtle example of
which is SMOTE - the Synthetic Minority Over-sampling TechniquE. This creates
new records in the minority group, by introducing synthetic neighbours to
existing records. These have minor variations in their feature values. 

# Results

Firstly, the improvement in the Predictor with only upsampling will be shown.
Then the Imputer is added to the system and that improvement will be seen.

## Predictor - no imputation

### No upsampling

This is the variable importance plot for the basic Predictor. 

![Predictor]({{ "/assets/images/br/xroadsc-5-ml-001.jpeg" | relative_url }})

Although it appears that one measure dominates all the others, *smplriskbC1* it
will be seen that its contribution is relatively small - in the scale, it is
only 2500.

Another useful insight can be gained from the density plots.

![Density plot]({{ "/assets/images/br/xroadsc-5-ml-002.jpeg" | relative_url }})

It can be seen from this how confused the system is. Most of the *noclaim*
records can be discriminated, but the *claim* records, the cyan coloured entries
off to the right are scattered all through the distribution.

The [confusion matrix]({{ "/assets/images/br/cm-0.txt" | relative_url }}) is
very poor. It displays the beginner's trap for unbalanced datasets - the
accuracy is very high and the sensitivity is very poor.

### With upsampling

This is the variable importance plot for the basic Predictor with upsampling.

![Predictor]({{ "/assets/images/br/xroadsc-7-up-001.jpeg" | relative_url }})

The same measure dominates, *smplriskbC1* but it can now be seen to be more
important: the scaled value, is now 20000.

This can be seen in the density plot, although it is also confused, the
confusion appears later.

![Density plot]({{ "/assets/images/br/xroadsc-7-up-002.jpeg" | relative_url }})

The [confusion matrix]({{ "/assets/images/br/cm-1.txt" | relative_url }}) is
much improved, it shows nearly 80% sensitivity. It also has the characteristic
of upsampled systems that the false positives greatly outnumber the true
positives. In this case, by a factor of two.

#### Predictive System with Upsampling and a Prescient Variable

This system predicts well because it has prescient variables within it. It
should be the case that these would dominate, but see the discussion later for
an explanation.

It is hoped that the Imputer can give us comparable performance but without the
prescient variables - the imputed priority should now dominate.

## Predictor - with imputation of priority

This shows the importance of the imputed priority variable. Note: there are
still prescient variables in the dataset, but only one *smplf30* is important. 

![Predictor]({{ "/assets/images/br2/xroadsc-7-up-001-X.jpeg" | relative_url }})

The density plot appears to be just as distinct as that with the prescient variables.

![Density plot]({{ "/assets/images/br2/xroadsc-7-up-002.jpeg" | relative_url }})

The [confusion matrix]({{ "/assets/images/br2/cm-1.txt" | relative_url }}) is
not as good as the system with prescient variables, with only 60% sensitivity.
The number of false positives is now over 10 times greater than the true positives.

# Discussion

