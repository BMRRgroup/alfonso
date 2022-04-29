function SNR = get_SNR( this, threshhold )
%GET_SNR estimates the signal to noise ratio as the maximum signal over the
%standard deviation of the noise signal
%   SNR = ALFONSO.get_SNR() estimates the SNR as the maximum absolute signal
%   over the standard deviation of the noise. The noise is expected to be
%   in the last 5% of the samples.
%   SNR = ALFONSO.get_SNR( threshhold ) noise only is expected to be in the
%   last 'threshold' % of the samples.
%
% See also ALFONSO/add_noise
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

if ~exist('threshhold', 'var')
    threshhold = 0.05;
end

data = this.get_data('x');

num_samples = size(data, 1);

noise = data(end-round( num_samples * threshhold ):end,:);

S_max = max(abs(data(:)));

SD_noise = std(noise(:));

SNR = S_max / SD_noise;

end

