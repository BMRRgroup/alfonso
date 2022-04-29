function t = get_timedomain_sampling( this )
%GET_TIMEDOMAIN_SAMPLING returns the sampling vector of the time domain
%signal
%   t = ALFONSO.get_timedomain_sampling() returns the time domain sampling 
%   vector t in units of seconds * 2 * PI for the present dataset. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 28, 2020
%
% Revisions: 	0.1 (Mar 28, 2020)
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

sampling_time_s = this.scanparam.bandwidth_Hz.^-1 ;
t = (0:this.scanparam.n_sample-1) .* sampling_time_s .* ( 2 * pi);

end

