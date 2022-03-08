# parser_main
## Steps in parser_main
1. Select project directory with config, labels, and data
    * conf_parser.csv
    * labels_subjID.csv
2. Extract information from proprietary formats and save in .mat format.  
    * Currently supported formats:

|File Extension|Company|Data type|
|:-:|:-:|:-:|
|.plx/.pl2|Plexon|spike|
|.rhd/.rhs|Intan|continuous|
---
# Running parser_main
1. Make sure data is organized in proper file structure. [See here for more details.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/file_layout.md)
2. Make sure filenames match [naming convention.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/filename_convention.md)
3. Make sure offline codebase is on your Matlab path. [Click here for details on adding dependencies](https://github.com/moxon-lab-codebase/docs/blob/main/matlab_basics/adding_dependencies.md).
5. [Make a labels file for each subject.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/labels_file.md)
    * labels_subjID.csv
6. Set up config file. See config section below for more details.
    * conf_parser.csv
7. Run `parser_main` in Matlab's command window and select path to project directory.

## Config
    * conf_parser.csv
### Global Parameters
|Parameter Name|Type| Description |
|:-----------:|:--:| :----------:|
|dir_name|char/str|Name of directory with data. Typically subject ID|
|include_dir|boolean|Controls if directory passes through main|
|include_sessions|int|Controls if a given recording session file is analyzed|
|recording_type|string|controls what info is pulled. Valid options: plexon: spike; intan: continuous|

### Spike Parameters
|Parameter Name|Type| Description |
|:-----------:|:--:| :----------:|
|total_events|Int|How many events are there|
|total_trials|Int|Total trials for each event|
|trial_lower_bound|Int|Filters out event channels with less trials than this set limit. Ex: set lower bound to 40 and the parser will skip over all event_channels that have less than 40 trials (ie: start and stop event channels are often skipped with this)|
|is_non_strobed_and_strobed|Boolean|true if recordings are mix of strobed events and non strobed events, false otherwise|
|event_map|Array of ints|Maps strobed to non strobed in the order of event channels. Can be left empty|

#### Note on strobed vs non strobed
Plexon allows for experminents to be recorded with two different sets of events: strobed and nonstrobed. When the exerpiment is recorded with the strobed event channel, then all recorded events will be stored in the strobed event channel in a given numerical order (ie: 4 events will be 1, 2, 3, 4). If the recording is made with non-strobed recordings, the recorded events will be recorded in their specified event channel.  

A case where a study mixes the two is with one of the original Tilt dataset sets recorded by Nate Bridges. In that experiment, they recorded non strobed events from 1, 3, 4, and 6 event channels. The strobed events came out as 1, 2, 3, and 4. In order to make these event types match, `is_strobed_non_strobed` is used to specify if the two event recording types are present and `event_map` specifies how to map the numerical order to the non strobed event channels. Since Nate had recorded the event types in the same order, his event mapping was `1,3,4,6`.

### Continuous Parameters
There are currently no additional parameters that need to be specified aside from the global parameters listed above