function set_peaks( this, peaks_ppm, peak_names )
%SET_PEAKS sets the ppm reference of the peaks of interest
%   set_peaks() trys to automatically detect peaks
%
%   set_peaks([0.9, 1.3], {'peak a', 'peak b'}) sets e.g. two peaks to 0.9
%   and 1.3 ppm named "peak a" and "peak b", respectively.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 04, 2019
%
% Revisions: 	0.1 (Apr 04, 2019)
%				Initial version.
%               1.1 (Oct 21, 2019)
%               Added handling for multiple quantifications.
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

FFT_ZEROFILL_FACTOR = 4;
PEAK_CUTOFF = 0.01; % min. relative peak amplitude with respect to the maximum peak amplitude

if nargin < 2

    data = ALFONSO.apodize( this.get_data( 'x' ) );
    % peak auto detection
    spec = this.ifft( data, this.dims_siz(1) * FFT_ZEROFILL_FACTOR );
    %figure;hold all;plot(abs(spec(:,1)));plot(real(spec(:,1)))
    spec = abs(spec(:,1));
    
    
    % get low SNR regions
    signal_mask = 1:(length(spec)-1);
    signal_mask = signal_mask(spec(1:end-1) < (max(spec) * PEAK_CUTOFF));
    
    % first derivative
    d1 = circshift(smooth(diff(spec)),1);
    d1zx = ALFONSO.get_zerox(d1);
    %d1zx = d1zx + 1;
    
    % second derivative
    d2 = circshift(smooth(diff(spec,2)),2);
    
    % ensure we do not overshoop vector size
    if max(d1zx) > length(d2)
        d1zx(d1zx > length(d2)) = [];
    end
    
    d1zx = d1zx(d2(d1zx) < 0);
    
    % exclude low SNR peaks
    d1zx(logical(sum(d1zx == signal_mask,2))) = [];
    
    % debug:
    if 0
        figure;hold all;
        plot(spec);
        plot(d1zx,spec(d1zx),'*')
        plot(d1);
        plot(d1zx,d1(d1zx),'*')
        plot(d2);
        plot(d1zx,d2(d1zx),'*')
    end
    
    peaks_ppm = this.scanparam.ppm_rel(round(d1zx / FFT_ZEROFILL_FACTOR));
    
end

if nargin < 3
    % auto set peak names
    n_peaks = length(peaks_ppm);
    for i = 1:n_peaks
        peak_names{i} = ['@' num2str(peaks_ppm(i),3) 'ppm'];
    end
end

if length(peaks_ppm) ~= length(peak_names)
    error('set_peaks: SIZ(peaks_ppm) ~= SIZ(peak_names)!')
end

this.quant{this.cur_quant}.peaks.ppm = peaks_ppm;
this.quant{this.cur_quant}.peaks.names = peak_names;

[~,idx] = min(abs(peaks_ppm-this.scanparam.ppm_rel'));
this.quant{this.cur_quant}.peaks.ppm_rel_idx = idx;

end