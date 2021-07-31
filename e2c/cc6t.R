## weaves
##
## Observed change in claims after 2016-07
## 

rm(list=ls())
gc()

## For footways

library(dplyr)
library(lubridate)
library(ggplot2)

df1 <- read.csv("t.csv")


p0 <- ggplot(data = df1, aes(dt0, log(n), group=outcome1, colour=outcome1) ) + 
    geom_line(size = 0.8) + theme_bw()

df2 <- df1[ df1$outcome1 == "Enquiry", ]

data1 <- df2 %>% select(dt0, n) %>% 
    mutate(yr0=as.integer(year(dt0)), month0=as.integer(month(dt0))) %>%
    select(dt0, yr0, month0, n)

data2 <- ts(data1$n, 
            start=c(data1$yr0[1], data1$month0[1]), 
            end=c(data1$yr0[nrow(data1)], data1$month0[nrow(data1)]), 
            frequency=12)

enqs0 <- decompose(data2)


df2 <- df1[ df1$outcome1 == "Settled", ]

data1 <- df2 %>% select(dt0, n) %>% 
    mutate(yr0=as.integer(year(dt0)), month0=as.integer(month(dt0))) %>%
    select(dt0, yr0, month0, n)

data2 <- ts(data1$n, 
            start=c(data1$yr0[1], data1$month0[1]), 
            end=c(data1$yr0[nrow(data1)], data1$month0[nrow(data1)]), 
            frequency=12)

settled0 <- decompose(data2)

jpeg(filename=paste("cc6t", "-%03d.jpeg", sep=""), 
     width=1024, height=768)

print(p0)

plot(enqs0)
title("Enquiries")

plot(settled0)
title("Claims")

x0 <- lapply(dev.list(), function(x) dev.off(x))

