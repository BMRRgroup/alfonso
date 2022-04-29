function [ spec ] = ifft( fid, zerofilling, dim)
%IFFT performs the iFFT (inverse fast Fourier transform) from time domain to 
%   frequency domain. 
%   [ spec ] = ALFONSO.ifft( fid ) performs the fourier transform along the first
%   dimesion without zero filling. 
%   [ spec ] = ALFONSO.ifft( fid, zerofilling ) performs the fourier transform 
%   along the first dimesion with the specified zero filling. 
%   [ spec ] = ALFONSO.ifft( fid, [], dim ) performs the fourier transform 
%   along the specified dimesion dim. 
%
% See also ALFONSO/fft
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 26, 2020
%
% Revisions:    0.1 (Mar 26, 2020)
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

if ~exist('dim', 'var')
    dim = 1;
end

if ~exist('zerofilling', 'var')
    zerofilling = [];
end

if isempty(zerofilling)
    n = size(fid, dim);
else
    n = zerofilling;
end

spec = sqrt(n) .* fftshift( ifft( fid, zerofilling, dim ), dim );

end