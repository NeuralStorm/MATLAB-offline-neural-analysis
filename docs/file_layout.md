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
