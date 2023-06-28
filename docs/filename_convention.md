All files that are being ran through the codebase have an assumed filename convention. Currently that convention looks like this:

EXA001_ExperimentalGroup_ExperimentalCondition_#_YYYYMMDD_option.ext

EXA = Study ID (type: string)
001 = Animal ID (type: string)
ExperimentalGroup = control, sham, etc (type: string)
ExperimentalCondition = OpenLoop, Opt, etc. (type: integer)
# = recording session (type: integer)
YYYYMMDD = date (type: string)
option = additional desired info
ext = file extension

For example: EXA001_control_opto_1_20190101_option.ext

NOTE: Recording session type requirement will change from int to string in future versions.
