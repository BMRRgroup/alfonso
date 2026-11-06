function [ fid ] = bandpassfilter( this, fid, freq_band_ppm )
%BANDPASSFILTER performs 1D bandpass filtering of the FID in the SPECTRAL
% domain. 
%   Input parameters:
%   fid - Array of free inducation decays (FIDS) with FID in first
%         dimension
%   freq_band_ppm - bandpass filter range in ppm, e.g. [0 6] (in ppm).
%
%   Returns filtered FID array
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 13, 2022
%
% Revisions: 	0.1 (Oct 13, 2022)
%					Initial version.
%               0.1.1 (Jun 6, 2024)
%                   Fixed bandpass filter flag
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

DEBUG = 0;


if nargin < 2 % perform bandpass filtering on directly on the data
    if ~this.flags.bandpassfilter
        warning('ALFONSO:bandpassfilter:AlreadyApplied', ...
            'Bandpass filtering was already performed on this data.')
    end

    if this.reconparam.bandpassfilter.enable

        fid = this.get_data({'x'});

    else
        fid = [];
        return;
    end

end

if ~exist('freq_band_ppm', 'var')
    freq_band_ppm = this.quantparam.bandpassfilter.param.freq_band_ppm;
end

SPEC = this.ifft(fid);

[ ~, idx1 ] = min( abs( this.scanparam.ppm_rel - freq_band_ppm(1) ) );
[ ~, idx2 ] = min( abs( this.scanparam.ppm_rel - freq_band_ppm(2) ) );

band_window = sort([idx1 idx2]);

filter_len = size(fid,1);

filter = [cos(linspace(1,0,band_window(1)-1)).^(filter_len*2) ones(1,diff(band_window)+1) cos(linspace(0,1,filter_len-band_window(2))).^(filter_len*2)].';

% debug helper
if DEBUG
    debug_idx = 1;
    figure
    subplot(2,1,1)
    hold all
    title('FIT / bandpassed FID')
    plot(abs(fid(:,debug_idx)))
    plot(angle(fid(:,debug_idx)))
    
    
    corr_data = this.fft(abs(SPEC(:,debug_idx)).*filter .* exp(1j .* angle(SPEC(:,debug_idx)).*filter));
    plot(abs(corr_data))
    plot(angle(corr_data))
    
    
    subplot(2,1,2)
    hold all
    
    title('spectrum / filter / bandpassed spectrum')
    plot(this.scanparam.ppm_rel,abs(SPEC(:,debug_idx)))
    plot(this.scanparam.ppm_rel,angle(SPEC(:,debug_idx)))
    plot(this.scanparam.ppm_rel,filter .* max(abs(SPEC(:,debug_idx))))
    
    
    plot(this.scanparam.ppm_rel,abs(SPEC(:,debug_idx)).*filter)
    plot(this.scanparam.ppm_rel,angle(SPEC(:,debug_idx)).*filter)
    
end

fid = this.fft(abs(SPEC).*filter .* exp(1j .* angle(SPEC).*filter));

if nargin < 2

    this.set_data( fid, {'x'} );

    this.flags.bandpassfilter = 1;

end

end
