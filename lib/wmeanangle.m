function y = wmeanangle(x,w,dim)
% WMEANANGLE weighted mean angle (in rad)
%   WMEANANGLE(X,WEIGHTS) returns the weighted mean angle (rad) of the 
%   elements along the first non-singleton dimension of X.
%
%   WMEANANGLE(X,WEIGHTS,DIM) returns the weighted mean angle (rad) along 
%   dimension DIM of X.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 29, 2019
%
% Revisions:    0.1 (Oct 29, 2019)
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
if nargin<2
    error('Not enough input arguments. WMEANANGLE(X,WEIGHTS)');
end
if nargin<3
    dim = find(size(x)~=1, 1);
    if isempty(dim)
        dim = 1; 
    end
end

if ~isreal(x)
    x = angle(x);
end

y = wmean(exp(1j*x),w,dim);
y = angle(y);

end