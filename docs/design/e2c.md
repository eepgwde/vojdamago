---
layout: page
title: KPI
permalink: /analyses/e2c
xbase: /vojdamago/
kpipath: /assets/images/e2c/hcc5t-001.jpeg
kpicaption: "Key Performance Indicators: log scale"
---

{::comment}
This text is completely ignored by kramdown - a comment in the text.
{{ page.kpipath }}
- separator -
{{ page.xbase }}
- separator -
{{ site.xbase }}
{:/comment}

# Asset Management

In this section, the Key Performance Indicators of the business are observed
over time and seasonality effects are quantified.

## Operational Activity

The business being investigated is an asset management one. The carriageways are
the assets.

<p class="photo-gallery">
    <figure>
      <img src="{{ site.xbase }}{{ page.kpipath }}" alt="{{ page.kpipath }}">
      <figcaption>{{ page.kpicaption }}</figcaption>
    </figure>
</p>

From this chart, there is a funnel of actions in the business' operations

 - The assets have faults reported about them, *enqs*
 - Some action is taken as a result, *action1*, usually at least an inspection
   is carried out.
 - Some have a remedial action undertaken, *enqrs*
 
At the same time, there are assets that give rise to legal action against the
business.
 
 - There are claims against the business most of which are repudiated - called *repudns*
 - But some are successful, the *claims*
 
Of course, these *repudns* and *claims* are dated at the time the damage occurs.
The *claims* are a subset of *repudns*. The challenge is to find what are the
causes of these.

One can also the *enqrs* lags *enqs*, and that *action1* does not have such a
defined lag.

## Seasonality

Clearly there is a very pronounced seasonality here. 

<p class="photo-gallery">
    <figure>
      <img src="{{ site.xbase }}/assets/images/e2c/ncas1-001.jpeg" alt="Seasonality claims">
      <figcaption>Seasonality of <em>claims</em></figcaption>
    </figure>
</p>

The *enqs* and other KPIs show a similar decomposition. It should be added that
there was a change in operational policy in 2015. This explains the change in
the underlying trend.

This can be investigated using the [Generalized Additive
Method](https://en.wikipedia.org/wiki/Generalized_additive_model). A variety of
models were tested and their [coefficient of
determination](https://en.wikipedia.org/wiki/Coefficient_of_determination)
compared. With that, the most accurate model proves to be this.

<p class="photo-gallery">
    <figure>
      <img src="/assets/images/e2c/hcc3-002.jpeg" alt="GAM model">
      <figcaption>GAM Model <em>claims</em></figcaption>
    </figure>
</p>

It has as its independent factors: the maximum and minimum temperatures, the
month of the year and the amount of rain. It can be used to predict the load on
the business that can be expected.

<p class="photo-gallery">
    <figure>
      <img src="/assets/images/e2c/hcc3-007.jpeg" alt="GAM predictor">
      <figcaption>Predictions using the GAM Model <em>claims</em></figcaption>
    </figure>
</p>

A log file of the R evaluations can be viewed
[here](/assets/images/e2c/hcc3.txt)

A correlation diagram can be viewed [here](/assets/images/e2c/hcc5-005.jpeg).
There are a lot of different metrics here, those prefixed with *d* are
differences between the last period and the current one. These metrics should
indicate if the business is overloaded from the last period.

### Discussion

The seasons are significant, not just because of the change in weather, they
also change daylight hours that people have to drive in. The most accurate model
used the month of the year as well as temperatures and rain. The month of the
year is probably a proxy for daylight hours.

Of course, the weather cannot be changed. This analysis can be used to partition
the events: it might prove useful to conduct further analysis on the summer
months separately from the winter months.

In the next analysis, the characteristics of the assets are evaluated with the claims.
