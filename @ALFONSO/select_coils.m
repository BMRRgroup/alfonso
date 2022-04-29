function [ sel_coils ] = select_coils( this )
%SELECT_COILS performs the coil selection process
%   [ sel_coils ] = ALFONSO.select_coils() returns the manual or automatic
%   selection of coil element indices depending on reconparam.coilcombination.
%
%   Parameters:
%       - reconparam.coilcombination.coil_selection_mode
%           - auto
%           - manual
%       - reconparam.coilcombination.selected_coils
%           - int array with selected coil elements (only for manual selection mode)
%       - reconparam.coilcombination.auto_coil_selection_corr_thresh
%           - float (0.001 - 0.999) - threshold value used to discard coils based on cross-correlation
%
% See also ALFONSO/coilcombination
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 8, 2018
%
% Revisions: 	0.1 (Sep 8, 2018)
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

fid = this.get_data({'x','coil'});

switch this.reconparam.coilcombination.coil_selection_mode
    
    case 'manual'
        
        disp('Coil selection mode: manual');
        
        if isempty(this.reconparam.coilcombination.selected_coil) ...
                || this.reconparam.coilcombination.selected_coil == 0
            sel_coils = 1:size(fid,2);
        else
            sel_coils = this.reconparam.coilcombination.selected_coil;
        end
        
    case 'auto'
        
        disp('Coil selection mode: auto selection');
        
        sel_coils = autoCoilSelection(fid);
        
    otherwise
        error('reconparam.coilcombinatino.coil_selection_mode was not set!')
end

if length(sel_coils) < 0.5 *size(fid,2)
    warning('Less than 50% of all coil elements are considered!')
end

if isempty( sel_coils )
    
    sel_coils = 1:size(fid,2);
    warning('No coils have been selected. Using all coil elements!')
    
end

disp(['Coils used: ' num2str(sel_coils) ' ( ' num2str(length(sel_coils)) ' / ' num2str(size(fid,2)) ' coils)']);

% nested functions

    function [ selectedCoils ] = autoCoilSelection( fiddata, trsh )
        
        if ~exist('trsh', 'var')
            trsh = this.reconparam.coilcombination.auto_coil_selection_corr_thresh;
        end
        
        % get number of coils
        nCoils = size( fiddata, 2 );
        
        param.phase_corr_order = 0;
        
        % average the phase corrected fiddata
        meanDATA = squeeze( sum( this.phase_correction( fiddata, param ), 3 ) ); %mean of all averages
        
        % get cross correlation
        [C,LAGS] = xcorr( meanDATA(:,:,1), 'coeff' );
        
        % mc represents the correlation of each coil with all other coils
        mc = sum( reshape( max(C), [nCoils, nCoils] ) ) ./ nCoils;
        
        % check for coil shifts
        [~, ILAG] = max(C);
        shiftmatrix = reshape( LAGS(ILAG), [nCoils, nCoils] );
        if sumn( shiftmatrix ) > 0
            warning(['AUTO COIL SELECTION: coil shift detected. Affected coil: ' num2str(find(shiftmatrix(1,:) > 0))])
        end
        
        selectedCoils = find( real(mc) > trsh);
    end
end