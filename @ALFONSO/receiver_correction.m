function [fit, rcf] = receiver_correction( fit, fid )
%RECEIVER_CORRECTION performs a simple heuristic receiver correction on fit
%based on the measured fid
%   rcf = ALFONSO.receiver_correction( fit, fid ) returns for a
%   multi-dimensional fit array the receiver corrected fitted signal. The
%   fitted signal fit and the measured signal fid need to have the same
%   dimensionality and the first dimension needs to be the readout
%   dimensions.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	May 14, 2020
%
% Revisions: 	0.1 (May 14, 2020)
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

rcf = dimfun( @(x) x(1), abs(fid), 1) ./ dimfun( @(x) x(1), abs(fit), 1);

fit(1,:) = fit(1,:) .* rcf(1,:);

end
