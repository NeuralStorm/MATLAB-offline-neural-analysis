# Required Base Layout

The Matlab Offline Neural Analysis program makes a number of assumptions regarding the file layout of the target directory, and these must be followed if the program is to run successfully. The layout should consist of a top level project folder containing the labels file for each subject and the configuration file for each main function. The project folder also contains a folder labeled `raw`, which should contain all of the directories listed in the configuration file. These should generally be named after individual subjects.

To better illustrate this, here is a sample layout in which `conf_mainFn.csv` here is a stand-in for whichever main functions are to be run, such as `conf_recfield.csv` or `conf_mnts.csv`.

```
Project_ABC
    ├──labels_ABC001.csv
    ├──labels_ABC###.csv
    ├──conf_parser.csv
    ├──conf_mainFn.csv
    ├──raw
    |    ├──ABC001
    |    |    └──supported raw file format (plx/pl2, rhs/rhd, etc)
    |    ├──ABC###
    |    |    └──supported raw file format (plx/pl2, rhs/rhd, etc)
```

|**Warning!**|
|:-|
|If you re-run the program after previously generating files, MONA will **overwrite** existing files in the working directory. To avoid this, save your output after using any main function.

Here is a comprehensive sample layout of a directory that has been run through the entire MONA pipeline:

```
Project_ABC_experiment
    ├──ABC001_labels.csv
    ├──ABC###_labels.csv
    ├──mnts_config.csv
    ├──parser_config.csv
    ├──psth_config.csv
    ├──continuous_config.csv
    ├──raw
    |    ├──ABC001
    |    |    ├──*.rhd
    |    |    └──*.plx
    |    ├──ABC###
    |    |    ├──*.rhs
    |    |    └──*.plx
    ├──parsed_spike
    |    ├──ABC001
    |    |    ├──*.mat
    |    |    └──ABC001_labels_log.csv
    |    ├──ABC###
    |    |    ├──*.mat
    |    |    └──ABC001_labels_log.csv
    |    └──parser_config_log.csv
    ├──psth
    |    ├──data
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    |    ├──rec_field
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    |    ├──classifier
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    |    ├──normalized_variance
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    |    ├──mutual_info
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    |    ├──psth_graphs
    |    ├──receptive_field_results.csv
    |    ├──normalized_variance_results.csv
    |    ├──pop_classifier_results.csv
    |    ├──unit_classifier_results.csv
    |    └──psth_config_log.csv
    ├──MNTS
    |    ├──data
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    |    ├──ica
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    |    ├──pca
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    ├──ica_psth (same layout as psth above)
    ├──pca_psth (same layout as psth above)
    ├──parsed_continuous
    |    ├──ABC001
    |    |    ├──*.mat
    |    |    └──ABC001_labels_log.csv
    |    ├──ABC###
    |    |    ├──*.mat
    |    |    └──ABC001_labels_log.csv
    |    └──parser_config_log.csv
    ├──continuous
    |    ├──filtered_data
    |    |    ├──ABC001
    |    |    |    ├──*.mat
    |    |    |    └──ABC001_log.csv
    |    |    ├──ABC###
    |    |    |    ├──*.mat
    |    |    |    └──ABC###_log.csv
    |    ├──sep
    |    |    ├──sep_formatted_data
    |    |    |    ├──ABC001
    |    |    |    |    ├──*.mat
    |    |    |    |    └──ABC001_log.csv
    |    |    |    ├──ABC###
    |    |    |    |    ├──*.mat
    |    |    |    |    └──ABC###_log.csv
    |    |    ├──sep_gui_data
    |    |    |    ├──ABC001
    |    |    |    |    └──*.mat
    |    |    |    ├──ABC###
    |    |    |    |    └──*.mat
    |    |    |    └──sep_results.csv
    |    |    ├──sep_autoanalysis_data
    |    |    |    ├──ABC001
    |    |    |    |    ├──*.mat
    |    |    |    |    └──ABC001_log.csv
    |    |    |    ├──ABC###
    |    |    |    |    ├──*.mat
    |    |    |    |    └──ABC###_log.csv
    ```
