function [ fid_corr ] = phase_correction( this, FID )
%PHASE_CORRECTION performs a zero-orer phase correction by
%subtracting the phase of the first sampling point of each coil and average
%
%   [ fid_corr ] = ALFONSO.phase_correction() performs phase correction and
%   also returns the result and also overwrites the object's data array. 
%   [ fid_corr ] = ALFONSO.phase_correction( FID ) performs phase
%   correction of the passed FID data instead of the object's data array.
%
%   Parameters:
%     - reconparam.phase_correction.use_mean_phasor = [0(default)|1] if set
%       to 1, a common phasor for all dynamics / averages will be 
%       determined and correct for.  
%     - reconparam.phase_correction.IR_phase_stabilzer_enable = [0|1(default)]
%       experimental method to to correctly phase IR series based on the 
%       longest TI. Tries to correctly phase inversion recovery data under 
%       the assumption that that all dynamics will be correctly phased
%       if the longest TI has a positive real spectrum. Will only be
%       performed if ALFONSO.scanparam.TI_s is not empty! (experimental)
%
%   Expected dimensions of passed FID:
%     1: sampling points
%     2: coil
%     3: average
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 30, 2020
%
% Revisions:    0.1 (Mar 30, 2020)
%					Initial version.
%               0.2 (Oct 09, 2020)
%                   Added experimental phase stabilizer for
%                   inversion-recovery series data.
%               0.2.1 (May 28, 2021)
%                   Updated phase stabilizer for inversion-recovery 
%                   series data. 
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

DEBUG = this.reconparam.phase_correction.debug;

if this.flags.phase_corrected
    warning('Phase correction was already performed!')
end

if (this.reconparam.phase_correction.enable && ~this.flags.phase_corrected) || nargin > 1
    
    if nargin > 1 % use the passed fid array instead of this.data
        fidSignalArray = FID;
    else
        fidSignalArray = this.get_data({'x', 'coil', 'TI'});
    end
    
    if DEBUG
        % check receiver phases
        figure;
        hold all
        title('DEBUG: phase correction: comparison of receiver phase')
        for iTI = 1:size(fidSignalArray,3)
        plot(squeeze(mod(pi + squeeze(angle(fidSignalArray(1,:,iTI,:))), pi)), '*')
        plot(squeeze(abs(fidSignalArray(1,:,iTI,:))) ./ max(squeeze(abs(fidSignalArray(1,:,iTI,:)))), '-')
        end
        xlabel('receiver number')
        ylabel('FID phase correction based on first sample')
    end
    
    rec_phasor = mean(mod(pi + angle(fidSignalArray(1,:,:,:)), pi),2);
    %rec_phasor = mean(0 - angle(fidSignalArray(1,:,:)),2);
    
    if ~isempty(this.scanparam.TI_s) && this.reconparam.phase_correction.IR_phase_stabilzer_enable
        % assume that spectra will be correctly phased for the longed TI
        % -> adjust all short TI accordingly if required (assuming no phase
        % jumps larger than 0.9 * pi.
        stab_idx = abs(rec_phasor(1,1,:,:) - rec_phasor(1,1,end,:)) > (pi*0.9);
        rec_phasor(stab_idx) = rec_phasor(stab_idx) + pi;
        % -> adjust along other dimensions based on jumps larger than 0.9 * pi.
        stab_idx2 = abs(rec_phasor(1,1,end,1) - rec_phasor(1,1,end,:)) > (pi*0.9);
        rec_phasor = rec_phasor + stab_idx2 * pi;
    end
    
    if this.reconparam.phase_correction.use_mean_phasor
        rec_phasor_weights = mean(abs(fidSignalArray(1,:,:,:)),2);
        if isempty(this.scanparam.metcycle) || (~ this.scanparam.metcycle)
            rec_phasor = wmeanangle(rec_phasor, rec_phasor_weights);
        else % metabolic cycling uses two mean phasors
            rec_phasor1 = wmeanangle(rec_phasor(:,:,:,1:2:end), rec_phasor_weights(:,:,:,1:2:end));
            rec_phasor2 = wmeanangle(rec_phasor(:,:,:,2:2:end), rec_phasor_weights(:,:,:,2:2:end));
        end
    end
    if isempty(this.scanparam.metcycle) || (~ this.scanparam.metcycle)
        fid_corr = fidSignalArray .* exp(-1j * rec_phasor);
    else
        fid_corr(:,:,:,1:2:size(fidSignalArray,4)) = fidSignalArray(:,:,:,1:2:end) .* exp(-1j * rec_phasor1);
        fid_corr(:,:,:,2:2:size(fidSignalArray,4)) = fidSignalArray(:,:,:,2:2:end) .* exp(-1j * rec_phasor2);
    end
    
    % flip spectra by pi if the real signal is negative
    % this assumption may not hold for inversion recovery, etc.
    % TODO: the condition checking for empty TI should be improved
    
    %if real(fid_corr(1)) < 0 && isempty(this.scanparam.TI_s)
    if sum(real(fid_corr(1,:,:))< 0)  & isempty(this.scanparam.TI_s)
        % fid_corr = fid_corr .* exp(-1j * pi);
        % tried to improve the correct phasing be individually
        % inverting dynamics
        fid_corr = fid_corr .* exp(-1j * pi * (real(fid_corr(1,:,:,:)) < 0));
    end
    
    if nargin == 1 % write back data if phase correction should be applide on this.data
        
        % Saving phase corrected data in Data Object:
        this.set_data( fid_corr, {'x', 'coil', 'TI'} );
        
        % experimental IR-phase correction
        if ~isempty(this.scanparam.TI_s)
            fidSignalArray = this.get_data({'x', 'TI'});
            if real(fidSignalArray(1,1,1)) > 0
                fidSignalArray = fidSignalArray .* exp(1j * pi);
                this.set_data( fidSignalArray, {'x', 'TI'} );
            end
        end
        
        % Setting flag:
        this.flags.phase_corrected = 1;
    end
    
else
    warning('Skipped ALFONSO.phase_correction.')
end

end