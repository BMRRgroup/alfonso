function [data, meta] = read_ImDataParams( ImDataParamsFile )
%read_ImDataParams reads imaging data from a ImDataParams.mat file
%   [ data, meta ] = read_ImDataParams( ImDataParamsFile ) returns data,
%      meta information from the passed ImDataParamsFile file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 27, 2022
%
% Revisions:    0.1 (Sep 27, 2022)
%					Initial version.
%
% Authors:
%
%   Stefan Ruschke (stefan.ruschke@tum.de)
%
% -------------------------------------------------------------------------
%
% Body Magnetic Resonance Research Group
% Department of Diagnostic and Interventional Radiology
% Technical University of Munich
% Klinikum rechts der Isar
% 22 Ismaninger St., 81675 Munich
%
% https://www.bmrr.de
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filedata = load( ImDataParamsFile, 'ImDataParams');

% set data
data = filedata.ImDataParams.signal;
%meta.dimensions = {'loc_x', 'loc_y', 'loc_z', 'x', 'average'};
meta.dimensions = {'loc_x', 'loc_y', 'x', 'average'};


[~, meta.scan_name] = fileparts(replace(ImDataParamsFile, '_ImDataParams.mat', '.mat'));

meta.n_dyn = 1;
meta.n_mix = 1;
meta.n_coil = 1;
meta.n_echo = 1;
meta.n_loc = prod(size(data,[1 2]));
meta.loc_dims = size(data,[1 2]);
meta.n_aver = size(data,4);
meta.n_sample = size(data,3);

% data = reshape(data, meta.n_loc, size(data,3), size(data,4));

meta.voxel_size_mm = filedata.ImDataParams.voxelSize_mm;
meta.fieldstrength_T = filedata.ImDataParams.fieldStrength_T;
meta.bandwidth_Hz = 1/(filedata.ImDataParams.TE_s(2)-filedata.ImDataParams.TE_s(1));
meta.gamma_bar = filedata.ImDataParams.centerFreq_Hz / meta.fieldstrength_T; % Hz / Tesla
meta.freqsign = -1;
meta.TE_s = 0 .* 1e-3;
meta.TM_s = [];
meta.bvalue_spm2 = [];
meta.TR_s = [];
meta.TI_s = [];
meta.acq_n = [];
meta.acq_window_center_ppm = 4.67;
meta.dynSeries = [];
meta.dynSeries2 = [];
meta.diffusion_gradient_mode = [];
meta.tau_s = [];
meta.spir_const_tau = 0;
meta.metcycle = 0;
meta.patient_id = [];
meta.series_time = [];
meta.series_number = [];
meta.sampling_time_s = filedata.ImDataParams.TE_s;

try % try to load initial fieldmap if WFIparams file exists fieldmap
    filedata = load( replace(ImDataParamsFile, 'ImDataParams', 'WFIParams' ), 'WFIparams' );
    meta.fieldmap_Hz = filedata.WFIparams.fieldmap_Hz;
    meta.init_maps.water = filedata.WFIparams.water;
    meta.init_maps.fat = filedata.WFIparams.fat;
    meta.init_maps.r2starmap = filedata.WFIparams.r2starmap;
    meta.init_maps.fatFraction_percent = filedata.WFIparams.fatFraction_percent;
catch
    warning('Fieldmap information not loaded from WFIparams.');
end

end
