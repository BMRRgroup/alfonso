clear
close all

addALFONSO2path();

% load MRS data from ALFONSOobj file (requires to run example_processing
% first)
datafile = './examples/temp/example_processing.mat';
DIR_OUT = './examples/temp/';

mrs = ALFONSO( datafile );

% perfrom quantification
mrs.set_model('./examples/example_waterfat.json', 1)
mrs.fit_model;
f{1} = mrs.plot_fit_model;

% perform quantification with rho being constrained to a trigylceride
% models and T2 constraints
mrs.set_model('./examples/example_waterfat_TAG10_cT2.json', 2)
mrs.fit_model;
f{2} = mrs.plot_fit_model;

% save ALFONSOobj including the quantifications to mat file
% automatic naming: bmrsobj.save_obj([], DIR_OUT)
mrs.save_obj('example_quantification', DIR_OUT)
