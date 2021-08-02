---
layout: page
title: Predictor
permalink: /analyses/br
navigation_weight: 4
---

# Predictor

In this section, the characteristics of the roads are assessed against the claims. 

What can give rise to disproportionately more claims?

 - Is it certain kinds of roads?
 - Or particular repairs histories? 

## Road Characteristics

<p class="photo-gallery">
    <figure>
      <img src="{{ "/assets/images/br/xroadsc-cwy0-003.jpeg" | relative_url }}" alt="Road Characteristics">
      <figcaption>Road Characteristics against claims: recursive partitions</figcaption>
    </figure>
</p>

From this diagram, a number of features can be observed:

 - 30% of claims occur on short roads that are not distributor roads.
 - longer, urban roads are then the most likely, usually these are narrow (they have a smaller area)
 
This proved to be very counter-intuitive finding for the domain experts within
the business. There is a discussion of this later.

It should be added that this is the clearest result from the recursive partition
analysis of the inventory of roads. Hundreds of features for the roads were
considered: physical properties, the width and length; socio-demographic
factors, number of cars in the household, index of deprivation, family size;
geographic proximity to civic amenities, schools, railway stations and so on.

Most of these characteristics were related to urban/rural and the length/width
of the road. Wealthier areas tended to be suburban with longer roads that were
not distributor roads.

## Maintenance History

Some aggregate metrics were attached to each asset: how often they were
inspected and repaired before a claim was made. A small subset of the inventory
was used for a cluster diagram.

<p class="photo-gallery">
    <figure>
      <img src="{{ "/assets/images/br/rp2-002.jpeg" | relative_url }}" alt="Claims cluster against repair history">
      <figcaption>Clustering of claims around repair history</figcaption>
    </figure>
</p>

The dataset here is constrained to just *claims* on rural tarmac roads. This
proves to be just 520 in all - about one fifth of the total.

The clusters are separated with 
[contingency tables]({{ "/assets/images/br/rp2.txt" | relative_url }}).

 - road priority is key factor: classes 2 and 3 are Local Distributor and Local Access roads.
 - one cluster of roads (cluster 4, with 75 assets) had no prior maintenance history
 - these roads are low-traffic and relatively long (over a hundred metres)

### Discussion

The analyses carried out in this section proved to be quite revealing for the
managers and strategists in the business. They had dedicated most of the
operations to maintaining the more important distributor roads - primary and
secondary roads that connect to motorways. 

They did not have a regular inspection process for smaller roads that could have
made repairs.

A spreadsheet was compiled that allowed a simple Chi-square test to be made
between the number of claims of roads that fulfilled a set of criteria and the
inventory as a whole.

The business had a priority system to determine if roads should be inspected as
the result of a fault report. It was decided that this prioritization system
could be improved with a Predictor. A key feature of this new Predictor was that
it would generate inspection requests for roads that were not the subject of a
fault report.
