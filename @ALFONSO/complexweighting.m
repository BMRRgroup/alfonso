function [ weights, coil_weights ] = complexweighting( FID )
%COMPLEXWEIGHTING computes (coil) weights usning SVD
%   [ weights, coil_weights ] = complexweighting( FID ) returns weights and
%   coil_weights. 
%   Input: 
%       - FID dimensions: ( samples, coils, :)
%
% Reference:
%   - M. Bydder, G. Hamilton, T. Yokoo, and C. B. Sirlin, “Optimal 
%       phased-array combination for spectroscopy.,” Magn Reson Imaging, 
%       vol. 26, no. 6, pp. 847–850, Jul. 2008.
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

fig_mean = mean( FID, 3 );

[U,S,V] = svd( fig_mean );

av_weight = V(:,1) / sum(V(:,1)) * ones(1,size(FID,3));

coil_weights = av_weight(:,1); % select weights based on first avg

weights = permute(repmat(av_weight, [1, 1, size(FID,1)]), [3,1,2]);

end






