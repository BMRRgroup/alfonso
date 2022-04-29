function frequency_offset_correction( this )
%FREQUENCY_OFFSET_CORRECTION tries to correct for freuquency offsets
%   by fitting a linear phase to the time domain signal
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 23, 2018
%
% Revisions: 	0.1 (Oct 23, 2018)
%                   Initial version.
%               0.2 (Oct 24, 2019)
%                   Bugfixed fft
%               0.3 (Oct 08, 2020)
%                   Improved version using reconparam
%                   frequency_offset_correction.crosscorr_max_ppm_shift
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

DEBUG = this.reconparam.frequency_offset_correction.debug;

if this.reconparam.frequency_offset_correction.enable && ~this.flags.frequency_offset_correction
    
    fidSignalArray = this.get_data({'x'});
    
    spec = this.ifft( this.apodize( fidSignalArray ) );
    
    output = get_profile_shifts( spec );
    
    this.reconparam.frequency_offset_correction.shifts = output.shifts;
    this.reconparam.frequency_offset_correction.corr_func = output.corr_func;
    
    if DEBUG
        figure;
        hold all
        title('Frequency offset correction: estimated shifts')
        plot(output.shifts.*size(spec,1))
        xlabel('profile #')
        ylabel('profile shift against reference')
        
        figure;
        hold all
        title('Frequency offset correction: estimated shifts')
        plot(abs(ALFONSO.ifft(fidSignalArray .* output.corr_func)))
        %xlabel('profile #')
        %ylabel('profile shift against reference')
    end
    
    % apply correction
    fidSignalArray = fidSignalArray .* output.corr_func;
    
    if DEBUG
        figure;
        plot(abs(ALFONSO.ifft(fidSignalArray)))
        title('Frequency offset correction: Corrected abosolute spectra')
    end
    
    this.set_data( fidSignalArray, {'x'} )
    
    this.flags.frequency_offset_correction = 1;
else
    warning('Skipped ALFONSO.frequency_offset_correction.')
end

    function output = get_profile_shifts( spec )
        
        n = size(spec,1);
        
        padfactor = 4;
        N = padfactor * n;
        x = linspace(0,1,n);
        fftc = @(x) ALFONSO.fft(x);
        ifftc = @(x) ALFONSO.ifft(x, N);
        phasor = @(k) exp(1j * k .* x(:));
        
        % set MAXLEG based on the
        ppm_per_sample = abs(this.scanparam.ppm_abs(2)-this.scanparam.ppm_abs(1));
        MAXLAG = ceil(this.reconparam.frequency_offset_correction.max_ppm_shift / ppm_per_sample * padfactor);
        
        A = abs(diff(ifftc(fftc(spec(:,:)))));
        
        d = finddelay(A(:,1),A(:,:),MAXLAG);
        
        % OPTIONAL TODO:
        % replace with xcorr2 (does not support MAXLEG)
        % c = xcorr2(A(:,1),A(:,:),MAXLAG));
        
        k = 2*pi*d/padfactor;
        corr_func = phasor(to_col(k));
        
        output.shifts = k;
        output.corr_func = corr_func;
        
    end

end

