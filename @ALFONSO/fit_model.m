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
%               0.5.1 (Oct 29, 2022)
%                   Added support setting optimset parameters using model
%                   parameters
%               0.6 (Oct 31, 2022)
%                   Added supported for multiple locations / voxels: loc,
%                   loc_{x,y,z}
%               0.6.1 (Nov 01, 2022)
%                   Added support for settings a fitting mask in the model
%                   parameters
%               0.7 (Nov 12, 2022)
%                   Added filter setting support within model defintion to
%                   work on the following data / functions:
%                       - optimdata (actual data)
%                       - modelfunc
%                       - fitfunc
%                       - costfunc_cpx (complex valued cost function)
%                       - costfunc_reim (real/imag valued cost function)
%               0.7.1 (Jun 28, 2026)
%                   Fixed output handling
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
dim_order = ['loc', 'loc_x', 'loc_y', 'loc_z', 'x' dimlist];

use_dims = this.dims;

[~, use_dim_idx] = ismember(dim_order, use_dims);
use_dim_idx(use_dim_idx == 0) = [];
use_dims = use_dims(unique(use_dim_idx));
n_dim = length(use_dims);
use_dim_idx = unique([use_dim_idx 1:length(this.dims)], 'stable');

num_loc = sum(ismember(this.dims, {'loc_x', 'loc_y', 'loc_z'}));
is_multi_loc = any(ismember(this.dims, 'loc'));
has_loc_dim = any([num_loc, is_multi_loc]);

if n_dim > length(this.dims)
    error('ALFONSO:fit_model:UnknownDims', ...
        'Unknown dimensions in data that cannot be used.')
end

if 1 < length(use_dim_idx)
    optim_data = permute(this.data, use_dim_idx);
else
    optim_data = this.data;
end
optim_data = double(optim_data);

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

% simple model checks
if ~is_multi_loc && ~num_loc
    % for the case of single loc we need to initialize const parameters
    % prior to the dimensionality check
    modelparam_const = initialize_const_param( );
    % check model dimensionality vs data dimensionality
    if (ndims(opsqueeze(modelfunc(x_init,modelparam_const))) ~= ndims(optim_data)) ...
            || sum(size(opsqueeze(modelfunc(x_init,modelparam_const))) ~= size(optim_data))
        error('ALFONSO:fit_model:DimMismatch', ...
            'Model dimensionality (%s) not in agreement with data dimensionality (%s).', ...
            num2str(size(opsqueeze(modelfunc(x_init,modelparam_const)))), ...
            num2str(size(optim_data)))
    end
else
    warning('ALFONSO:fit_model:MissingDimCheck', ...
        'Missing model dimensionality vs data dimensionality check for fit_model with locs.')
end

% % debug
if this.reconparam.quant.fit_model.debug
    if ~is_multi_loc && ~num_loc
        %              figure;
        %              hold all
        %              fit_init = this.ifft(modelfunc(x_init),[],2);
        %              data = this.ifft(optim_data);
        %              plot(real(squeeze(sum(fit_init(:,:,:,1),1))))
        %              plot(real(squeeze(data(:,:,1))))
        
        % Set up shared variables with OUTFUN
        history.x = [];
        history.fval = [];
        searchdir = [];
        options_lsqnonlin = optimset(options_lsqnonlin, ...
                                     'PlotFcn', @optimpltfun);
    else
        warning('ALFONSO:fit_model:DebugNotSupported', ...
            'reconparam.quant.fit_model.debug only supported for data without loc dimension.')
    end
end

fitfunc = @(x,c) opsqueeze(modelfunc(x,c));

if isfield( modelparam, 'filter') && isfield( modelparam.filter, 'fitfunc') && isfield( modelparam.filter.fitfunc, 'bandpass') && modelparam.filter.fitfunc.bandpass.enabled
    fitfunc = @(x,c) this.bandpassfilter(fitfunc(x,c), modelparam.filter.fitfunc.bandpass.freq_band_ppm);
end

%% run over loc — unified dispatch
% Two modes:
%   'separable' — independent per-voxel fits (parfor); single voxel is nvox=1
%   'joint'     — one global solve coupling all voxels via regularization_vars
[fit_mode, nvox, vox_shape] = classify_fit();

