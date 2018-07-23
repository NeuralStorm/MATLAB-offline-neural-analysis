function delete_char(numchar)

rep='%c';
del=',8';
str=['fprintf(''',repmat(rep,1,numchar),'''',repmat(del,1,numchar),')'];
eval(str);