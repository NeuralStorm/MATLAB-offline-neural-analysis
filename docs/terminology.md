# Purpose
In general, we want to describe a selection of data using precise words. While there is not a perfect word that can capture all the possibilities of what the data might be, we have settled on using set words universally in the codebase to help readability.

# Fixed Terminology
|Word         | Description |Possible Abbreviations|
|:-----------:|:----------:|:---------------------:|
|bin| temporal resolution of data |N/A|
|channel| Typically the physical channel from which data are collected (e.g. sigchannel for neural data or LFP) but can also be a population function (e.g. average firing rate across neurons, principal component, latent variable etc.|chan|
|chan_group|Collection of channels that should be grouped together when doing an analysis (i.e.: brain regions, region + power combinations, etc.)|ch_group|
|relative_response|Data matrix with dimensions: Trialsx(Chans * Bins). This matrix is typically relative to some stimulus/event|rr|
|Peri-stimulus Time Histogram (PSTH)|Trial averaged relative response matrix. Dimensions: 1x(Chans * Bins)|psth|
|multineuron time series (mnts)|Similiar to relative response, but with dimensions slightly tweaked. Dimensions: (Trials * Bins) x Chans|mnts|
|baseline_window|Time window bound by window start and window end and must be cleanly divisible by total bins. Baseline window is typically used for measuring baseline activity in a given channel for an analysis (ie: receptive field)||
|response_window|Time window bound by window start and window end and must be cleanly divisible by total bins. Response window is typically used for a window of response to a given stimulus/event for an analysis (ie: receptive field, PSTH classifier)||

# Other Terminology
|Word         | Description |Possible Abbreviations|
|:-----------:|:----------:|:---------------------:|
|Feature| abstraction from the raw data that represent some variable of interest (e.g. firing rate of single neuron or power in a particular frequency band) Features can be endless, whatever variables the user creates from their data. Note that features can also be derived from population functions |feat|
|Pipeline| a user defined set of routines that is defined by stringing together multiple mains or writing their own main||
|main| A function that runs a predefined  data analysis routine||
