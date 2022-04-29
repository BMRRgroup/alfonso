function [param_unit, param_factor] = get_dim_display_info( this, scanparam )
%GET_DIM_DISPLAY_INFO returns unit and corresping scaling factor for the
%passed scan parameter.
%   [param_unit, param_factor] = ALFONSO.get_dim_display_info( scanparam )
%   returns the unit array and factor array for the requested scanparam.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	May 11, 2020
%
% Revisions: 	0.1 (May 11, 2020)
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

if ~iscell( scanparam )
    scanparam = {scanparam};
end

known_source_units = {'_s','_spm2'};
known_target_units = {'ms','s/mm^2'};
known_factors =      [1e3 1e-6];

for ipar = 1:length( scanparam )
    
    param_factor(ipar) = 1;
    param_unit{ipar} = '';

    [~, cur_dyn_scanparam_name] = this.is_scanparam( scanparam{ipar} );
    
    for i = 1:length( known_source_units )
        if endsWith(cur_dyn_scanparam_name, known_source_units{i})
            param_factor(ipar) = known_factors(i);
            param_unit{ipar} = known_target_units{i};
        end
    end
    
end

end