% CI: default ON for single voxel, OFF for multi-voxel; override via modelparam
compute_CI = (nvox == 1);
if isfield(modelparam, 'confidence_intervals')
    compute_CI = modelparam.confidence_intervals;
end

if strcmp(fit_mode, 'separable')

    % flatten leading voxel dims onto dim 1 so indexing is iloc = 1..nvox
    if num_loc
        optim_data_siz = size(optim_data);
        optim_data = reshape(optim_data, [prod(size(optim_data, 1:num_loc)) ...
                                          size(optim_data, (num_loc+1):ndims(optim_data))]);
    end

    modelparam_const = initialize_const_param();
    if nvox > 1
        % per-voxel normalisation (voxels are in dim 1 after reshape)
        [optim_data, scaling_factor] = normalize_data(optim_data, 2:ndims(optim_data));
    else
        % single-voxel: one global scale factor
        [optim_data, scaling_factor] = normalize_data(optim_data, []);
    end

    x_out      = zeros(nvox, length(x_init));
    resnorm    = zeros(nvox, 1);
    residual_c = cell(nvox, 1);  % cell array to collect per-voxel residuals (avoids size pre-alloc)
    exitflag   = zeros(nvox, 1);
    iterations = zeros(nvox, 1);
    funevals   = zeros(nvox, 1);
    jac        = [];
    x_out_CI   = [];

    tic
    if nvox == 1
        % single voxel: use solve_nlls directly (no parfor overhead; gets Jacobian in one pass)
        % NB: no leading voxel dim here — dim 1 is the signal/x dim, so use optim_data as-is
        optim_data_loc = optim_data;
        if isfield(modelparam, 'filter') && isfield(modelparam.filter, 'data') ...
                && isfield(modelparam.filter.data, 'bandpass') ...
                && modelparam.filter.data.bandpass.enabled
            optim_data_loc = this.bandpassfilter(optim_data_loc, ...
                                                  modelparam.filter.data.bandpass.freq_band_ppm);
        end
        x_init_local = x_init;
        if ~this.is_data_dim('TI') && isfield(modelparam, 'phi_vars')
            x_init_local(modelparam.phi_vars) = -angle(optim_data_loc(1));
        end
        costfunc_sv = @(x) split_reim(build_residual(fitfunc, x, modelparam_const, optim_data_loc));
        res_sv = solve_nlls(costfunc_sv, x_init_local, lb, ub, options_lsqnonlin, 2, compute_CI);

        x_out(1,:)    = res_sv.x(:).';
        resnorm(1,1)  = res_sv.resnorm;
        exitflag(1,1) = res_sv.exitflag;
        iterations(1) = res_sv.iterations;
        funevals(1)   = res_sv.funevals;
        residual_c{1} = res_sv.residual(:).';
        jac           = res_sv.jac;
        solver_output = res_sv.output;
        if compute_CI
            x_out_CI = get_CI(res_sv.x, res_sv.residual, jac, 0.05).';
        end
    else
        % multi-voxel: parallel loop (solver inlined — nested-fn handles cannot enter parfor)
        parfor iloc = 1:nvox

            x_init_local = x_init;

            % per-voxel initial values from maps
            if isfield(modelparam, 'init_vars_from_map') && ~isempty(modelparam.init_vars_from_map)
                for ivar = modelparam.init_vars_from_map
                    x_init_local(ivar) = modelparam.var_init_map{ivar}(iloc);
                end
            end

            % extract and optionally bandpass-filter the per-voxel data slice
            optim_data_loc = shiftdim(optim_data(iloc,:,:,:,:,:,:,:,:,:,:,:,:));
            if isfield(modelparam, 'filter') && isfield(modelparam.filter, 'data') ...
                    && isfield(modelparam.filter.data, 'bandpass') ...
                    && modelparam.filter.data.bandpass.enabled
                optim_data_loc = this.bandpassfilter(optim_data_loc, ...
                                                      modelparam.filter.data.bandpass.freq_band_ppm);
            end

            % per-voxel constant params (map support)
            if isfield(modelparam, 'constant_param_is_map') && modelparam.constant_param_is_map
                if iscell(modelparam_const)
                    modelparam_const_loc = cell(length(modelparam_const), 1);
                    for icell = 1:length(modelparam_const)
                        modelparam_const_loc{icell} = modelparam_const{icell}(iloc);
                    end
                else
                    modelparam_const_loc = modelparam_const(iloc);
                end
            else
                modelparam_const_loc = modelparam_const;
            end

            % phi phase initialisation per voxel
            if ~this.is_data_dim('TI') && isfield(modelparam, 'phi_vars')
                x_init_local(modelparam.phi_vars) = -angle(optim_data_loc(1));
            end

            % build cost function inline (nested-function handles cannot enter parfor)
            if this.quantparam.receiver_correction.enable
                costfunc_cpx_loc = @(x) ALFONSO.receiver_correction(fitfunc(x, modelparam_const_loc), optim_data_loc) - optim_data_loc;
            else
                costfunc_cpx_loc = @(x) fitfunc(x, modelparam_const_loc) - optim_data_loc;
            end
            if isfield(modelparam, 'filter') && isfield(modelparam.filter, 'costfunc_cpx') ...
                    && isfield(modelparam.filter.costfunc_cpx, 'bandpass') ...
                    && modelparam.filter.costfunc_cpx.bandpass.enabled
                cpx_band = modelparam.filter.costfunc_cpx.bandpass.freq_band_ppm;
                costfunc_cpx_loc = @(x) this.bandpassfilter(costfunc_cpx_loc(x), cpx_band);
            end
            costfunc = @(x) [real(costfunc_cpx_loc(x)); imag(costfunc_cpx_loc(x))];

            % skip masked / zero / NaN voxels
            if sum(optim_data_loc, 'all') == 0 || sum(isnan(optim_data_loc), 'all') ...
                    || (isfield(modelparam, 'mask') && ~modelparam.(modelparam.mask)(iloc))
                x_out(iloc,:)    = nan(size(x_init_local));
                resnorm(iloc,1)  = nan;
                exitflag(iloc,1) = nan;
                iterations(iloc) = 0;
                funevals(iloc)   = 0;
                continue
            end

            % solver call inlined
            if ~strcmpi(options_lsqnonlin.Algorithm, 'NL2SOL')
                [x_loc, rn_loc, res_loc, ef_loc, out_loc] = ...
                    lsqnonlin(costfunc, x_init_local, lb, ub, options_lsqnonlin);
                it_loc = out_loc.iterations;
                fe_loc = out_loc.funcCount;
            else
                [x_loc, rn_loc, res_loc, ef_loc, it_loc, fe_loc] = ...
                    mexnl2sol(costfunc, x_init_local, lb, ub, options_lsqnonlin, 0);
                x_loc = ensure_col(x_loc);
            end

            x_out(iloc,:)    = x_loc(:).';
            resnorm(iloc,1)  = rn_loc;
            exitflag(iloc,1) = ef_loc;
            iterations(iloc) = it_loc;
            funevals(iloc)   = fe_loc;
            residual_c{iloc} = res_loc(:).';

        end
        solver_output = [];
    end
    processing_time_s = toc;

    % convert per-voxel residual cells to matrix (NaN rows for masked voxels)
    nonempty = ~cellfun(@isempty, residual_c);
    if any(nonempty)
        residual_len = length(residual_c{find(nonempty, 1)});
        residual = nan(nvox, residual_len);
        for iloc_ = 1:nvox
            if nonempty(iloc_)
                residual(iloc_,:) = residual_c{iloc_};
            end
        end
    else
        residual = [];
    end
    clear residual_c

    lambda = [];

    % restore original spatial shape for multi-voxel output
    if num_loc
        x_out      = reshape(x_out,      [optim_data_siz(1:num_loc) size(x_out, 2)]);
        resnorm    = reshape(resnorm,     optim_data_siz(1:num_loc));
        if ~isempty(residual)
            residual = reshape(residual, [optim_data_siz(1:num_loc) size(residual, 2)]);
        end
        exitflag   = reshape(exitflag,   optim_data_siz(1:num_loc));
        iterations = reshape(iterations, optim_data_siz(1:num_loc));
        funevals   = reshape(funevals,   optim_data_siz(1:num_loc));
        scaling_factor = reshape(scaling_factor, optim_data_siz(1:num_loc));
    end

