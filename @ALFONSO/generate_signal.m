function [data, dims] = generate_signal( this, x_in )
%GENERATE_SIGNAL calculates the signal function using model parameters x_in
%   [data, dims] = generate_signal( x_in ) generates the signal according 
%   to the model function for the current quantification model 
%   (quant.model.param) and the passed x_in variable vector. 
%   Passed x_in will be converted for parameters with exisiting 
%   inv_constraint_func. 
%
%   [data, dims] = generate_signal( ) uses the result of the quantification
%   quant.output.xout to generate the signal. 
%
%   generate_signal( x_in ) with no out arguments will write the result in
%   to the object data.
%
%   data:
%       Dimensions of the returned data:
%           1: x
%           2: TI series
%           3: TE series
%           4: TM series
%           5: bvalue series
%           6: ... addtional dimensions as defined in the model are
%           currently not supported
%
%   dims:
%       Corresponding dimensions as cell array. E.g. {'x', 'TI', 'TE', ...}
%
%
%   See also ALFONSO/get_model_func
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Jun 12, 2020
%
% Revisions: 	0.1 (Jun 12, 2020)
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

modelparam = this.quant{this.cur_quant}.model.param;

if ~exist('x_in','var')
    x_in =  this.quant{this.cur_quant}.output.xout;
else
    paramlist = this.get_model_param_list();
    update_x_in( paramlist );
end

% obtain model and parameter functions
modelfunc = this.get_model_func();

% define helper functions
opsqueeze = @(a) (shiftdim(sum(a,1),1));

% generate signal
data = opsqueeze( modelfunc(x_in) );

% obtain dimensions
% TODO: additional dimensions as added by the model are not handled yet
dims{1} = 'x';
dims(2:(length(ALFONSO.get_scan_param_list())+1)) = ALFONSO.get_scan_param_list();

% write out the object data if requested
if nargout == 0
    this.set_data( data, dims );
end

    function update_x_in( paramlist )
        % helper function to apply inv_constraint function passed x_in
        for i = 1:length( paramlist )
            cur_par = [paramlist{i} '_vars'];
            if this.is_model_param( cur_par )
                cur_param_name_inv_constraint = [extractBefore(cur_par,'_vars') '_inv_constraint'];
                if isfield(modelparam, cur_param_name_inv_constraint)
                    % apply inverse constraint function on init values if existing
                    inv_constraint_func = eval(modelparam.(cur_param_name_inv_constraint));
                    x_in( modelparam.(cur_par) ) = inv_constraint_func(x_in);
                end
            end
        end
    end

end