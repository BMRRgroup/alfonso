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
        for i = 1:size(fid, 3)
            subplot(ceil(sqrt(size(fid, 3))),ceil(sqrt(size(fid, 3))),i)
        	hold all; 
            plot(squeeze(real(this.ifft( fid(:,1:2,i))))); plot(squeeze(real(this.ifft( mean(fid(:,1:2,i),2)))));
        end
%         for i = 1:size(fid, 3)
%             figure; 
%             subplot(2,2,1)
%             plot(angle(fid(1:10,:,i)))
%             subplot(2,2,2)
%             plot(angle(fid(1:10,1,i)-fid(1:10,2,i)))
%             subplot(2,2,3)
%             plot(abs(angle(fid(1:10,1,i))-angle(fid(1:10,2,i))))
%             subplot(2,2,4)
%             hold all
%             plot(squeeze(real(this.ifft( fid(:,1:2,i)))),'k')
%             plot(squeeze(real(this.ifft( mean(fid(:,1:2,i),2)))),'r')
%         end
        
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
            warning('ALFONSO:polaritycombination:NoPolarityDim', ...
                'No diffusion_orientation dimension found. Ensure data was acquired with polarity switching.');
            ok = false;
        end
        if ~ this.reconparam.polaritycombination.enable
            warning('ALFONSO:polaritycombination:Disabled', ...
                'Polarity combination is disabled. Set reconparam.polaritycombination.enable = 1 to enable.');
            ok = false;
        end
        if this.flags.polaritycombination
            warning('ALFONSO:polaritycombination:AlreadyApplied', ...
                'Polarity combination was already performed. Reset flags to reapply.');
            ok = false;
        end
    end

end