else % joint — single global solve coupling voxels via regularization

    optim_data_siz = size(optim_data);
    [optim_data, scaling_factor] = normalize_data(optim_data, (num_loc+1):ndims(optim_data));

    % replicate x_init/lb/ub across spatial dims
    var_size = [size(optim_data, 1:num_loc) 1];
    x_init = repmat(shiftdim(ensure_row(x_init), -num_loc), var_size);
    lb     = repmat(shiftdim(ensure_row(lb),     -num_loc), var_size);
    ub     = repmat(shiftdim(ensure_row(ub),     -num_loc), var_size);

    locfunc  = @(fh, x) permute(dimfun(fh, shiftdim(x,-2), num_loc+3), [1 3:ndims(optim_data)+1 2]);
    rs       = @(x) reshape(x, size(x_init));
    slice_par = @(x,p) x(p,:,:,:);
    sel_par  = @(x,p) shiftdim(slice_par(shiftdim(x, num_loc), p), 1);

    if this.quantparam.bandpassfilter.enable
        joint_fitfunc = @(x) this.bandpassfilter( ...
            opsqueeze(locfunc(@(xloc) modelfunc(xloc), rs(x))), ...
            this.quantparam.bandpassfilter.param.freq_band_ppm);
    else
        joint_fitfunc = @(x) opsqueeze(locfunc(@(xloc) modelfunc(xloc), rs(x)));
    end

    if this.quantparam.receiver_correction.enable
        fidelity = @(x) split_reim( ...
            ALFONSO.receiver_correction(joint_fitfunc(x), optim_data) - ensure_row(optim_data));
    else
        fidelity = @(x) split_reim(joint_fitfunc(x) - ensure_row(optim_data));
    end

    costfunc = @(x) reshape(fidelity(x), [], 1);
    for ifield = 1:length(modelparam.regularization_vars)
        ifield_local = ifield; % capture for anonymous function
        costfunc = @(x) [costfunc(x); reshape( ...
            modelparam.regularization_coefs(ifield_local) .* ...
            abs(gradient(sel_par(x, modelparam.regularization_vars(ifield_local)))), [], 1)];
    end

    modelparam_const = initialize_const_param();

    tic
    res = solve_nlls(costfunc, x_init, lb, ub, options_lsqnonlin, 2, false);
    processing_time_s = toc;

    x_out         = reshape(res.x, size(x_init));
    resnorm       = res.resnorm;
    residual      = res.residual;
    exitflag      = res.exitflag;
    iterations    = res.iterations;
    funevals      = res.funevals;
    lambda        = res.lambda;
    solver_output = res.output;
    jac           = [];
    x_out_CI      = [];

