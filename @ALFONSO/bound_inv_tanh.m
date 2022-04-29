function X = bound_inv_tanh(Xb, LB, UB)
%BOUND_INV_TANH returns the X for a bound Xb using the tanh bound function
%   X = bound_inv_tanh(Xb, LB, UB) returns X for the bound Xb. 
%
% See also ALFONSO/bound_tanh
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

X = atanh( (Xb - LB) ./ (UB - LB) ./ 0.5 - 1 );

end

