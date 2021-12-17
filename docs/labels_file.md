# Purpose
Group electrodes together with a given name.

## Filename Convention
labels_subjid###.csv where subjid = project id and ### = subject id number

## Summary
Electrodes may be planted in different locations or layers in the brain and labels provides a way to organize the groups of electrodes. There needs to be a label file for each subject directory located in the project root directory.  

The labels file must include the following columns:
1. channel: Name of the channel in the file. The file must contain the <u>**complete list of channels for a given session**</u>
2. selected_channels: Boolean column that controls which channels are used to create data structures and analysis.
3. user_channels: Arbitrary way to sort channels defined by user. This order can be used to control plotting of SEPs in the [continuous pipeline][continuous_main].
4. chan_group: Assigned label for each channel. This label is used to group together channels before going through a given analysis.
5. chan_group_id: Assigned numerical channel id number. This mapping must be 1-1 and each chan_group must have a unique number.
6. recording_session: Used to track and sort channels and groups across multiple files.
7. recording_notes: Notes on channels for the given file.

The labels file is first loaded in when a data file is being converted into the .mat format for further processing in the `parser_main`. If there are labels that are in the recording file that are not in the labels file an error will be thrown with the list of missing channels for the recording session. The `selected_channels` is not applied in the `parser_main`, but is used in the subsequent mains when the data is organized and analyzed.

## Example labels:

|channel|selected_channels|user_channels|chan_group|chan_group_id|recording_session|recording_notes|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|sig001a|1|sig001a|Right|1|1|Blah|
|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|
|sig064d|0|sig064|Left|2|1|Blah|
|sig001a|1|sig001|Right|1|2|Blah|
|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|
|sig064d|1|sigg064|Left|2|2|Blah|

[continuous_main]: https://github.com/moxon-lab-codebase/MATLAB-offline-neural-analysis/wiki/Continuous-Main