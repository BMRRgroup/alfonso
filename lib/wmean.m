function y = wmean(x,weights,dim)
%WMEAN weighted mean
%   WMEAN(X,WEIGHTS) returns the weighted mean value of the elements along 
%   the first non-singleton dimension of X.
%
%   WMEAN(X,WEIGHTS,DIM) returns the weighted mean along dimension DIM of X.
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
    error('Not enough input arguments: WMEAN(X,WEIGHTS)');
end
if nargin<3
    dim = find(size(x)~=1, 1);
    if isempty(dim)
        dim = 1; 
    end
end
if(~isequal(size(x), size(weights)))
    error('x and weights must be of the same size.');
end

y = sum(weights.*x,dim)./sum(weights,dim);

end