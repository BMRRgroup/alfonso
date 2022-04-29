function read_data( this )
%READ_DATA reads data from param.filename into the data array
%   READ_DATA trys to read in the file given in param.filename or calls the
%   file picker UI.
%
%   Parameters:
%    - reconparam.read_data.enable_cache = [0(default)|1] enables raw data
%    caching.
%
%   Supported raw data formats:
%       - Philips
%           - *.raw/*.lab (Gyrotools MRecon Version) using MRecon
%           - *.data/*.list/*.ini - data/list files plus an additional
%           configuration file
%       - GE
%           - *.7 raw data.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 7, 2018
%
% Revisions: 	0.1 (Sep 7, 2018)
%                   Initial version.
%               0.2 (Feb 27, 2019)
%                   Updated caching mechanism
%                   Added data / list reader prototype
%               0.3 (Jul 14, 2021)
%                   Added initial support for GE .7 raw data
%               0.4 (Oct 22, 2021)
%                   Bugfixed recon flag reset after reading from cache
%                   Added support for metabolic cycling parameters in
%                   Philips raw data
%               0.5 (Apr 21, 2022)
%                   Add init_scanparam method.
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

if this.reconparam.read_data.enable_cache && ~isempty(this.reconparam.read_data.cache)
    
    warning( [mfilename ': cache data found! Reset data to cached data!'])
    
    get_cache();
    
else
    
    if isempty(this.scanparam.filename)
        % provide simple file picker if filename was not provided
        [file_name, file_pathstring] = ...
            uigetfile('*.*', ...
            'Select spectroscopy data file ...', ...
            'MultiSelect', 'off');
        this.set_file([file_pathstring file_name]);
    end
    
    [file_pathstring, file_name, file_ext] = fileparts( [this.scanparam.filepathname this.scanparam.filename] );
    
    switch lower( file_ext )
        
%         case {'.example'} % .example file extension
%             % this is an example of how a custom data reader could be
%             % implemented
%             [ data, meta ] = read_custom_data( [this.scanparam.filepathname this.scanparam.filename] );
%             
%             % init scanparam
%             this.init_scanparam()
%             
%             % map the meta information manually to scanparam struct
%             % e.g.
%             %  this.scanparam.scan_name = meta.name; % map data read in (meta) to this.scanparam accordingly
%             %  this.scanparam.TE_s = meta.TE_ms .* 1e-3; % always convert to SI units, e.g. from ms -> s
%             this.scanparam.patient_id = [];
%             this.scanparam.scan_name = [];
%             this.scanparam.patient_id = [];
%             this.scanparam.dynSeries = [];
%             this.scanparam.dynSeries2 = [];
%             this.scanparam.dynSeries3 = [];
%             this.scanparam.TE_s = [];
%             this.scanparam.TM_s = [];
%             this.scanparam.TR_s = [];
%             this.scanparam.TI_s = [];
%             this.scanparam.bvalue = [];
%             this.scanparam.diffusion_gradient_mode = [];
%             this.scanparam.tau_s = [];
%             this.scanparam.spir_const_tau = [];
%             this.scanparam.voxel_size_mm = [];
%             this.scanparam.bandwidth_Hz = [];
%             this.scanparam.fieldstrength_T = [];
%             this.scanparam.gamma_bar = [];
%             this.scanparam.acq_window_center_ppm = [];
%             this.scanparam.n_sample = [];
%             this.scanparam.freqsign = [];
%             this.scanparam.metcycle = [];
%             this.scanparam.bvalue_spm2 = [];  % always convert to SI units, e.g. convert from s / mm^2 to s / m^2 (=spm2)
%             this.scanparam.n_sample = [];
%             this.scanparam.freqsign = -1; % Philips -> -1 => counter clockwise, SIEMENS, GE -> 1 => clockwise
%             
%             % set data
%             this.set_data( data, meta.dimensions_cell )
%             % meta.dimensions_cell informs about the content of each
%             % dimension and should start with x (sampling / readout), e.g. 
%             % {'x', 'coil', 'average', 'TE'}
%             
%             clear data meta
        
        case {'.raw', '.lab'} % Philips RAW / LAB raw data (requires gyrotools MRecon license)
            
            [ data, meta ] = read_PHILIPS_rawlab_mrecon( [this.scanparam.filepathname this.scanparam.filename] );
            
            % init scanparam
            this.init_scanparam()
            
            metafields = fieldnames(meta);
            for iField = 1:length(metafields)
                this.scanparam.(metafields{iField}) = meta.(metafields{iField});
            end
            
            % set data
            this.set_data( data, meta.dimensions )
            
            clear data meta

        case {'.data', '.list'} % Philips DATA / LIST raw data
            
            % this is a quick an dirty implementation of a Philips DATA /
            % LIST reader and requires some improvements in the future
            
            [ data, info] = read_PHILIPS_datalist( [this.scanparam.filepathname this.scanparam.filename] );
            
            % set param
            this.init_scanparam()
            
            % read in ini file which holds addtional required information
            inifile = IniConfig;
            if ~inifile.ReadFile( [file_pathstring filesep file_name '.ini'])
                error('Could not find .ini file which is required to read in .data/.list. The .ini file has to be created manually and holds the missing meta information. Please see /DataReader/PHILIPS/data-list-example.ini for an example.')
            end
            
            initfile_section = 'ScanParam';
            
            init_keys = inifile.GetKeys(initfile_section);
            for ikey = 1:length( init_keys )
                this.scanparam.(init_keys{ikey}) = inifile.GetValues(initfile_section, init_keys{ikey});
            end
            
            if isfield(this.scanparam,'bvalue')
                % convert from s / mm^2 to s / m^2
                this.scanparam.bvalue_spm2 = this.scanparam.bvalue .* 1e6;
                this.scanparam = rmfield(this.scanparam, 'bvalue');
            end
            
            this.scanparam.n_sample = info.nReadoutPoints;
            this.scanparam.freqsign = -1; % Philips -> -1 => counter clockwise
            
            PHILIPS_datalist_dimensions = {'x', 'coil', 'average', this.scanparam.dynSeries};
            
            % set data
            this.set_data( data, PHILIPS_datalist_dimensions )
            
            clear data info
            
        case {'.sdat', '.spar'} % Philips SDAT / SPAR data
            
            error(['Raw data file type (' file_ext ') not yet supported! (' this.scanparam.filename ')'])
            
        case {'.rda'} % Siemens raw data
            
            error(['Raw data file type (' file_ext ') not yet supported! (' this.scanparam.filename ')'])
            
        otherwise
            
            if startsWith(file_ext, '.7') % GE raw data
                
                [ ~,data] = io_loadspec_GE([this.scanparam.filepathname this.scanparam.filename], 0);
                
                % this needs to be adjusted for higher dimensional data
                data_dimensions = {'x', 'coil', 'average'};
                
                
                % set param
                this.init_scanparam()
                this.scanparam.scan_name = this.scanparam.filename;

                this.scanparam.n_dyn = data.subspecs;
                this.scanparam.n_mix = 1;
                this.scanparam.n_coil = data.sz(data.dims.coils);
                this.scanparam.n_echo = 1;
                this.scanparam.n_loc = 1;
                this.scanparam.n_aver = data.sz(data.dims.averages);
                this.scanparam.n_sample = data.sz(data.dims.t);

                this.scanparam.voxel_size_mm = [];
                this.scanparam.fieldstrength_T = data.Bo;
                this.scanparam.bandwidth_Hz = data.spectralwidth;

                this.scanparam.gamma_bar = data.txfrq / this.scanparam.fieldstrength_T; % Hz / Tesla


                this.scanparam.TE_s = data.te .* 1e-3;

                this.scanparam.TM_s = [];

                this.scanparam.bvalue_spm2 = [];

                this.scanparam.TR_s = data.tr .* 1e-3;

                this.scanparam.TI_s = [];

                this.scanparam.acq_n = [];
                
                this.scanparam.dynSeries = 'TE';

                this.scanparam.acq_window_center_ppm = data.ppm(end/2);
                
                this.scanparam.freqsign = 1; % GE -> 1 => clockwise

                this.scanparam.patient_id = this.scanparam.filename;
                this.scanparam.series_time = [];
                this.scanparam.series_number = [];
                this.scanparam.diffusion_gradient_mode = [];

                % set data
                this.set_data( data.fids, data_dimensions )

                clear data data_dimensions
            else
                error(['Unkown file type: ' file_ext ' (' this.scanparam.filename ')'])
            end
            
    end
    
end

% handle diffusion information
this.set_diffusion_orientation();

% perform caching activities
set_cache();

% calculate PPM scale
this.get_ppm_scale;

this.flags.read_data = 1;

    function set_cache()
        % cache data if wanted
        if this.reconparam.read_data.enable_cache
            this.reconparam.read_data.cache.data = this.data;
            this.reconparam.read_data.cache.dims = this.dims;
            this.reconparam.read_data.cache.dims_siz = size( this.reconparam.read_data.cache.data );
            this.reconparam.read_data.cache.scanparam = this.scanparam;
        else
            this.reconparam.read_data.cache = [];
        end
    end

    function get_cache()
        % write back cache data
        this.data = this.reconparam.read_data.cache.data;
        this.dims = this.reconparam.read_data.cache.dims;
        this.dims_siz = size( this.data );
        scanparam_fields = fieldnames(this.reconparam.read_data.cache.scanparam);
        for iField = 1:length(scanparam_fields)
            this.scanparam.(scanparam_fields{iField}) = this.reconparam.read_data.cache.scanparam.(scanparam_fields{iField});
        end
        % reset flags
        this.reset_flags;
        this.flags.read_data = 1;
    end

end

 