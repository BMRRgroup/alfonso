function polaritycombination( this )
%POLARITYCOMBINATION combines opposite (e.g. diffusion) gradient polarities
%   ALFONSO.polaritycombination combines opposite gradient polarties as e.g.
%       used in diffusion weighted spectroscopy to correct for eddy current
%       effects.
%   Parameters:
%       reconparam.polaritycombination.crosscorr_magn - perform
%       magnitude-based prior to the signal combination
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 09, 2020
%
% Revisions: 	0.1 (Apr 09, 2020)
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

if check_requirements()
    fid = this.get_data({'x', 'diffusion_orientation'});
    
    % perform cross-correlation for averages before averaging
    if this.reconparam.polaritycombination.crosscorr_magn
        
        % This approach may not work for TI experiments!
        %spec = this.ifft( this.apodize( fid ) );
        spec = this.ifft( fid );
        
        output = this.estimate_profile_shifts( spec );
        
        if this.reconparam.polaritycombination.debug
            figure;
            plot(squeeze(output.shifts))
            title('DEBUGGING: POLARITYCOMBINATION: determined frequency profile shifts')
            ylabel('profile shift (samples)')
            xlabel('profile (-)')
        end
        
        fid = fid .* reshape(output.corr_func, size(fid));
        
    end
    
    if this.reconparam.polaritycombination.debug
        figure;
        subplot(2,2,1)
        plot(squeeze(abs(this.ifft( fid(:,1,:)))))
        title({'DEBUGGING: POLARITYCOMBINATION:','(abs) frequency profiles BEFORE polaritycombination'})
        subplot(2,2,2)
        plot(squeeze(real(this.ifft( fid(:,1,:)))))
        title({'DEBUGGING: POLARITYCOMBINATION:','(real) frequency profiles BEFORE polaritycombination'})
    end
    
    % currently we do a simple mean - could potentially be improved in the 
    % future
    fid = mean( fid, 2 );
    
    if this.reconparam.polaritycombination.debug
        subplot(2,2,3)
        plot(squeeze(abs(this.ifft( fid(:,1,:)))))
        title({'(abs) frequency profiles AFTER polaritycombination'})
        subplot(2,2,4)
        plot(squeeze(real(this.ifft( fid(:,1,:)))))
        title({'(real) frequency profiles AFTER polaritycombination'})
    end
    
    this.set_data( fid, {'x', 'diffusion_orientation'} );
    
    this.flags.polaritycombination = 1;

end

    function ok = check_requirements()
        ok = true;
        if ~ this.is_data_dim('diffusion_orientation')
            warning('No polarity dimension found.');
            ok = false;
        end
        if ~ this.reconparam.polaritycombination.enable
            warning('Skipping POLARITYCOMBINTION - (disabled).');
            ok = false;
        end
        if ~ this.flags.polaritycombination
            warning('Skipping POLARITYCOMBINTION - already performed.');
            ok = false;
        end
    end

end

