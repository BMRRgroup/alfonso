function fit_model( this )
%FIT_MODEL performs fitting according to ALFONSO.quant{cur_quant}
%   ALFONSO.fit_model() performs the fitting routine for
%   ALFONSO.quant{ALFONSO.cur_quant} and writes the result to
%   ALFONSO.quant{cur_quant}.output. The result can afterwards be visualized
%   with ALFONSO.plot_fit_model().
%
%   See also ALFONSO/plot_fit_model
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 13, 2018
%
% Revisions: 	0.1 (Oct 13, 2018)
%                   Initial version.
%               0.2 (Oct 21, 2019)
%                   Added handling for multiple quantifications.
%               0.2.1 (Mar 27, 2020)
%                   Added confidence intervals (CI)
%               0.3 (Mar 28, 2020)
%                   Refactoring of model and parameter function
%               0.4 (Jun 14, 2020)
%                   Added ALFONSO.quantparam settings for controlling the
%                   algorithm parameters
%               0.5 (Apr 22, 2022)
%                   Updated resdiual and resnorm scaling
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

%% prepare optim_data
% make sure dimensions are compliant with the fitting procedure
% dimensions:
% 1: time domain signal (measurement)
% 2: TI series
% 3: TE series
% 4: TM series
% 5: bvalue series
% 6: aver series (averages) -> see get_scan_param_list()

dimlist = ALFONSO.get_scan_param_list();

% order of dimensions
dim_order = ['x' dimlist];

use_dims = this.dims;

[~, use_dim_idx] = ismember(dim_order, use_dims);
use_dim_idx(use_dim_idx == 0) = [];
use_dims = use_dims(unique(use_dim_idx));
n_dim = length(use_dims);
use_dim_idx = unique([use_dim_idx 1:length(this.dims)], 'stable');


if n_dim > length(this.dims)
    error([ mfilename ': Unknown dimenions in data that cannot be used!'])
end

if 1 < length(use_dim_idx)
    optim_data = permute(this.data, use_dim_idx);
else
    optim_data = this.data;
end
optim_data = double(optim_data);

% normalize data
scaling_factor = max(abs(optim_data(:)));
optim_data = optim_data ./ scaling_factor;

% initial guess, upper bounds and lower bounds
x_init = [];
lb = [];
ub = [];
get_bounds = false;

% get model parameter
modelparam = this.quant{this.cur_quant}.model.param;

% setup algorithm options
setup_algorithm()

% obtain model and parameter functions
[modelfunc, parfunc] = this.get_model_func();

% define some helper functions
opsqueeze = @(a) (colsqueeze(sum(a,1)));
split_reim = @(c) ([real(c);imag(c)]);

paramlist = this.get_model_param_list();
update_vars( paramlist );

if ~ this.is_data_dim( 'TI' )
    % good first guess for non TI series
    x_init(modelparam.phi_vars) = -angle(optim_data(1,1));
end

% define cost function
if this.quantparam.receiver_correction.enable
    costfunc = @(x) split_reim(ALFONSO.receiver_correction(opsqueeze(modelfunc(x)), optim_data) - optim_data);
else
    costfunc = @(x) split_reim(opsqueeze(modelfunc(x)) - optim_data);
end

% simple model checks
% check model dimensionality vs data dimensionality
if (ndims(opsqueeze(modelfunc(x_init))) ~= ndims(optim_data)) ...
        || sum(size(opsqueeze(modelfunc(x_init))) ~= size(optim_data))
    error(['Model dimensionality (' num2str(size(opsqueeze(modelfunc(x_init)))) ') not in agreement with data dimensionality (' num2str(size(optim_data)) ')!'])
end

% % debug
if this.reconparam.quant.fit_model.debug
    %     figure;
    %     hold all
    %     fit_init = this.ifft(modelfunc(x_init),[],2);
    %     data = this.ifft(optim_data);
    %     plot(real(squeeze(sum(fit_init(:,:,:,1),1))))
    %     plot(real(squeeze(data(:,:,1))))
    
    % Set up shared variables with OUTFUN
    history.x = [];
    history.fval = [];
    searchdir = [];
    options_lsqnonlin = optimset(options_lsqnonlin, ...
        'PlotFcn', @optimpltfun);
end


if ~strcmpi(options_lsqnonlin.Algorithm, 'NL2SOL') % NL2SOL
    [ x_out , ...
        resnorm, ...
        residual, ...
        exitflag, ...
        output, ...
        lambda, ...
        jac ]  ...
        = lsqnonlin(costfunc, ...
        x_init, ...
        lb, ...
        ub, ...
        options_lsqnonlin);
else % NL2SOL
    [ x_out , ...
        resnorm, ...
        residual, ...
        exitflag, ...
        iterations, ...
        funevals]  ...
        = mexnl2sol(costfunc, ...
        x_init, ...
        lb, ...
        ub, ...
        options_lsqnonlin, 2);
    lambda = [];
    x_out = ensure_col(x_out);
    output.exitflag = exitflag;
    output.iterations = iterations;
    output.funevals = funevals;
    output.algorithm = 'NL2SOL';
    jac = get_finitJAC(costfunc,x_out,1e-10);
