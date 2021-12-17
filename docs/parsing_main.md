# parser_main
## Steps in parser_main
1. Select project directory with config, labels, and data
    * conf_parser.csv
    * subjID.csv
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
### Global Variables
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|dir_name|char/str|Name of directory with data. Typically subject ID|
|include_dir|boolean|Controls if directory passes through main|
|include_sessions|int|Controls if a given recording session file is analyzed|
|recording_type|string|controls what info is pulled. Valid options: plexon: spike; intan: continuous|