function get_ppm_scale( this )
% GET_PPM_SCALE calculates the ppm scale and writes the info to scanparam
%   The following parameters will be calculated and updated: 
%       - scanparam.freq_abs
%       - scanparam.freq_rel
%       - scanparam.ppm_abs
%       - scanparam.ppm_rel
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 15, 2018
%
% Revisions: 	1.0 (Oct 15, 2018)
%				Initial version.
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

nReadoutPoints = size(this.data,1);

this.scanparam.freq_abs = ((0:nReadoutPoints-1) - (0.5 * nReadoutPoints)) * this.scanparam.bandwidth_Hz ./ nReadoutPoints;
this.scanparam.freq_rel = this.scanparam.freq_abs + this.scanparam.acq_window_center_ppm * this.scanparam.fieldstrength_T * this.scanparam.gamma_bar * 1e-6;
this.scanparam.ppm_abs = this.scanparam.freq_abs * this.scanparam.freqsign ./ (this.scanparam.fieldstrength_T * this.scanparam.gamma_bar * 1e-6);
this.scanparam.ppm_rel = this.scanparam.ppm_abs + this.scanparam.acq_window_center_ppm;

end

