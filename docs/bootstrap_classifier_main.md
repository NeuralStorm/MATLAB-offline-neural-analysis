# bootstrap_classifier_main
## Steps in bootstrap_classifier_main
1. Select project directory with config, labels, and data
    * conf_bootstrap_classifier.csv
    * labels_subjID.csv
2. Format relative response matrix from neural data
3. Run Euclidean distance PSTH classifier
    * If bootstrap_iterations > 0, bootstrap classifier
---
# Running bootstrap_classifer_main
1. Make sure data is organized in proper file structure. [See here for more details.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/file_layout.md)
2. Make sure filenames match [naming convention.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/filename_convention.md)
3. Make sure offline codebase is on your Matlab path. [Click here for details on adding dependencies](https://github.com/moxon-lab-codebase/docs/blob/main/matlab_basics/adding_dependencies.md).
4. Make sure you have these other dependencies as well:
    * [Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html): This is used to help speed up plotting the PSTHS. This is not needed if you skip graphing
5. [Make a labels file for each subject.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/labels_file.md)
    * labels_subjID.csv
6. Set up config file. See config section below for more details.
    * conf_bootstrap_classifier.csv
7. Run `bootstrap_classifier_main` in Matlab's command window and select path to project directory.

## Config
    * conf_bootstrap_classifier.csv
### Global Variable
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|dir_name|char/str|Name of directory with data. Typically subject ID|
|include_dir|boolean|Controls if directory passes through main|
|include_sessions|int|Controls if a given recording session file is analyzed|
|psth_type|char/str|Determines if psth, pca, or ica data is used|
|bin_size|numerical|Temporal resolution of data is binning, or temporal resolution of relative response|
|window_start|numerical|Start of global event centered around trial onset|
|window_end|numerical|End of global event centered around trial onset|
|response_start|numerical|Start of response window|
|response_end|numerical|End of response window|

### Creating relative response
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|creaste_psth (should change name)|boolean|Controls if creating relative response from parsed spike data|
|trial_range|numerical|If creating relative response, selects which trials are used to make relative response|
|include_events|char/str|If creating relative response, selects which events are used to make relative response|

### PSTH Classifier
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|combine_chan_groups|boolean|0 = keeps chan_groups separate, 1 = combine all chan_groups together before classifying|
|boot_iterations|How many bootstrap iterations the bootstrapper will run|

## Classifier Output
The bootstrap classifier analysis will output a csv file containing the results across subjects and session files called `res_type_chan_eucl_classifier.csv` and `res_type_pop_eucl_classifier.csv` on the top level of the project directory, where type = psth_type set in config. The `chan` csv is the performance of classifying with each channel separately while the `pop` csv is the performance of using each chan_group to classify.

### Filename Info

|Variable Name| Description |
|:-----------:| :----------:|
|filename|Name of file where data was from|
|animal_id|subject id in filename|
|exp_group|subject experimental group in filename|
|exp_condition|subject experimental condition in filename|
|optional_info|any optional info in filename|
|date|date in filename|
|record_session|session in filename|

### Classifier Params
All of these columns are set in the config described above.

|Variable Name| Description |
|:-----------:| :----------:|
|bin_size|see above|
|window_start|see above|
|window_end|see above|
|response_start|see above|
|response_end|see above|
|include_events|see above|
|boot_iterations|see above|

### Classifier Results
The population and channel csv share the following columns.

|Variable Name| Description |
|:-----------:| :----------:|
|chan_group|Name of channel group specified in labels file|
|performance|Accuracy of classification|
|mutual_info|Mutual information calculated from confusion matrix generated during leave-one-out classification|
|boot_perf|Averaged bootstrapped performance after shuffling trial labels n times (n = boot_iterations)|
|boot_mutual_info|Averaged bootstrapped mutual information after shuffling trial labels n times (n = boot_iterations)|
|corrected_info|mutual_info - boot_mutual_info|

#### Channel
The channel CSV has these additional columns:

|Variable Name| Description |
|:-----------:| :----------:|
|channel|Name of channel|
|user_channels|List of user defined channel names retrieved from labels if applicapable.
|recording_notes|List of user notes retrieved from labels if applicapable|

#### Population
The population csv have these additional columns:

|Variable Name| Description |
|:-----------:| :----------:|
|synergy_redundancy|Difference of population and channel information|
|synergestic|If synergy_redundancy > 0, synergistic = 1 and 0 otherwise|