# Required Base Layout
This is the base layout required to start running the code from the parser main. See the [parser main page](https://github.com/moxon-lab-codebase/MATLAB-offline-neural-analysis/wiki/Parser-Main) for a complete lists of current supported parsing formats.  

There is a conf file for each main function. Please see the respictive markdown page for a desired analysis for more details on what parameters are needed.
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
Note that `conf_mainFn.csv`, `mainFn` is a place holder for the main that you intend to run. For example, if you intend to run the `recfielf_main` function, then that function will require `conf_recfield.csv` whereas the `mnts_main` function requires the `conf_mnts.csv`.