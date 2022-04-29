function paramlist = get_model_param_list( this )
%GET_MODEL_PARAM_LIST returns an ordered cell array with known model
%parameters
%   paramlist = ALFONSO.get_model_param_list()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 30, 2020
%
% Revisions:    0.1 (Mar 30, 2020)
%					Initial version.
%               0.2 (Apr 15, 2020)
%                   Added loading of additional model params form current
%                   quant (modelparam.add_model_param)
%               0.3 (Jun 04, 2021)
%                   Update to allow handling of average dimension. 
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

paramlist = {'rho', ...
    'omega', ...
    'd', ...
    'g', ...
    'phi', ...
    'T1', ...
    'T2', ...
    'D', ...
    };

% load additional model parameter from add_model_param
modelparam = this.quant{this.cur_quant}.model.param;

if isfield( modelparam, 'add_model_param') && ~isempty(modelparam.add_model_param)
    if ischar(modelparam.add_model_param)
        modelparam.add_model_param = {modelparam.add_model_param};
    end
    paramlist = [paramlist modelparam.add_model_param];
end

end
