function rho = model_TAG( ndb, nmidb, CL, num_freq )
%MODEL_TAG calculates model peak amplitudes based on ndb, nmidb, CL and #
%num_freq (number of frequencies).
%
%   rho = model_TAG( ndb, nmidb, CL ) assumes the 10 peak fat model and
%   returns normalized rho vector.
%
%   rho = model_TAG( ndb, nmidb, CL, N ) assumes the N peak fat model and
%   returns normalized rho vector. N has to be known by ALFONSO/get_TAGmat.
%
% References:
%   Triglyceride model: 
%       1. Hamilton et al. “In vivo characterization of the liver fat 1H MR 
%           spectrum.,” NMR Biomed, vol. 24, no. 7, pp. 784–790, Aug. 2011.
%
% See also ALFONSO/get_TAGmat
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 15, 2018
%
% Revisions:    0.1 (Oct 15, 2018)
%                   Initial version.
%               0.2 (Nov 2, 2018)
%                   Added rho normalization.
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

if nargin < 4
    num_freq = 10;
end

M = ALFONSO.get_TAGmat(num_freq); 

x = [1; ndb; nmidb; CL];

rho = M * x;

% normalization
rho = rho ./ sum(rho(:));

end

