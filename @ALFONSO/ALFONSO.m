classdef ALFONSO < matlab.mixin.Copyable & dynamicprops
%ALFONSO A versatiLe Formulation fOr N-dimensional Signal mOdel fitting of MR spectroscopy data
%   ALFONSO provides convenient functions for simple data processing, fitting and visualization.
%   It's main focusing is on the simple yet versatile definition of model fitting strategies
%   allowing easy rapid prototyping and comparison of fitting strategies / constraints / models.

    properties
        data
        dims
        dims_siz
        scanparam
        reconparam
        quantparam
        flags
        quant
        cur_quant
        version
        gitinfo
    end
    
    methods
        
        function this = ALFONSO( filename )
            
            this.version = '0.1.1';
            
            this.gitinfo = get_gitinfo(mfilename('fullpath'));

            %% parameter initialization 
            % scanparam
            this.scanparam.filepathname = [];
            this.scanparam.filename = [];
            this.init_scanparam();
            
            %% Apodization:
            % (0|1) enable method
            this.reconparam.apodization.enable = 0;
            % (0|1) enable debug output 
            this.reconparam.apodization.debug = 0;
            % apodization.param will be passed to ALFONSO.apodize. See
            % details there.
            % mode: auto | manual
            this.reconparam.apodization.param.mode = 'auto'; 
            % filter type: cut-off | gaussian | lorentzian
            this.reconparam.apodization.param.filter = 'cut-off';
            % decay parameter controlling the filter
            this.reconparam.apodization.param.d = 1/500;
            
            %% AVERAGING
            % (0|1) enable method
            this.reconparam.averaging.enable = 1;
            % (0|1) enable debug output 
            this.reconparam.averaging.debug = 0; 
            % signal averaging over repetition dimension 
            this.reconparam.averaging.crosscorr_magn = 1;
            % (0|1) turns OFF / ON a frequency correction before averaging 
            %   based on the magnitude spectrum using crosscorrelation
            this.reconparam.averaging.crosscorr_max_ppm_shift = 0.7;
            % maximum expected frequency shift (in ppm)
            %   (controles MAXLAG option of xcross)
            
            %% Coil combination:
            % (0|1) enable method
            this.reconparam.coilcombination.enable = 1;
            % (0|1) enable debug output 
            this.reconparam.coilcombination.debug = 0;
            % coil selection mode
            %   manual: use only measured data from specified coil elements; 
            %   auto: selects the coils
            this.reconparam.coilcombination.coil_selection_mode = 'manual';
            % set to 0 to use all coil elements or select specific coil elements using an index array    
            this.reconparam.coilcombination.selected_coil = 0; 
            % defines the treshhold level below which coils are discardet based on the normalized autocorrelation factor
            this.reconparam.coilcombination.auto_coil_selection_corr_thresh = 0.99; 

            %% Frequency Offset Correction:
            % (0|1) enable method
            this.reconparam.frequency_offset_correction.enable = 0;
            % (0|1) enable debug output 
            this.reconparam.frequency_offset_correction.debug = 0;
            this.reconparam.frequency_offset_correction.max_ppm_shift = 0.2;
            
            %% Phase Correction:
            % (0|1) enable method
            this.reconparam.phase_correction.enable = 1;
            % (0|1) enable debug output 
            this.reconparam.phase_correction.debug = 0;
            this.reconparam.phase_correction.use_mean_phasor = 0;
            % inversion-recovery series: 
            % experimental method to to correctly phase IR series based on
            % the longest TI
            this.reconparam.phase_correction.IR_phase_stabilzer_enable = 1;
            
            %% Polarity Combination: 
            % (0|1) enable method
            this.reconparam.polaritycombination.enable = 1;
            % (0|1) enable debug output 
            this.reconparam.polaritycombination.debug = 0;
            % (0|1) perform magnitude-based prior to the signal combination
            this.reconparam.polaritycombination.crosscorr_magn = 1;
            
            %% Read Data:
            % save important data to save time when reprocessing is
            % required
            this.reconparam.read_data.enable_cache = 0;
            this.reconparam.read_data.cache = [];
            
            %% Set reference frequency: (SHIFTING & ALIGNMENT)
            this.reconparam.set_ref_freq.defaults.mode = 'simple';
            % expected offset (in ppm) between water and fat peak
            this.reconparam.set_ref_freq.defaults.autoset_waterfat.lookaround_distance_ppm = 3.4; 
             % ppm range within which water / peak is expected
            this.reconparam.set_ref_freq.defaults.autoset_waterfat.lookaround_range_ppm = 0.75;
            % noise level factor which used to calculate the peak
            % threshold: peak_noise_level = mean(noise) + noise_level_factor * SD(noise)
            this.reconparam.set_ref_freq.defaults.autoset_waterfat.noise_level_factor = 5;
            % relative length (rel. to total spectrum) used to determin noise level
            this.reconparam.set_ref_freq.defaults.autoset_waterfat.noise_meas_range = 0.05;
            
            %% initialize PLOTTING parameters
            % (0|1) enable debug output 
            this.reconparam.quant.fit_model.debug = 0;
            
            %% initialize PLOTTING parameters
            this.reconparam.plotting.ppm_range = [0 6];
            
            % apodization settings for plotting only
            this.reconparam.plotting.apodize.enable = 1;
            this.reconparam.plotting.apodize.param.mode = 'auto';
            this.reconparam.plotting.apodize.param.filter = 'cut-off';
            this.reconparam.plotting.apodize.param.d = 1/500;
            
            this.reconparam.plotting.plot_fitModel.plot_peaks = 0;
            this.reconparam.plotting.plot_fitModel.plot_CI = 0;
            this.reconparam.plotting.plot_fitModel.plot_single_dynamics = 0;
            this.reconparam.plotting.plot_fitModel.all_combinations = 0;

            %% quantification properties
            % fit_model settings
            this.quantparam.optimset.algorithm = 'NL2SOL';
            this.quantparam.optimset.Display = 'Iter';
            this.quantparam.optimset.ScaleProblem = 'none';
            this.quantparam.optimset.LargeScale = 'on';
            this.quantparam.optimset.TolFun = 1e-10;
            this.quantparam.optimset.RelTolFun = 1e-10; % NL2SOL only
            this.quantparam.optimset.MaxFunEvals = 1e6;
            this.quantparam.optimset.MaxIter = 400;
            this.quantparam.optimset.TolX = 1e-8;
            this.quantparam.receiver_correction.enable = 0;
            
            %% initialize flags
            this.flags.apodization = 0;
            this.flags.averaging = 0;
            this.flags.coilcombination = 0;
            %this.flags.eddycurrent_phase_corrected = 0;
            this.flags.frequency_offset_correction = 0;
            this.flags.phase_corrected = 0;
            this.flags.polaritycombination = 0;
            this.flags.read_data = 0;
            this.flags.set_ref_freq = 0;
            % quantification related flags
            this.flags.fitModel = 0;
            this.flags.fitParam2Freq = 0;
            
            % initialize current quantification
            this.cur_quant = 1;
            
            % set file
            if nargin > 0
                this.set_file(filename);
            else
                this.scanparam.filename = '';
                this.scanparam.filepathname = '';
            end
            
            % set additional param
            this.set_script_dirs();
            
        end
        
        % declaration of function signatures (alphabetical order)
        % general methods
        apodization( this )
        averaging( this )
        coilcombination( this )
        %eddycurrent_phase_correction( this )
        frequency_offset_correction( this )
        [ data, dim_out ] = get_data( this, dim )
        get_ppm_scale( this )
        [ fid_corr ] = phase_correction( this, fid )
        polaritycombination( this )
        process( this )
        read_data( this )
        reset_flags( this )
        [ coils ] = select_coils( this )
        set_data( this, data, dim )
        set_diffusion_orientation( this )
        set_file( this, filename )
        set_ref_freq( this, varargin )
        squeeze_data_dim( this )
        %time_offset_correction( this )

        % plotting methods
        [ fh ] = plot_fid(this)
        [ fh ] = plot_dynSeries(this, type, fig_limit )
        [ fh ] = plot_dyn(this, dyn, type )
        
        % helper methods
        freq_Hz = ppm2hertz( this, ppm )
        ppm = hertz2ppm( this, freq_Hz )
        init_scanparam( this )
        val = get_scanparam_val( this, param_name, idx )
        data_info( this )
        [ t ] = get_timedomain_sampling( this )
        [ idd ] = is_data_dim( this, dim_name )
        [ isp, found_parname ] = is_scanparam( this, param_name );
        [ param_unit, param_factor ] = get_dim_display_info( this, scanparam )

        % data obj helper methods
        [ fname, ALFONSOobj ] = save_obj( this, filename, dest )
        [ ALFONSOobj ] = load_obj( this, filename )
        [ objfilename ] = get_obj_filename( this )
        [ obj_exists ] = exists_obj( this, dest )
        
        % quantification methods
        set_model( this, model_name, quant_idx );
        set_peaks( this, peaks_ppm, peak_names );
        save_model( this );
        [ model_names ] = get_model_names( this );
        [ modelfunc, parfunc ] = get_model_func( this );
        [ paramlist ]   = get_model_param_list( this );
        [ imp ] = is_model_param( this, param_name );
        fit_model( this );
        fit_param2freq( this, dim );
        set_script_dirs( this );
        [data, dims] = generate_signal( this, x_in );
        [ SNR ] = get_SNR( this, threshhold );
        [ noisy_data, noise ] = add_noise(this, SNR );
        
        % quantification plotting methods
        [ fh ] = plot_fit_model( this, type, fig_limit );
        [ fh ] = plot_fit_param2freq( this );
        
    end
    
    methods(Hidden)
        % declaration of function signatures
    end
    
    methods(Static)
        
        % declaration of function signatures
        [ data ]    = apodize( data, param )
        [ weightingArray, ...
            coil_weights ] ...
                    = complexweighting( inputArray )
        [ output ]  = estimate_profile_shifts( prof, param )
        [ spec ]    = fft( fid , zerofilling, dim )
        [ idx ]     = get_zerox( s )
        [ fid ]     = ifft( spec , zerofilling, dim )
        save_plots(filepath, FORMAT)
        [ str ]     = var2fstr( c, FORMAT, DELIMITER )
        [ fit, rcf ]     = receiver_correction( fit, fid )
        
        % quantification related methods
        [ X ]           = bound_inv_tanh(Xb, LB, UB);
        [ Xb ]          = bound_tanh(X, LB, UB);
        [ paramlist ]   = get_scan_param_list();
        [ M ]           = get_TAGmat( nSpecies );
        [ ADC ]         = model_mitra( r, D_free, DT );
        [ mcw ]         = model_murdaycotts( r, D, DT, G, delta_G, J0_roots, gamma_bar );
        [ rho ]         = model_TAG( ndb, nmidb, CL, nSpecies );

    end
end
