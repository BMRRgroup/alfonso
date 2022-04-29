function [freq_Hz] = ppm2hertz(this, ppm)
%PPM2HERTZ converts ppm (parts per million) to the corresponding frequency
%in Hertz based on the scan parameters.
%   freq_Hz = ALFONSO.ppm2hertz(ppm) ppm to Hertz conversion using the 
%   formula freq_Hz = ppm * carrier_frequency_Hz * 10^-6
%
% See also ALFONSO/hertz2ppm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 20, 2020
%
% Revisions:    0.1 (Mar 20, 2020)
%					Initial version.
%
% Authors: 
%
%   stefan.ruschke@tum.de
% 
% --------------------------------
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

freq_Hz = ppm .* this.scanparam.gamma_bar .* this.scanparam.fieldstrength_T .* 1e-6;

end
