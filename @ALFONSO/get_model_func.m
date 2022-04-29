function [modelfunc, parfunc] = get_model_func( this )
%GET_MODEL_FUNC returns the model function handle
%   [modelfunc, parfunc ] = get_model_func() builds the model and parameter
%   function for the current quantification model (quant.model.param).
%
%   modelfunc:
%       Dimensions of the returned model function:
%           1: chemical species
%           2: time domain signal
%           3: TI series
%           4: TE series
%           5: TM series
%           6: bvalue series
%           7: ... from here on dimensions are free to use
%
%       The dimensions are shifted +1 compared to the optim_data as defined
%       in ALFONSO.fit_model. For optimimization purposes the chemical species
%       dimension gets summed up and squeezed to match optim_data.
%
%   parfunc:
%       Struct of existing parameter functions. The following functions may
%       be returned, depending on the specified model:
%
%           parfunc.rho
%           parfunc.omega
%           parfunc.d
%           parfunc.g
%           parfunc.phi
%           parfunc.T1
%           parfunc.T2
%           parfunc.D
%
%   See also ALFONSO/get_model_param_list, ALFONSO/get_scan_param_list
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 28, 2020
%
% Revisions: 	0.1 (Mar 28, 2020)
%                   Initial version.
%               0.2 (Apr 03, 2020)
%                   Revised version. Dropped omega_shift parameter. Improved
%                   dynamic assembly of modelfunc. 
%               0.2.1 (Apr 15, 2020)
%                   Added SEQfunc overloading capability
%               0.2.2 (Apr 15, 2020)
%                   Loading of additional scan parameter from the model as 
%                   defined in modelparam.add_scan_param
%               0.3 (May 12, 2020)
%                   Reduced the number of default scan parameters (see also
%                   ALFONSO/get_scan_param_list.
%               0.4 (Jul 14, 2021)
%                   Bugfixed omega definition to allow for both, clockwise
%                   and counter clockwise spin definition. 
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

if ~ isempty( this.quant )
    
    % load model parameter of the current model
    modelparam = this.quant{this.cur_quant}.model.param;
    
    % get parameter list
    paramlist = this.get_model_param_list();
    
    % get sampling time vector
    t = this.get_timedomain_sampling();
    
    % get known sequence parameters
    seq_pars = ALFONSO.get_scan_param_list();
    
    % make sequence parameter already available, so they can also be used
    % for PARfunc
    for i = 1:length( seq_pars )
        [is_seq_par, seq_par_name ] = this.is_scanparam( seq_pars{i} );
        if is_seq_par
            % SEQPAR = this.scanparam.seqpar
            eval([seq_pars{i} ' = this.scanparam.' seq_par_name ';'])
        end
    end
    % load additional parameter from add_scan_param
    % TODO: refactor!
    if isfield( modelparam, 'add_scan_param') && ~isempty(modelparam.add_scan_param)
        if ischar(modelparam.add_scan_param)
            modelparam.add_scan_param = {modelparam.add_scan_param};
        end
        for i = 1:length( modelparam.add_scan_param )
            [is_seq_par, seq_par_name ] = this.is_scanparam( modelparam.add_scan_param{i} );
            if is_seq_par
                % SEQPAR = this.scanparam.seqpar
                eval([modelparam.add_scan_param{i} ' = this.scanparam.' seq_par_name ';']);
            end
        end
    end
    
    
    %% PARfunc - parameter functions
    % generate parameter functions PARfunc
    for i = 1:length( paramlist )
        cur_par = [paramlist{i} '_vars'];
        cur_par_constraint = [paramlist{i} '_constraint'];
        if this.is_model_param( cur_par_constraint )
            % load constraint function if defined
            % eval: PAR_func = eval(modelparam.PAR_constraint);
            eval([paramlist{i} '_func = eval(modelparam.' cur_par_constraint ');']);
        elseif this.is_model_param( cur_par )
            % otherwise load parameter variables directly
            % eval: PAR_func = @(x) x(modelparam.PAR_vars);
            eval([paramlist{i} '_func = @(x) x(modelparam.' cur_par ');']);
        end
    end
    
    % omega function handling
    % make us of omega_ref if existing
    % use freq_sign here
    if exist('omega_func','var')
        if this.is_model_param('omega_ref')
            omega_func = @(x) omega_func(x) + modelparam.omega_ref;
        end
        omega_func = @(x) this.ppm2hertz( omega_func(x) - this.scanparam.acq_window_center_ppm ) * (-this.scanparam.freqsign);
    end
    
    
    %% Upsilon - chemical species relaxation function
    % rho, omega, d, g, phi
    Upsilon_func = @(x) 1;
    Upsilon_pars = {'rho', 'omega', 'd', 'g', 'phi'};
    
    rhomod = @(rho) ensure_row(rho);
    omegamod = @(omega) exp(1j .* ensure_row(omega) * t);
    dmod = @(d) exp(- t .* ensure_row(d));
    gmod = @(g) exp(- t.^2 .* ensure_row(g).^2 .* 0.5);
    phimod = @(phi) exp(1j .* ensure_row(phi));
    
    for i = 1:length( Upsilon_pars )
        cur_par = Upsilon_pars{i};
        if this.is_model_param( [ cur_par  '_vars'] )
            % eval: Upsilon_func =  @(x) Upsilon_func(x) .* PARmod(PAR_func(x));
            eval(['Upsilon_func = @(x) Upsilon_func(x) .* ' cur_par 'mod(' cur_par '_func(x));']);
        end
    end
    
    % Rho - sequence specific modeling
    % T1, T2, D
    % make sure dimensions are compliant with the fitting procedure dimensions:
    %   1: frequency components
    %   2: time domain signal (measurement)
    %   3: TI series
    %   4: TE series
    %   5: TM series
    %   6: bvalue series
    %   7: aver (averages)
    
    Theta_func = @(x) 1;
    
    % corresponding signal modulation functions for seq_pars
    seq_func = {...
        'TI_func = @(T1) ( 1 - 2 .* exp(- shiftdim(TI(:),-2) ./ ensure_row(T1)) );', ...
        'TE_func = @(T2) ( exp( - shiftdim(TE(:),-3) ./ ensure_row(T2)) );', ...
        'TM_func = @(T1) exp( - shiftdim(TM(:),-4) ./ ensure_row(T1) );', ...
        'bvalue_func = @(D) (exp(- ensure_row(D) .* shiftdim(bvalue(:),-5)));', ...
        };
    
    % overload SEQfunc from model definition
    for iseq_par = 1:length(seq_pars)
        if isfield( modelparam, [seq_pars{iseq_par} '_func']) && ~isempty(modelparam.([seq_pars{iseq_par} '_func']))
            seq_func{iseq_par} = modelparam.([seq_pars{iseq_par} '_func']);
        end
    end
    
    % evaluate sequence modulation functions if
    %   a) required sequence parameters exist
    %   and
    %   b) required model parameter were defined
    for i = 1:length( seq_pars )
        if this.is_scanparam( seq_pars{i} ) % a)  require sequence parameters
            dep_par_ok = true;
            % extract required model parameters
            dep_pars = split(extractBetween(seq_func{i},"@(",")"),',');
            for idp = 1:length(dep_pars)
                dep_par_ok = dep_par_ok & this.is_model_param( [dep_pars{idp} '_vars'] );
            end
            if dep_par_ok % b) require model parameters
                % eval the sequence modulation function
                eval(seq_func{i});
            end
        end
    end
    
    % build up Thetafunc
    for i = 1:length( seq_pars )
        if exist([seq_pars{i} '_func'],'var')
            % extract arguments from SEQPAR_func handle
            dep_par_fh = functions(eval([seq_pars{i} '_func']));
            dep_pars = split(extractBetween(dep_par_fh.function,"@(",")"),',');
            % eval: Thetafunc =  @(x) Thetafunc(x) .* SEQPAR_func(x));
            eval(['Theta_func = @(x) Theta_func(x) .* ' seq_pars{i} '_func(' ALFONSO.var2fstr(dep_pars,'%s_func(x)',',') ');']);
        end
    end
    
    %% final assembly of modelfunc
    % modelfunc = @(x) Upsilon_func(x) .* Theta_func(x);
    % nl2sol workaround: ensure x are col vectors to ensure correct
    % handling of dimensions
    modelfunc = @(x) Upsilon_func(ensure_col(x)) .* Theta_func(ensure_col(x));
    
    % return parameter functions if requested
    if nargout > 1
        for i = 1:length( paramlist )
            cur_par = [paramlist{i} '_vars'];
            if this.is_model_param( cur_par )
                parfunc.(paramlist{i}) = eval([paramlist{i} '_func']);
            end
        end
    end
    
else
    error('Model definition missing. Please load model first using ALFONSO.set_model() !')
end

end