function averaging( this )
%AVERAGING performs simple mean signal averaging
%   Parameters:
%       reconparam.averaging.crosscorr_magn - perform magnitude-based
%           crosscorrelation before averaging
%
%   Metabolic cycling is considered (ON/OFF subtraction)  if indicated in
%   scanparam.metcycle. In this case, the new dimension metcycle will be
%   added after averaging.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 26, 2018
%
% Revisions: 	0.1 (Sep 26, 2018)
%                   Initial version.
%               0.2 (Oct 30, 2019)
%                   Improved crosscorrelation correction
%               0.3 (Oct 08, 2020)
%                   Bugfixed and improved X-correlation
%               0.4 (Oct 22, 2021)
%                   Added logic for averaging metabolic cycling data
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

DEBUG = this.reconparam.averaging.debug;

if this.reconparam.averaging.enable && ~this.flags.averaging
    
    fid = this.get_data({'x', 'average'});
    
    % perform cross-correlation before averaging
    if this.reconparam.averaging.crosscorr_magn
        
        % approach may not work for TI experiments!
        spec = this.ifft( fid );
        
        output = get_profile_shifts( spec );
        
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
            plot(abs(this.ifft(fid(:,:) .* output.corr_func)))
            %xlabel('profile #')
            %ylabel('profile shift against reference')
        end
        
        fid = fid .* reshape(output.corr_func, size(fid));
        
        if DEBUG
            figure;
            plot(squeeze(abs(this.ifft( fid(:,1,:)))))
            title('DEBUGGING: AVERAGING: corrected (abs) frequency profiles before averaging')
        end
    end
    
    % currently we do a simple mean
    % this could potentially be improved in the future
    % TODO: improve signal averaging
    if isempty(this.scanparam.metcycle) || (~ this.scanparam.metcycle)
        fid = mean( fid, 2 );
        this.set_data( fid, {'x', 'average'} );
    else
        fid_water = sum( fid, 2 );
        fid_meta = sum( fid(:,1:2:end,:), 2 ) - sum( fid(:,2:2:end,:), 2 );
        fid = cat( 2, fid_meta, fid_water );
        this.set_data( fid, {'x', 'average'} );
        % rename dimension to indicate metcycle data
        this.dims{find(strcmp(this.dims, 'average'))} = 'metcycle';
    end
    
    this.flags.averaging = 1;
    
else
    warning('Skipped ALFONSO.averaging.')
end

%% nested functions

    function output = get_profile_shifts( spec )
        
        spec = this.apodize( spec );
        n = size(spec,1);
        
        padfactor = 4;
        N = padfactor * n;
        x = linspace(0,1,n);
        fftc = @(x) ALFONSO.fft(x);
        ifftc = @(x) ALFONSO.ifft(x, N);
        phasor = @(k) exp(1j * k .* x(:));
        
        % set MAXLEG based on the
        ppm_per_sample = abs(this.scanparam.ppm_abs(2)-this.scanparam.ppm_abs(1));
        MAXLAG = ceil(this.reconparam.averaging.crosscorr_max_ppm_shift / ppm_per_sample * padfactor);
        
        A = abs(ifftc(fftc(spec(:,:))));
        
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