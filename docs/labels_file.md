# Labels file guide

## Purpose
As electrodes may be placed in different locations within the brain, label files are needed to allow end users to communicate some organization of these electrodes and the different groups they comprise to the program.

### Filename Convention
**Examples:**   
`labels_CSM030.csv`   
`labels_CSM031.csv`    
`labels_EXP001.csv`    
`labels_EXP002.csv`   
    
**Representation:**    
`labels_SUBJID###.csv`    
    
...where SUBJID is a given project ID and ### is a given subject ID number.

### Label Columns

MONA expects all labels files to contain the following columns:

|Column label          |Contents                                                |Sample Values|
|---------------------|--------------------------------------------------------|:---------------------:|
|`sig_channels`|The name of each signal channel in the recording file.                  |`sig001a`/`wire1a`     |
|`selected_channels`          |Denotes whether each channel ought to be included in the processing to come.|`0`/`1`/`TRUE`/`FALSE`    |
|`user_channels`          |User-defined custom channel sortation.           |?    |
|`label`|The label under which each channel ought to be grouped.|`HLM1`/`Parietal`/`LEFT`|
|`label_id`|Unique ID associated with each label.|?|
|`recording_session`|Tracks and sorts channels and labels across multiple recording sessions.|`0`/`3`/`6`|
|`recording_notes`|Any notes experimenters had to make regarding a specific channel.|`got loose`/`ignore this one`

The labels file is first loaded in when a data file is being converted into the .mat format for further processing in the `parser_main`. If there are labels that are in the recording file that are not in the labels file an error will be thrown with the list of missing channels for the recording session. The `selected_channels` is not applied in the `parser_main`, but is used in the subsequent mains when the data is organized and analyzed.

To further set appropriate expectations as to what label files should look like, here's a sample format:

|sig_channels|selected_channels|user_channels|label|label_id|recording_session|recording_notes|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|sig001a|1|sig001a|Right|1|1|Blah|
|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|
|sig064d|0|sig064|Left|2|1|Blah|
|sig001a|1|sig001|Right|1|2|Blah|
|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|
|sig064d|1|sigg064|Left|2|2|Blah|

Please keep in mind that label files are, again, generally loaded in at the start of each main function (e.g. `parser_main.m`/`recfield_main.m`), and that the program will return an error if any of the label files are missing channels listed in the raw data.