end

% calculate confidence interval
x_out_CI = get_CI( x_out, residual, jac, 0.05 ).';

% % debug
% if this.reconparam.quant.fit_model.debug
%     figure;
%     hold all
%     fit_init = this.ifft(modelfunc(x_out),[],2);
%     data = this.ifft(optim_data);
%     plot(real(squeeze(sum(fit_init(:,:,:,1),1))))
%     plot(real(squeeze(data(:,:,1))))
% end

%% prepare output
this.quant{this.cur_quant}.output = [];
this.quant{this.cur_quant}.output.xout                  =   x_out;
this.quant{this.cur_quant}.output.xout_CI               =   x_out_CI;
[this.quant{this.cur_quant}.output.fitsignal,                 ...
    this.quant{this.cur_quant}.output.rcf]                  =   ALFONSO.receiver_correction( opsqueeze(modelfunc(x_out)), optim_data);
this.quant{this.cur_quant}.output.fitsignal             =   this.quant{this.cur_quant}.output.fitsignal .* scaling_factor;
this.quant{this.cur_quant}.output.fit                   =   modelfunc(x_out) .* scaling_factor;
this.quant{this.cur_quant}.output.fit(:,1,:)            =   this.quant{this.cur_quant}.output.fit(:,1,:) .* shiftdim(this.quant{this.cur_quant}.output.rcf(1,:),-1);
this.quant{this.cur_quant}.output.resnorm               =   resnorm .* scaling_factor^2;
this.quant{this.cur_quant}.output.residual              =   residual .* scaling_factor;
this.quant{this.cur_quant}.output.exitflag              =   exitflag;
this.quant{this.cur_quant}.output.output                =   output;
this.quant{this.cur_quant}.output.lambda                =   lambda;
this.quant{this.cur_quant}.output.jacobian              =   jac;
this.quant{this.cur_quant}.output.scaling_factor        =   scaling_factor;
this.quant{this.cur_quant}.output.modelfunc             =   modelfunc;
this.quant{this.cur_quant}.output.parfunc               =   parfunc;
this.quant{this.cur_quant}.output.costfunc              =   costfunc;
for ipar = 1:length(paramlist)
    if this.is_model_param([paramlist{ipar} '_vars'])
        parfun = ['parfunc.' paramlist{ipar}];
        this.quant{this.cur_quant}.output.param.(paramlist{ipar}) = eval([parfun '( x_out )']);
        this.quant{this.cur_quant}.output.param_CI.(paramlist{ipar}) = ...
            [ensure_col(eval([parfun '( x_out_CI(1,:) )'])); ...
            ensure_col(eval([parfun '( x_out_CI(2,:) )']))];
    end
end

% convert omega from Hertz to ppm
ppm_shift = (this.scanparam.ppm_abs(1) - this.scanparam.ppm_rel(1));
this.quant{this.cur_quant}.output.param.omega = this.hertz2ppm(this.quant{this.cur_quant}.output.param.omega) - ppm_shift;
this.quant{this.cur_quant}.output.param_CI.omega = this.hertz2ppm(this.quant{this.cur_quant}.output.param_CI.omega) - ppm_shift;

