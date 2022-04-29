function fh = plot_dynSeries( this, type, fig_limit )
%PLOT_DYNSERIES plots the spectra stored in ALFONSO.data with respect to their
%dynamic
%   fh = plot_dynSeries() plots real spectra for all dynamics.
%
%   fh = plot_dynSeries(type) plots type (e.g. 'real') spectra for all 
%       dynamics. Any name of a function handle that can handle spectral data and
%       outputs real numbers can be used.
%
%   fh = plot_dynSeries('real', 10) plots real spectra for all 
%       dynamics, but maximum 10 dynamics.
%
%   The figure handle fh will be returned.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 13, 2018
%
% Revisions: 	0.1 (Oct 13, 2018)
%                   Very initial version.
%               0.2 (Oct 29, 2018)
%                   Minor adjustments to improve visualization.
%               0.3 (Nov 3, 2018)
%                   Added figure name. Updated figure style.
%               0.3.1 (Oct 28, 2019)
%                   Added fig_limit
%               0.3.2 (Mar 20, 2020)
%                   Refactoring some parts
%               0.3.3 (May 11, 2020)
%                   Bugfixes and optimization.
%               0.3.4 (May 12, 2020)
%                   Addtional refactoring and optimization.
%               0.3.5 (Jul 14, 2021)
%                   Bugfixed plotting range definition.
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

if nargin < 2
    type = 'real';
elseif isempty(type)
    type = 'real';
end

if nargin < 3
    fig_limit = [];
end

known_dynamics = {'x', 'TI', 'TE', 'TM', 'TR', 'bvalue'};

found_dyn = known_dynamics(ismember(known_dynamics, this.dims));

% if no dynamics were found, simply use TE
if length(found_dyn) == 1
   if this.is_scanparam('TE')
       found_dyn{end+1} = 'TE';
   end
end

disp(['Recognized the following dyanmics: ' ALFONSO.var2fstr( found_dyn, '%s', ', ')]);

[param_unit, param_factor] = this.get_dim_display_info( found_dyn(2:end) );

n_dyn = length(found_dyn);

if this.reconparam.plotting.apodize.enable
    spec = this.ifft( this.apodize( this.get_data(found_dyn), this.reconparam.plotting.apodize.param) );
else
    spec = this.ifft( this.get_data(found_dyn) );
end

% get plotting range according to ppm range
[~,idx1] = min( abs( this.scanparam.ppm_rel-this.reconparam.plotting.ppm_range(1) ) );
[~,idx2] = min( abs( this.scanparam.ppm_rel-this.reconparam.plotting.ppm_range(2) ) );
x_plot_rang_idx = sort([idx1 idx2]);
x_plot_rang = x_plot_rang_idx(1):x_plot_rang_idx(2);

propfh = str2func(['@(x) ' type '(x)']);

[~, objfilename ] = fileparts(this.scanparam.filename);

switch n_dyn
    case 0
        error([mfilename ': cannot find any known dimensions. I am currently aware of the follwing ones: ' ALFONSO.var2fstr( known_dynamics ) ])
    case 1
        error('Plotting for single dimension data not implemented!')
    case 2
        
        n_dyn1 = size(spec, 2);
        
        fh = figure;
        fh.Color = [1 1 1];
        hold all
        
        fh.Name = [objfilename '_' this.scanparam.scan_name '_dynamic' found_dyn{2} '_' type '_spectrum'];
        
        
        title(['dynamic ' found_dyn{2} ' series: ' type ' spectrum'])
        
        plot( this.scanparam.ppm_rel(x_plot_rang), ...
            propfh( spec(x_plot_rang,:) ), ...
            'LineWidth', 1)
        
        
%         % use plot3 for plotting
%         % this allows to also tild the plot
%         n_samples = length(this.scanparam.ppm_rel(x_plot_rang));
%         n_dyn1 = size(spec,2);
%         
%         Y = this.scanparam.ppm_rel(x_plot_rang).' * ones( 1, n_dyn1 );
%         Z = ones(n_samples, 1) *  this.get_scanparam_val(found_dyn{2}) .* param_factor(1);
%         for idyn = n_dyn1:-1:1
%             h{1} = plot3(Y(:,idyn), propfh( spec(x_plot_rang,idyn) ), Z(:,idyn), ...
%                 ....%'Color', [0 0 0], ...
%                 'LineWidth', 1);
%  
%         end
        
        
        
        set_axes();
        
        % legend
        legend_txt = [repmat([found_dyn{2} ' = '], [n_dyn1 1] ) num2str(to_row(this.get_scanparam_val(found_dyn{2})) .* param_factor(1)) repmat([' ' param_unit{1}], [n_dyn1 1] ) ];
        lgd = legend(legend_txt, 'Location', 'westoutside');
        
        
    case 3
        
        n_dyn1 = size(spec, 2);
        n_dyn2 = size(spec, 3);
        
        
        if isempty( fig_limit )
            n_dyn2_max = n_dyn2;
        else
            n_dyn2_max = min([fig_limit n_dyn2]);
        end
        
        for id2 = 1:n_dyn2_max
            
            fh{id2} = figure;
            hold all
            
            fh{id2}.Name = [objfilename '_' this.scanparam.scan_name '_dynamic' found_dyn{2} '_' found_dyn{3} '=' num2str((this.get_scanparam_val(found_dyn{3},id2)) * param_factor(2)) param_unit{2} '_' type '_spectrum'];
            
            title(['dynamic ' found_dyn{2} ' series @ ' found_dyn{3} ' = ' num2str((this.get_scanparam_val(found_dyn{3},id2)) * param_factor(2)) ' ' param_unit{2}])
            plot( this.scanparam.ppm_rel(x_plot_rang), ...
                real( spec(x_plot_rang,:,id2) ), ...
                'LineWidth', 1)
            
            set_axes()
            
            % legend
            legend_txt = [repmat([found_dyn{2} ' = '], [n_dyn1 1] ) num2str(to_row(this.get_scanparam_val(found_dyn{2})).* param_factor(1)) repmat([' ' param_unit{1}], [n_dyn1 1] ) ];
            lgd = legend(legend_txt, 'Location', 'westoutside');
            
        end
        
    case 4
        error('Not implemented!')
    otherwise
        error('Not implemented!')
end

    function set_axes()
        % set axis
        
        ax = gca;
        ax.Box = 'on';
        
        % x axis
        ax.XLabel.String = 'ppm';
        ax.XDir = 'rev';
        ax.XLim = this.reconparam.plotting.ppm_range;
        ax.XGrid = 'on';
        ax.XMinorGrid = 'on';
        ax.XMinorTick = 'off';
        ax.XAxis.MinorTickValues = this.reconparam.plotting.ppm_range(1):0.1:this.reconparam.plotting.ppm_range(2);
        
        % y axis
        ax.YLabel.String = [type ' signal (a.u.)'];
        ax.YTick = 0;
        ax.YAxis.Exponent = 0;  % avoid displaying the exponent in the plot
        ax.YGrid = 'on';
    end

end

