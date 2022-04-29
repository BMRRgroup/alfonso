function [ppm] = hertz2ppm(this, freq_Hz)
%HERTZ2PPM converts frequency in Hertz to the corresponding ppm (parts per 
% million) based on the scan parameter.
%   ppm = freq_Hz / (carrier_frequency_Hz * 10^-6)
%
% See also ALFONSO/ppm2hertz
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

ppm = freq_Hz ./ (this.scanparam.gamma_bar .* this.scanparam.fieldstrength_T .* 1e-6);

end

