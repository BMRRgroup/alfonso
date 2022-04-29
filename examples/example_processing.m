clear
close all

addALFONSO2path();

% load MRS data from .data / .list MRS data
datafile = './tests/data/philips/data/al_19042022_1501389_12_1_wip_te_steamV4_raw_012.data';

DIR_OUT = './examples/temp/';

mrs = ALFONSO( datafile );

% reconparam.read_data.enable_cach = 1 % caches the raw data
% we can cache the raw data in the object itself, so we don't need to read
% in the data from the raw data file. This is useful in cases where it
% takes very long to read in the data from the actual raw file and one
% wants to rerun the processing multiple times.
mrs.reconparam.read_data.enable_cache = 1;
% 
mrs.read_data;

mrs.data_info;
mrs.coilcombination;
mrs.averaging;
mrs.phase_correction;
mrs.set_ref_freq('autoset-waterfat',1.3) % use methylene peak as reference

f = mrs.plot_dynSeries;

% save ALFONSOobj to mat file
mrs.save_obj('example_processing', DIR_OUT)
