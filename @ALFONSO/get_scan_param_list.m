function paramlist = get_scan_param_list()
%GET_SAN_PARAM_LIST returns an ordered cell array with known dynamic scan 
%parameters
%   paramlist = ALFONSO.get_scan_param_list() returns a sequence parameter
%       list that is also reflecting the dimensional order used for 
%       ALFONSO.fit_model.
%
%   See also ALFONSO/fit_model, ALFONSO/get_model_func
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 09, 2020
%
% Revisions:    0.1 (Apr 09, 2020)
%					Initial version.
%               0.2 (May 12, 2020)
%                   Reduced the number of default scan parameters. 
%               0.3 (Jun 04, 2021)
%                   Added average dimension. 
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

paramlist = {
    'TI', ...
    'TE', ...
    'TM', ...
    'bvalue', ...
    'aver', ...
    };

end
