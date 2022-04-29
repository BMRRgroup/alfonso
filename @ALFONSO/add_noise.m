function [noisy_data, noise] = add_noise(this, SNR )
%ADD_NOISE adds white Gaussian noise to the data
%   [noisy_data, noise] = ALFONSO.add_noise( SNR ) adds noise based to 
%   the requested SNR level, where SNR is defined as the ratio as the 
%   maximum signal over the standard deviation of the noise signal. The
%   data is written to the object if the number of output arguments is
%   zero.
%   ALFONSO.add_noise( SNR ) writes back the noisy data to the object and
%   overwrites ALFONSO.data.
%
% See also ALFONSO/get_SNR
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Jun 15, 2020
%
% Revisions:    0.1 (Jun 15, 2020)
%                   Initial version.
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

noisy_data = this.get_data({'x'});

S_max = max(abs(noisy_data(:)));

SD_noise = S_max / double(SNR);

noise = (SD_noise / sqrt(2)) .* (randn(size(noisy_data)) + 1j * randn(size(noisy_data)));

noisy_data = noisy_data + noise;

if nargout == 0
    this.set_data( noisy_data, {'x'});
end

end