end


% % debug
if this.reconparam.quant.fit_model.debug
    figure;
    hold all
    fit_init = this.ifft(modelfunc(x_out),[],2);
    data = this.ifft(optim_data);
    plot(real(squeeze(sum(fit_init(:,:,:,1),1))))
    plot(real(squeeze(data(:,:,1))))
end

%% prepare output
this.quant{this.cur_quant}.output = [];
this.quant{this.cur_quant}.output.xout                  =   x_out;
this.quant{this.cur_quant}.output.xout_CI               =   x_out_CI;

if ~has_loc_dim
    
    [this.quant{this.cur_quant}.output.fitsignal,                 ...
        this.quant{this.cur_quant}.output.rcf]              =   ALFONSO.receiver_correction( opsqueeze(modelfunc(x_out, modelparam_const)), optim_data);
    this.quant{this.cur_quant}.output.fitsignal             =   this.quant{this.cur_quant}.output.fitsignal .* scaling_factor;
    this.quant{this.cur_quant}.output.fit                   =   modelfunc(x_out, modelparam_const) .* scaling_factor;
    this.quant{this.cur_quant}.output.fit(:,1,:)            =   this.quant{this.cur_quant}.output.fit(:,1,:) .* shiftdim(this.quant{this.cur_quant}.output.rcf(1,:),-1);
    this.quant{this.cur_quant}.output.resnorm               =   resnorm .* scaling_factor.^2;
    this.quant{this.cur_quant}.output.residual              =   residual .* scaling_factor;
    this.quant{this.cur_quant}.output.exitflag              =   exitflag;
    this.quant{this.cur_quant}.output.output                =   solver_output;
    this.quant{this.cur_quant}.output.lambda                =   lambda;
    this.quant{this.cur_quant}.output.jacobian              =   jac;
    this.quant{this.cur_quant}.output.scaling_factor        =   scaling_factor;
    this.quant{this.cur_quant}.output.modelfunc             =   modelfunc;
    this.quant{this.cur_quant}.output.parfunc               =   parfunc;
    this.quant{this.cur_quant}.output.costfunc              =   @(x) split_reim(build_residual(fitfunc, x, modelparam_const, optim_data));
    if exist('processing_time_s', 'var')
        this.quant{this.cur_quant}.output.processing_time_s =   processing_time_s;
    end
    for ipar = 1:length(paramlist)
        if this.is_model_param([paramlist{ipar} '_vars'])
            parfun = ['parfunc.' paramlist{ipar}];
            this.quant{this.cur_quant}.output.param.(paramlist{ipar}) = eval([parfun '( x_out, modelparam_const )']);
            if ~isempty(x_out_CI)
                this.quant{this.cur_quant}.output.param_CI.(paramlist{ipar}) = ...
                    [ensure_col(eval([parfun '( x_out_CI(1,:), modelparam_const )'])); ...
                    ensure_col(eval([parfun '( x_out_CI(2,:), modelparam_const )']))];
            end
        end
    end
    
    % convert omega from Hertz to ppm
    if isfield(this.quant{this.cur_quant}.output.param, 'omega')
        ppm_shift = (this.scanparam.ppm_abs(1) - this.scanparam.ppm_rel(1));
        this.quant{this.cur_quant}.output.param.omega = this.hertz2ppm(this.quant{this.cur_quant}.output.param.omega) - ppm_shift;
        this.quant{this.cur_quant}.output.param_CI.omega = this.hertz2ppm(this.quant{this.cur_quant}.output.param_CI.omega) - ppm_shift;
    end
