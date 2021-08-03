---
layout: page
title: MTBF
permalink: /analyses/a2d
navigation_weight: 5
---

{::comment}
This text is completely ignored by kramdown - a comment in the text.
{:/comment}

# Mean Time Between Failures

In the previous section, it was explained that there is a resurfacing schedule
for roads. This is based on a [mathematical
model](https://documents.worldbank.org/en/publication/documents-reports/documentdetail/793271468171847482/fourth-highway-development-and-management-model-hdm-4-road-use-costs-model-documentation)
maintained by the World Bank.

This is an illustrative diagram of the time behaviour of a road

![Alligator Cracking]({{ "/assets/images/a2d/road-pf-curve.jpg" | relative_url }})

Underpinning this curve is a mathematical function which has a family of curves
that look like this with different parameters.

![Decay function]({{ "/assets/images/a2d/pf-curve2.jpg" | relative_url }})

This parametric function depends principally on the traffic and usually a road
surface is calibrated to it in the laboratory. This produces reference tables
that are road surfaces can be tested against. 

Most roads last much longer than their reference model would suggest. In fact,
individual roads need to be calibrated to produce a function that gives a useful
estimate of when damage becomes imminent.

## Hazard Function 

This function is a hazard function that operates latitudinally. A number of
plausible factors are added that it is hoped the machine learning algorithm can
adjust for us.

### Static Factors

These are characteristics in particular the model traffic. This parameter is the
estimate of the traffic that the road will face in a day. Other characteristics
are:

  - road priority – in particular, local and non-local, but also slip road,
    distributor road and so on.
  
and some scaling factors that attempt to refine the model traffic

  - scaling factors: the total cars in the neighbourhood
  - the area of the road relative to the area of all roads in the geographic
  area. 
  
### Dynamic Factors

The other factors are derived from the number of defects. The more defects a
road has reported for it, the more this indicates it has degraded.

Cumulative sum of defects – as each defect arrives, we increment a count of the
total number of defects (dfcts). This indicates the degree of Hazard.

Days since last defect was reported (ddays1). This indicates the frequency of Hazard.

Wear Metrics: the longitudinal degradation metric (wear1) and the latitudinal
load metric (wear3). These are calculated each time a Defect occurs.

Weather metrics: we add a mean minimum temperature for the coldest seasons over
the lifetime of the asset up the Defect (tmin). And we add a mean minimum
temperature for the month of the Defect (tmin0).

## Road Histories

The dynamic factors produce these plots of the history of a road.

![Selected Road Histories]({{ "/assets/images/a2d/hcc3-001.jpeg" | relative_url }})

The most defective road is has 57 defects over 9 years. The least defective road
is a typical local road: only one real defect over 10 years. (Every asset starts
with a defect added by the system.) For the busier roads, flat parts of the
defect lifetime curves are usually correlated to summer periods. Short steep
rises are typical of the winter months. It should be the case, that the hazard
rate increases toward the end of the asset’s life and the number of defects will
increase.

All the road histories start at the same time. A road is older than another if
was resurfaced before the other. It is hoped that clustering will take place and
that local roads will display wear patterns that are typical of low traffic
roads and that distributor roads will show a different pattern.

Here is a larger selection. There are clusters appearing.

![Large selection]({{ "/assets/images/a2d/hcc3-002.jpeg" | relative_url }})

A cluster diagram partitions mostly on road type and model traffic.

![Clustering]({{ "/assets/images/a2d/hcc3-008.jpeg" | relative_url }})

## Health Metrics

For the roads that do have substantial repair histories, a Generalized Additive
Method regression function is generated; this uses as its inputs the *wear*
metrics given above.

Each road then has a effective age calculated for it using the GAM function and
this is recorded and charted. 

![Effective Age]({{ "/assets/images/a2d/hcc3-014.jpeg" | relative_url }})

In this chart, each defect has a horizontal error bar and is calculated as
(actual – health), so the error bar is plotting the estimated number of days
since resurfacing. If it extends to the left, the asset is effectively younger
and should last longer and to the right indicates it is effectively older and is
not going to last as long.

The chart is surprisingly optimistic for the local roads - these are the ones
that are lower down on the chart. Because they have relatively infrequent
defects reported, the roads appear to be younger.

It is also possible with this GAM function to estimate when the next defect
might occur: the Mean Time Between Failures.

# Summary

These health metrics are calibrated against the events recorded in the field.

The MTBF can be used as an additional feature for a classification system.

The MTBF can also be used to generate inspection requests. Roads that are close
to reporting a defect using the MTBF can be scheduled for an inspection. 
