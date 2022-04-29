function addALFONSO2path()
%ADDALFONSO2PATH adds ALFONSO to the MATLAB path

% add all subdirectories except hidden .git directories
addpath(regexprep(genpath('./'), '(:[\w-/.]*\.git[\w-/.]*)', ''))

end