else
    %[this.quant{this.cur_quant}.output.fitsignal,                 ...
    %    this.quant{this.cur_quant}.output.rcf]              =   ALFONSO.receiver_correction( opsqueeze(modelfunc(x_out)), optim_data);
    %this.quant{this.cur_quant}.output.fitsignal             =   this.quant{this.cur_quant}.output.fitsignal .* scaling_factor;
    %this.quant{this.cur_quant}.output.fit                   =   modelfunc(x_out) .* scaling_factor;
    %this.quant{this.cur_quant}.output.fit(:,1,:)            =   this.quant{this.cur_quant}.output.fit(:,1,:) .* shiftdim(this.quant{this.cur_quant}.output.rcf(1,:),-1);
    this.quant{this.cur_quant}.output.resnorm               =   resnorm .* scaling_factor.^2;
    this.quant{this.cur_quant}.output.residual              =   residual .* scaling_factor;
    this.quant{this.cur_quant}.output.exitflag              =   exitflag;
    this.quant{this.cur_quant}.output.iterations            =   iterations;
    %this.quant{this.cur_quant}.output.output                =   output;
    this.quant{this.cur_quant}.output.lambda                =   lambda;
    this.quant{this.cur_quant}.output.jacobian              =   jac;
    this.quant{this.cur_quant}.output.scaling_factor        =   scaling_factor;
    this.quant{this.cur_quant}.output.modelfunc             =   modelfunc;
    this.quant{this.cur_quant}.output.parfunc               =   parfunc;
    this.quant{this.cur_quant}.output.costfunc              =   [];%costfunc;
    if exist('processing_time_s', 'var')
        this.quant{this.cur_quant}.output.processing_time_s =   processing_time_s;
    end
    if this.quantparam.output.parameter_maps
        for ipar = 1:length(paramlist)
            if this.is_model_param([paramlist{ipar} '_vars'])
                parfun = ['parfunc.' paramlist{ipar}];
                % this.quant{this.cur_quant}.output.param.(paramlist{ipar}) = dimfun(eval(parfun), reshape(x_out,[],size(x_out, ndims(x_out))), 2); %eval([parfun '( x_out )']);
                this.quant{this.cur_quant}.output.param.(paramlist{ipar}) = reshape(dimfun(@(x_) eval([parfun '( x_, modelparam_const )']), reshape(x_out,[],size(x_out, ndims(x_out))), 2), [optim_data_siz(1:num_loc) length(eval([parfun '( x_out, modelparam_const )']))]);
                % this.quant{this.cur_quant}.output.param_CI.(paramlist{ipar}) = ...
                %    [ensure_col(eval([parfun '( x_out_CI(1,:) )'])); ...
                %    ensure_col(eval([parfun '( x_out_CI(2,:) )']))];
            end
        end

        % convert omega from Hertz to ppm
        if isfield(this.quant{this.cur_quant}.output.param, 'omega')
            ppm_shift = (this.scanparam.ppm_abs(1) - this.scanparam.ppm_rel(1));
            this.quant{this.cur_quant}.output.param.omega = this.hertz2ppm(this.quant{this.cur_quant}.output.param.omega) - ppm_shift;
            % this.quant{this.cur_quant}.output.param_CI.omega = this.hertz2ppm(this.quant{this.cur_quant}.output.param_CI.omega) - ppm_shift;
        end
    end
