# Matlab Offline Neural Analysis (MONA)

## Important Note

The Moxon Neurorobotics Laboratory maintains a [Codebase Master Document](https://ucdavis.box.com/s/icsjygmi2bkcv1275xskigibiewahd3p) that introduces users to key concepts that are helpful for properly understanding, installing, and using this program. It is highly recommended that new users and lab members review the document in its entirety before proceeding.


## Content Guide

- **[Summary](#Summary)**: Explanation of program purpose, its required inputs, and its expected outputs.
- **[Pipeline](#Pipeline)**: Ordered list of what the program does when.
- **[Terminology](#Terminology)**: Index of key terms commonly used in MONA documentation.
- **[Usage Guide](#Usage-Guide)**: How to use the program.
    - **[Installation](#Installation)**: How to install the program.
    - **[Labels File](#Labels-File)**: Explanation of the labels file and its contents.
    - **[Config File](#Config-File)**: Explanation of the config file and its contents.
    - **[Running the Program](#Running-Program)**: Breakdown of how the program is run.

## <a name="Summary">Summary</a>

This program takes raw neural data, converts it into relative response matrices, runs a number of analyses, and visualizes aspects of the processed data. MONA is intentionally modular and most of its functions and plots are entirely optional, and it is **strongly** recommended that users read this documentation in its entirety so as to understand how to opt in and out of specific aspects of this program.

MONA accepts the following files, **which must be provided by the user**:
|Terminology          |Contents                                                |Accepted File Formats|
|---------------------|--------------------------------------------------------|:---------------------:|
|Raw neural data|Contains the raw data to be converted and analyzed.                  |`.plx`/`.pl2`/`.rhd`/`.rhs` [^dataform]     |
|Labels file          |Contains channel mapping information.                   |`.csv`    |
|Config file          |Contains modifiable parameters and arguments.           |`.csv`    |

[^dataform]: Please note that spike data will generally use the `.plx`/`.pl2` formats, while continuous data will generally use the `.rhd`/`.rhs` formats.

Once properly run, **the program will return these files**:
|Terminology                |Contents                          |Expected File Formats                         |
|----------------|-------------------------------|:-----------------------------:|
|PSTH Format[^rrm]|File containing relative response matrix as well as channel & event information.            |`.mat`            |

[^rrm]: Within the PSTH format files, users can find relative response matrices for the various regions included in a recording, event information featuring the timestamps and trial indices of different event types, channel information featuring the names assigned to each channel and some of the configurable parameters associated with each of them (e.g. was a given channel configured to be included in any analyses?), and some further mapping information. 

Each of these inputs and outputs is discussed in further detail down below, and we again strongly encourage new users to read this documentation in its entirety to obtain a comprehensive understanding of what the program does and how to make proper use of it.

## <a name="Pipeline">Pipeline</a>

The program is divided into a number of modular components that each handle a different part of the greater pipeline, and which can each be run either on their own or through a batch process.

1. **Loading and Parsing** (Handled by `parser_main.m`.)
    1. Request project directory containing config, labels, and raw data.
    2. Read in parser configuration (`conf_parser.csv`) and subject listing (`subjID.csv`).
    3. Extract raw information from proprietary data formats.
    4. Save said information to a `.mat` file.

2. **Receptive Field Analysis** (Handled by `recfield_main.m`.)
    1. Preliminary Handling
        1. Request project directory containing config, labels, and raw data.
        2. Read in receptive field analysis configuration (`conf_recfield.csv`) and subject labels (`labels_subjID.csv`).
        3. Generate relative response matrix using raw neural data.
        4. Save relative response matrix to PSTH format file.
        
    2. Actual Analysis
        1. Receptive Field Analysis
        2. Cluster Analysis (Optional.)

    3. Plotting Routines
        1. Plot peri-stimulus time histogram.
        2. Plot receptive field measures.
        3. Save all plots to the graph directory.
    
3. **Euclidean Classifier**
    1. Preliminary Handling
        1. Request project directory containing config, labels, and parsed data.
        2. Read in receptive field analysis configuration (`conf_bootstrap_classifier.csv`) and subject labels (`labels_subjID.csv`).
        3. Generate relative response matrix using using parsed neural data.

    2. Classification
        1. Run Euclidean Distance PSTH classifier.
        2. Run bootstrap (Optional, only if `bootstrap_iterations` > 0).

4. **Shannon Mutual Information** (Handled by `shannon_info_main.m`.)
    1. Preliminary Handling
        1. Request project directory containing config, labels, and raw data.
        2. Read in receptive field analysis configuration (`conf_shannon_info.csv`) and subject labels (`labels_subjID.csv`).
        3. Load relative response matrix from directory listed in the config file. [^rrmsmi]
        4. Save relative response matrix to PSTH format file.
        
    2. Actual Analysis
        1. Calculate Shannon Mutual Information.

5. **Component Analysis (PCA/ICA)** (Handled by `mnts_main.m`.)

[^boot]: If `bootstrap_iterations` is greater than `0`, bootstrap classifier.
[^rrmsmi]: If the relative response matrix cannot be found in the specified directory, the program will attempt to generate it at this point.

## <a name="Terminology">Terminology</a>

We generally seek to describe selections of data using precise words. While there may not always be a perfect word that can capture all the possibilities of what a user might encounter throughout the course of using MONA, you can find an index of common terms whose use and meaning has been standardized for the purposes of this documentation [here](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/terminology.md).

## <a name="Usage-Guide">Usage Guide</a>

### <a name="Installation">Installation</a>

To install this program, follow the steps outlined in the Git tutorial within the [Codebase Master Document](https://ucdavis.box.com/s/icsjygmi2bkcv1275xskigibiewahd3p).

### <a name="Labels-File">Labels File</a>

As electrodes may be placed in different locations within the brain, label files are needed to allow end users to communicate some organization of these electrodes and the different groups they comprise to the program. Each label file must specify _**all**_ of the channels that are expected to appear in the raw neural data.

The columns MONA expects all labels files to contain are:
|Column label          |Contents                                                |Sample Values|
|---------------------|--------------------------------------------------------|:---------------------:|
|`sig_channels`|The name of each signal channel in the recording file.                  |`sig001a`/`wire1a`     |
|`selected_channels`          |Denotes whether each channel ought to be included in the processing to come. [^selchan]                   |`0`/`1`/`TRUE`/`FALSE`    |
|`user_channels`          |User-defined custom channel sortation.           |?    |
|`label`|The label under which each channel ought to be grouped.|`HLM1`/`Parietal`/`LEFT`|
|`label_id`|Unique ID associated with each label.|?|
|`recording_session`|Tracks and sorts channels and labels across multiple recording sessions.|`0`/`3`/`6`|
|`recording_notes`|Any notes experimenters had to make regarding a specific channel.|`got loose`/`ignore this one`

[^selchan]: Please note that `selected_channels` is *not* used during parsing, i.e. it is not used by `parser_main.m`. MONA always parses all channels listed in a labels file.

To further set appropriate expectations as to what label files should look like, here's a sample format:

|sig_channels|selected_channels|user_channels|label|label_id|recording_session|recording_notes|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|sig001a|1|sig001a|Right|1|1|Blah|
|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|
|sig064d|0|sig064|Left|2|1|Blah|
|sig001a|1|sig001|Right|1|2|Blah|
|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|&#8942;|
|sig064d|1|sigg064|Left|2|2|Blah|

Please keep in mind that label files are generally loaded in at the start of each main function (e.g. `parser_main.m`/`recfield_main.m`), and that the program will return an error if any of the label files are missing channels listed in the raw data.

### <a name="Config File">Config File</a>

The configuration files define a number of parameters that control whichever main function (e.g. `parser_main.m`/`recfield_main.m`) is being run. Unlike the labels files, of which only one is necessary for each subject, the program requires a different config file for each such function, generally named `conf_<func>.m`, e.g. `conf_parser.csv`/`conf_recfield.csv`. For details on what the configuration file of each function should look like, click on the appropriate markdown (`.md`) file here:

- [parsing_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/parsing_main.md)
- [recfield_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/recfield_main.md)
- [bootstrap_classifier_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/bootstrap_classifier_main.md)
- [dropping_classifier_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/dropping_classifier_main.md).
- [shannon_info_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/shannon_info_main.md)
- [window_classify_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/window_classify_main.md).

### <a name="running-program">Running the Program</a>

The Matlab Offline Neural Analysis programs makes a number of assumptions regarding the file layout and file naming conventions of the target directory, and these must be followed if the program is to run successfully. The layout should consist of a top level project folder containing the labels file for each subject and the configuration file for each main function. The project folder also contains a folder labeled `raw`, which should contain all of the directories listed in the configuration file. These should generally be named after individual subjects.

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

Each of the files in the `raw` directory should in follow the Moxon Neurorobotics Laboratory's codebase-wide naming conventions, which dictates that file names consist of the study ID, the animal ID, the experimental group, the experimental condition, the recording session, the date, and key notes. More on that [here](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md).

Once the project directory is properly set up, calling `parser_main` in Matlab will open a file window. After the project directory is defined, the parser will generate new directories containing the raw data parsed into `.mat` files. From there, the process can be repeated with any other main function, each of which will either create its own directory, populate the graph directory, or both.

[^negn]: Must be negative.
[^posn]: Must be positive.
[^negpre]: Must be negative if it precedes event onset.
