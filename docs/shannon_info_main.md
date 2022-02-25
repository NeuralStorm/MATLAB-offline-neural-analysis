# shannon_info_main
## Steps in shannon_info_main
1. Select project directory with config, labels, and data
    * conf_shannon_info.csv
    * labels_subjID.csv
2. Directory with relative response picked by config
    * create rr directly if necessary
3. Calculate Shanon Mutual Information
---
# Running shannon_info_main  
1. Make sure data is organized in proper file structure. [See here for more details.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/file_layout.md)
2. Make sure filenames match [naming convention.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/filename_convention.md)
3. Make sure offline codebase is on your Matlab path. [Click here for details on adding dependencies](https://github.com/moxon-lab-codebase/docs/blob/main/matlab_basics/adding_dependencies.md).
4. [Make a labels file for each subject.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/labels_file.md)
    * labels_subjID.csv
5. Set up config file. See config section below for more details.
    * conf_shannon_info.csv
6. Run `shannon_info_main` in Matlab's command window and select path to project directory.

## Config
    * conf_shannon_info.csv
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

## Shannon Info Output
The Shannon Info Analysis will output a csv file containing the results across subjects and session files called `res_type_shannon_info.csv` on the top level of the project directory, where type = psth_type set in config.
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

### Shannon Info Params
All of these columns are set in the config described above.

|Variable Name| Description |
|:-----------:| :----------:|
|bin_size|see above|
|window_start|see above|
|window_end|see above|
|response_start|see above|
|response_end|see above|

### Shannon Info Results
|Variable Name| Description |
|:-----------:| :----------:|
|entropy_time|Entropy calculated from all the unique timing patterns found in response window across trials|
|entropy_count|Entropy calculated from unique spike counts found in response window across trials|
|mutual_info_time|Mutual info for events based on unique timing patterns across trials and events|
|mutual_info_count|Mutual info for events based on unique counts across trials and events|