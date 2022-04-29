function y = meanangle(x,dim)
% MEANANGLE weighted mean angle (rad)
%   MEANANGLE(X) returns the mean angle (rad) of the elements along the 
%   first non-singleton dimension of X.
%
%   MEANANGLE(X,DIM) returns the mean angle (rad) along dimension DIM of X.
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
    dim = find(size(x)~=1, 1);
    if isempty(dim)
        dim = 1; 
    end
end

if ~isreal(x)
    x = angle(x);
end

y = mean(exp(1j*x),dim);
y = angle(y);

end