end



% set flag
this.flags.fitModel = 1;

    function [mode, nvox, vox_shape] = classify_fit()
        % Determine fit mode, total voxel count, and original spatial shape.
        % 'separable': independent per-voxel fits (single voxel is nvox=1)
        % 'joint':     one global solve with neighbourhood regularization
        if num_loc && isfield(modelparam, 'regularization_vars')
            mode      = 'joint';
            vox_shape = size(optim_data, 1:num_loc);
            nvox      = prod(vox_shape);
        else
            mode = 'separable';
            if is_multi_loc
                % 'loc' dim is already dim-1 after permute; single voxel axis
                vox_shape = size(optim_data, 1);
                nvox      = vox_shape;
            elseif num_loc
                vox_shape = size(optim_data, 1:num_loc);
                nvox      = prod(vox_shape);
            else
                vox_shape = 1;
                nvox      = 1;
            end
        end
    end

    function [data, scale] = normalize_data(data, non_vox_dims)
        % Normalize data by per-voxel maximum absolute value.
        % non_vox_dims: dimensions over which to take the max (non-spatial dims)
        non_vox_dims = non_vox_dims(non_vox_dims <= ndims(data));
        if isempty(non_vox_dims)
            scale = max(abs(data(:)));
        else
            scale = max(abs(data), [], non_vox_dims);
        end
        data = data ./ scale;
    end

    function r = build_residual(ff, x, c, data_loc)
        % Build the complex residual: apply fitfunc, optional receiver correction,
        % subtract data, and apply optional complex costfunc bandpass.
        % ff: fitfunc handle @(x,c)
        model = ff(x, c);
        if this.quantparam.receiver_correction.enable
            model = ALFONSO.receiver_correction(model, data_loc);
        end
        r = model - data_loc;
        if isfield(modelparam, 'filter') && isfield(modelparam.filter, 'costfunc_cpx') ...
                && isfield(modelparam.filter.costfunc_cpx, 'bandpass') ...
                && modelparam.filter.costfunc_cpx.bandpass.enabled
            r = this.bandpassfilter(r, modelparam.filter.costfunc_cpx.bandpass.freq_band_ppm);
        end
    end

    function res = solve_nlls(costfunc, x0, lb_, ub_, opts, printlevel, want_jac)
        % Single solver boundary. Calls lsqnonlin or mexnl2sol depending on
        % opts.Algorithm and returns a consistent result struct.
        % want_jac: compute finite-difference Jacobian after solve (for CI).
        res.jac        = [];
        res.lambda     = [];
        res.output     = [];
        res.iterations = 0;
        res.funevals   = 0;

        if ~strcmpi(opts.Algorithm, 'NL2SOL')
            [res.x, res.resnorm, res.residual, res.exitflag, ...
             res.output, res.lambda] = ...
                lsqnonlin(costfunc, x0, lb_, ub_, opts);
            res.iterations = res.output.iterations;
            res.funevals   = res.output.funcCount;
        else
            [res.x, res.resnorm, res.residual, res.exitflag, ...
             res.iterations, res.funevals] = ...
                mexnl2sol(costfunc, x0, lb_, ub_, opts, printlevel);
            res.x = ensure_col(res.x);
            res.output.exitflag  = res.exitflag;
            res.output.iterations = res.iterations;
            res.output.funevals  = res.funevals;
            res.output.algorithm = 'NL2SOL';
        end

        if want_jac
            res.jac = get_finitJAC(costfunc, res.x, 1e-10);
        end
    end

    function setup_algorithm()
        % helper function to determin the correct algorithm for the
        % selected model including initalization of the optimset and
        % overloading of optimset parameters as requested in
        % modelparam.optimset if specified. 
        % Default values are read from ALFONSO.quantparam. 
        
        if this.is_model_param('algorithm')
            selected_algorithm = modelparam.algorithm;
        else % set to default
            selected_algorithm = this.quantparam.optimset.algorithm;
        end
        
        % NL2SOL, trust-region-reflective, ATRDLS, and CERES support bounds 
        % check if bounds are defined in the model and make sure to pass 
        % them to the algorithm (get_bounds = true)
        if model_has_bounds() && ...
            (strcmpi(selected_algorithm, 'trust-region-reflective') || ...
            strcmpi(selected_algorithm, 'NL2SOL') || ...
            strcmpi(selected_algorithm, 'ATRDLS') || ...
            strcmpi(selected_algorithm, 'CERES'))
            get_bounds = true; % TODO auto detect if bounds were passed and are supported
        end
        
        % initialize optimset
        options_lsqnonlin = optimset( ...
            'ScaleProblem', this.quantparam.optimset.ScaleProblem, ... None: search direction: ( J(x_k)^T J(x_k) + λ_k I) d_k = − J(x_k)^T F(x_k),
            'Display', this.quantparam.optimset.Display, ... % 'off', 'iter', ...
            'LargeScale', this.quantparam.optimset.LargeScale, ...
            'TolFun', this.quantparam.optimset.TolFun, ...
            'MaxFunEvals', this.quantparam.optimset.MaxFunEvals, ...
            'MaxIter', this.quantparam.optimset.MaxIter, ...
            'TolX', this.quantparam.optimset.TolX);
        
        % overload optimset parameters if required in modelparam
        if isfield(modelparam, 'optimset')
            options_lsqnonlin_pars = fieldnames(options_lsqnonlin);
            for iopset = 1:length(options_lsqnonlin_pars)
                if isfield(modelparam.optimset, options_lsqnonlin_pars{iopset})
                    options_lsqnonlin.(options_lsqnonlin_pars{iopset}) = modelparam.optimset.(options_lsqnonlin_pars{iopset});
                end
            end
        end
        
        % workaround to set algorithm - (cannot set to NL2SOL using optimset)
        options_lsqnonlin.Algorithm = selected_algorithm;
        % add parameters not refognized by optimset but NL2SOL
        if strcmpi(selected_algorithm, 'NL2SOL')
            if isfield(modelparam, 'optimset') && isfield(modelparam.optimset, 'RelTolFun')
                options_lsqnonlin.RelTolFun = modelparam.optimset.RelTolFun;
            else % use default value
                options_lsqnonlin.RelTolFun = this.quantparam.optimset.RelTolFun;
            end
        end
    end

    function update_vars( paramlist )
        % helper function to fill x_init and ub / lb (if required)
        for i = 1:length( paramlist )
            cur_par = [paramlist{i} '_vars'];
            if this.is_model_param( cur_par ) && ~isempty(modelparam.(cur_par))
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
            error('ALFONSO:fit_model:LengthMismatch', ...
                '%s (n=%d) and %s (n=%d) are not of equal length.', ...
                param_name, length(modelparam.(param_name)), ...
                param_name_init, length(modelparam.(param_name_init)))
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

    function [ modelparam_const ] = initialize_const_param( )
        if isfield( modelparam, 'constant_param')
            % load constant model parameters according to the model definition 
            if ischar(modelparam.constant_param) || isstring(modelparam.constant_param) % load parameter at runtime
                modelparam_const = this.quant{this.cur_quant}.model.param.(modelparam.constant_param);
            else % load predefined parameter from model definition
                modelparam_const = modelparam.constant_param;
            end
        else
            modelparam_const = [];
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
        
        jac = (dimfun(@(x_) shiftdim(f(x_),-1), repmat(x,size(x'))+diag(h), 2) - ...
            dimfun(@(x_) shiftdim(f(x_),-1), repmat(x,size(x')), 2)) ./ stepsize;
        
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