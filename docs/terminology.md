# Purpose

We generally seek to describe selections of data using precise words. While there may not always be a perfect word that can capture all the possibilities of what a user might encounter throughout the course of using MONA, you can find an index of common terms whose use and meaning has been standardized for the purposes of this documentation here:

## Fixed Terminology
|Term         | Description |Abbreviations|
|:-----------|:----------|:---------------------|
|Bin| Temporal resolution of data. |N/A|
|Channel| Typically the physical channel from which data are collected (e.g. `sigchannel` for neural data or LFP), but can also be a population function (e.g. average firing rate across neurons, principal component, latent variable, etc.)|chan|
|Channel group|Collection of channels that should be grouped together when during analyses, such as brain regions, region & power combinations, et cetera.|chan_group, ch_group|
|Relative Response Matrix|Data matrix whose every row represents one trial, and whose every column is one bin of one channel, for total dimensions of `Trials x (Chans * Bins)`. This matrix is typically relative to some stimulus or event.|RR|
|Peri-Stimulus Time Histogram|Trial-averaged relative response matrix. Dimensions: `1 x (Chans * Bins)`.|PSTH|
|Multineuron Time Series|Data matrix whose every row represents one bin of one trial, and whose every column is one channel, for total dimensions of `(Trials * Bins) x Chans`|MNTS|
|Baseline window|Time window typically used for measuring baseline activity in a given channel, bounded by a start and end time. Must be divisible by total bins.|BSLN|
|Response window|Time window typically used for measuring response activity in a given channel, bounded by a start and end time. Must be divisible by total bins.|N/A|
|Feature|Abstraction from the raw data that represent some variable of interest, such as the firing rate of a single neuron or the power in a particular frequency band. Features can be endless -- whatever variables the user creates from their data. Note that features can also be derived from population functions. |feat|

## Miscellaneous Terminology
|Main|A function that runs a pre-defined  data analysis routine.|N/A|
|Pipeline|A set of routines generally defined by a user or programmer that strings together multiple mains.|N/A|
