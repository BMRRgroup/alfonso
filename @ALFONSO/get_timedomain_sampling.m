function t = get_timedomain_sampling( this )
%GET_TIMEDOMAIN_SAMPLING returns the sampling vector of the time domain
%signal
%   t = ALFONSO.get_timedomain_sampling() returns the time domain sampling
%   vector t in units of seconds for the current dataset.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 28, 2020
%
% Revisions:    0.1 (Mar 28, 2020)
%                   Initial version.
%               0.2 (Oct 08, 2022)
%                   Returned vector t in units of seconds from now on.
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

if isfield(this.scanparam, 'sampling_time_s') && ~isempty( this.scanparam.sampling_time_s )
    t = this.scanparam.sampling_time_s;
else
    sampling_time_s = this.scanparam.bandwidth_Hz.^-1 ;
    t = (0:this.scanparam.n_sample-1) .* sampling_time_s;
end

end
