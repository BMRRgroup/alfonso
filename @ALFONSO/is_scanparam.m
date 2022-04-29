function [isp,found_parname] = is_scanparam( this, param_name )
%IS_SCANPARAM returns true if scan parameter is defined and not empty
%   [isp] = ALFONSO.is_scanparam( param_name ) returns true if
%   model.scanparam.(param_name) exists and is not empty. Otherwise returns
%   false.
%   [~,found_parname] = ALFONSO.is_scanparam( param_name ) found_parname is
%   the actual parameter name which may also include the paramter unit as 
%   suffix.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 03, 2020
%
% Revisions: 	0.1 (Apr 03, 2020)
%                   Initial version.
%               0.1.1 (Apr 16, 2020)
%                   Under the hood simplifications...
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

scanparam = this.scanparam;

% init return values with unsuccessful value
isp = false;
found_parname = [];

% also look for the paramter name with the following suffixes
suffix = {'', ...
          '_s', ... % seconds 
          '_spm2' ... % seconds per square meter
          };

for isuffix = 1:length(suffix)
    param_name_suf = [param_name suffix{isuffix}];
    if isfield(scanparam, param_name_suf) && ~isempty(scanparam.(param_name_suf))
        isp = true;
        found_parname = param_name_suf;
        break
    end
end

end

