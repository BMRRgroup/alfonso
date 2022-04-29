function [imp] = is_model_param( this, param_name )
%IS_MODEL_PARAM returns true if parameter is defined and not empty
%signal
%   [imp] = ALFONSO.is_model_param( param_name ) returns true if
%   model.param.(param_name) exists and is not empty. Otherwise returns 
%   false.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 28, 2020
%
% Revisions: 	0.1 (Mar 28, 2020)
%				Initial version.
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

modelparam = this.quant{this.cur_quant}.model.param;

imp = false;

if isfield(modelparam, param_name)
    if ~ isempty(modelparam.(param_name))
        imp = true;
    end
end

end

