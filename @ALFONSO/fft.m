function [ spec ] = fft( fid , zerofilling, dim)
%FFT performs the FFT (fast fourier Transform) from frequency domain to 
%time domain. 
%   [ spec ] = ALFONSO.fft( fid ) performs the fourier transform along the 
%   first dimesion. 
%   [ spec ] = ALFONSO.fft( fid, zerofilling ) performs the fourier transform 
%   along the first dimesion with the specified zero filling. 
%   [ spec ] = ALFONSO.fft( fid, [], dim ) performs the fourier transform 
%   along the specified dimesion dim. 
%
%   See also ALFONSO/ifft
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

spec = 1 / sqrt(n) .* fft( fftshift( fid, dim ), zerofilling, dim );

end