% set flag
this.flags.fitModel = 1;

    function setup_algorithm()
        % helper function to determin the correct algorithm for the
        % selected model including the request to set variable bounds.
        
        if this.is_model_param('algorithm')
            selected_algorithm = modelparam.algorithm;
        else % set to default
            selected_algorithm = this.quantparam.optimset.algorithm;
        end
        
        % NL2SOL and trust-region-reflective support bounds 
        % check if bounds are defined in the model and make sure to pass 
        % them to the algorithm (get_bounds = true)
        if model_has_bounds() && ...
            (strcmpi(modelparam.algorithm, 'trust-region-reflective') || ...
            strcmpi(modelparam.algorithm, 'NL2SOL'))
            get_bounds = true; % TODO auto detect if bounds were passed and are supported
        end
        
        options_lsqnonlin = optimset( ...
            'ScaleProblem', this.quantparam.optimset.ScaleProblem, ... None: search direction: ( J(x_k)^T J(x_k) + λ_k I) d_k = − J(x_k)^T F(x_k),
            'Display', this.quantparam.optimset.Display, ... % 'off', 'iter', ...
            'LargeScale', this.quantparam.optimset.LargeScale, ...
            'TolFun', this.quantparam.optimset.TolFun, ...
            'MaxFunEvals', this.quantparam.optimset.MaxFunEvals, ...
            'MaxIter', this.quantparam.optimset.MaxIter, ...
            'TolX', this.quantparam.optimset.TolX);
        
        % workaround to set algorithm - (cannot set to NL2SOL using optimset)
        options_lsqnonlin.Algorithm = selected_algorithm;
        % add parameters not refognized by optimset but NL2SOL
        if strcmpi(selected_algorithm, 'NL2SOL')
            options_lsqnonlin.RelTolFun = this.quantparam.optimset.RelTolFun;
        end
    end

    function update_vars( paramlist )
        % helper function to fill x_init and ub / lb (if required)
        for i = 1:length( paramlist )
            cur_par = [paramlist{i} '_vars'];
            if this.is_model_param( cur_par )
                update_x_init( cur_par );
                update_bounds( cur_par );
            end
        end
    end

    function has_bounds = model_has_bounds()
        % helper function to check if model includes bounds
        has_bounds = false;
        parlist = this.get_model_param_list();
        for i = 1:length( parlist )
            cur_par = [parlist{i} '_vars'];
            if this.is_model_param( cur_par )
                param_name_init = cur_par(1:end-4);
                param_name_lb = [param_name_init 'lb'];
                if isfield(modelparam, param_name_lb)
                    has_bounds = true;
                    break
                end
            end
        end
    end

    function update_x_init( param_name )
        % fill x_init with initial values for param_name
        param_name_init = param_name;
        param_name_init(end-3:end) = 'init';
        
        param_name_inv_constraint = [extractBefore(param_name,'_vars') '_inv_constraint'];
        
        if (length(modelparam.(param_name_init)) > 1) && (length(modelparam.(param_name_init)) ~= length(modelparam.(param_name)))
            error([param_name '(n=' num2str(length(modelparam.(param_name))) ') and ' param_name_init '(n=' num2str(length(modelparam.(param_name_init))) ') are not of equal length!' ])
        end
        
        x_init( modelparam.(param_name) ) = modelparam.(param_name_init);
        
        if isfield(modelparam, param_name_inv_constraint)
            % apply inverse constraint function on init values if existing
            inv_constraint_func = eval(modelparam.(param_name_inv_constraint));
            x_init( modelparam.(param_name) ) = inv_constraint_func(x_init);
        end
        
    end

    function update_bounds( param_name )
        % fill lower and upper bounds (lb,ub) with initial values for param_name
        if get_bounds
            param_name_init = param_name(1:end-4);
            param_name_lb = [param_name_init 'lb'];
            param_name_ub = [param_name_init 'ub'];
            
            if isfield(modelparam, param_name_lb)
                lb( modelparam.(param_name) ) = modelparam.(param_name_lb);
                ub( modelparam.(param_name) ) = modelparam.(param_name_ub);
            else
                lb( modelparam.(param_name) ) = -Inf;
                ub( modelparam.(param_name) ) = Inf;
            end
        end
    end

    function CI = get_CI( estimates, residual, jac, ALPHA )
        % estimate the 100(1-ALPHA)% confidence intervals for parameter estimates
        
        % ensure estimates is a column vector
        estimates = ensure_col( estimates );
        
        if ~exist('ALPHA','var')
            ALPHA = 0.05;
        end
        
        % covariance matrix:
        % COV = inv(J'*J) * var(residual)
        covm = ( jac' * jac ) .\ var( residual(:) );
        
        df = length(residual) - numel(estimates); %degrees of freedom
        
        % t-test inverse cumulative distribution
        tcdf = tinv( 1 - ALPHA/2, df );
        
        CI = nan(numel(estimates),2);
        CI(:,1) = estimates - tcdf * sqrt(diag(covm).');
        CI(:,2) = estimates + tcdf * sqrt(diag(covm).');
        
    end

    function jac = get_finitJAC( f, x, stepsize )
        % computes the Jacobian F(x) of f(x) at x using stepsize
        
        if ~exist('stepsize','var')
            stepsize = 1e-8;
        end
        
        h = stepsize * ones(size(x));
        
        jac = (dimfun(@(x_) shiftdim(f(x_),-1), repmat(x,size(x'))+diag(h), 2, 0) - ...
            dimfun(@(x_) shiftdim(f(x_),-1), repmat(x,size(x')), 2, 0)) ./ stepsize;
        
        % reorder dimensions
        jac = permute(jac(:,:), [2 1]);
        
    end

    function stop = optimpltfun(x,optimValues,state)
        stop = false;
        switch state
            case 'init'
                init_data = this.ifft(optim_data);
                plot(real(squeeze(init_data(:,:))))
                hold on
                fit_init = this.ifft(opsqueeze(modelfunc(x_init)),[],1);
                plot(real(fit_init(:,:)), '--');
                hold off
            case 'iter'
                init_data = this.ifft(optim_data);
                plot(real(squeeze(init_data(:,:,1))))
                hold on
                fit_init = this.ifft(opsqueeze(modelfunc(x)),[],1);
                plot(real(fit_init(:,:)), '--')
                hold off
                
                % Concatenate current point and objective function
                % value with history. x must be a row vector.
                %history.fval = [history.fval; optimValues.fval];
                %history.x = [history.x; x];
                % Concatenate current search direction with
                % searchdir.
                % searchdir = [searchdir;...
                %    optimValues.searchdirection'];
                %plot(x(1),x(2),'o');
                
                % plot iteration number
                ax = gca;
                text(ax.XLim(1),ax.YLim(2), ...
                    ['Iteration #' num2str(optimValues.iteration)], ...
                    'HorizontalAlignment', 'Left', ...
                    'VerticalAlignment', 'Top' ...
                    );
            case 'done'
                hold off
            otherwise
        end
    end

end