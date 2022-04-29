function Xb = bound_tanh(X, LB, UB)
%BOUND_TANH returns X using a tanh as bound function
%   Xb = bound_tanh(X, LB, UB) bounds X between the lower bound LB and
%   upper bound UB. 
%
% See also ALFONSO/bound_inv_tanh
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

Xb = ((tanh(X) + 1) .* 0.5) .* (UB - LB) + LB;

end

