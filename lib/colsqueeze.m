function [ B ] = colsqueeze( A )
%COLSQUEEZE removes singleton dimensions and returns a column vector (if
%vector)
%   [ B ] = colsqueeze( A ) returns an array B with the same elements as
%   A with all singleton dimensions removed (exactly like squeeze) and
%   ensures that vectors are returned as column vectors.
%
%   See also squeeze
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B = squeeze(A);
if isrow(A)
    B = A.';
end
end