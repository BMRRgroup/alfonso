function init_scanparam( this )
%INIT_SCANPARAM initializes scanparam parameter fields
%   Initializesall scanparam parameter fields under ALFONSO.scanparam.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 21, 2022
%
% Revisions: 	0.1 (Apr 21, 2022)
%                   Initial version.
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

fields_empty = { ...
    'patient_id', ...
    'scan_name', ...
    'patient_id', ...
    'dynSeries', ...
    'dynSeries2', ...
    'dynSeries3', ...
    'TE_s', ...
    'TM_s', ...
    'TR_s', ...
    'TI_s', ...
    'bvalue', ...
    'diffusion_gradient_mode', ...
    'tau_s', ...
    'spir_const_tau', ...
    'voxel_size_mm', ...
    'bandwidth_Hz', ...
    'fieldstrength_T', ...
    'gamma_bar', ...
    'acq_window_center_ppm', ...
    'n_sample', ...
    'freqsign', ...
    'metcycle'
    };

for iField = length(fields_empty)
    this.scanparam.(fields_empty{iField}) = [];
end

end
