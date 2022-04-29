function val = get_scanparam_val( this, param_name, idx )
%GET_SCANPARAM_VAL returns the requested scan parameter value
%   val = ALFONSO.get_scanparam_val( param_name ) returns the scan
%   parameter value(s) for param_name. In case of an array, the complete 
%   array will be retured.  
%   val = ALFONSO.get_scanparam_val( param_name, idx ) returns the val at
%   index idx of the scan parameter array param_name.
%
% See also ALFONSO/is_scanparam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 15, 2018
%
% Revisions: 	1.0 (Oct 15, 2018)
%                   Initial version.
%               1.1 (May 11, 2020)
%                   Under the hood improvements.
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

[is_scanparam, found_parname] = this.is_scanparam( param_name );

if ~is_scanparam
    error(['Could not find ' param_name ' in scan parameters.'])
end

if nargin > 2
    val = this.scanparam.(found_parname)(idx);
else
    val = this.scanparam.(found_parname);
end

end