# parsing_main

## Summary

This function takes in raw neural data (`.rhs`/`.rhd`/`.plx`/`.pl2`) and converts it into browseable `.mat` files. It is very important to make sure that the file structure and all filenames follow the conventions described in the [general MONA documentation](https://github.com/NeuralStorm/docs/edit/kev-rewrites/offline_analysis/readme.md). After making sure that MONA is on your Matlab path, run `parser_main` in the command window to start the program.

## Program Workflow

 1. Request project directory containing config, labels, and raw data.
 2. Read in parser configuration (`conf_parser.csv`) and subject listing (`subjID.csv`).
 3. Extract raw information from proprietary data formats.
 4. Save said information to a `.mat` file.

## Configuration File

|Parameter|Description|Format|
|:-|:-|:-|
|`dir_name`|	Name of main directory containing raw data.|	`String`
|`include_dir`|	Whether the directory ought to be searched.|	`Boolean`
|`include_sessions`|	Controls which recording sessions are analyzed.| `6`/`Array`
|`recording_type`|	Description of data type.|	`spike`/`continuous`
