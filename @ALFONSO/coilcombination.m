function coilcombination( this )
%COILCOMBINATION selects and combines coil elements
%   ALFONSO.coilcombination performs a SVD-based coil combination using
%       ALFONSO.complexweighting with the selected coil elements using
%       ALFONSO.select_coils.
%   Parameters:
%     - reconparam.coilcombination.coil_selection_mode (see
%       ALFONSO/select_coils)
%     - reconparam.coilcombination.selected_coil (see ALFONSO/select_coils)
%     - reconparam.coilcombination.auto_coil_selection_corr_thresh (see 
%       ALFONSO/select_coils)
%
%   See also ALFONSO.complexweighting, ALFONSO.select_coils
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

if this.reconparam.coilcombination.enable && ~this.flags.coilcombination
    
    selected_coils = this.select_coils;
    
    fid = this.get_data({'x','coil'});
    
    weights = this.complexweighting( fid(:,selected_coils,:) );
    
    fid = sum( weights .* fid(:,selected_coils,:), 2 );
    
    this.set_data(fid, {'x','coil'});
    
    this.flags.coilcombination = 1;
    
else
    warning('Skipped ALFONSO.coilcombination.')
end

end

