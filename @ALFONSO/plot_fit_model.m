function fh = plot_fit_model( this, type, fig_limit )
%PLOT_FIT_MODEL plots results form the ALFONSO.fit_model routine for the
%current quantification
%   fh = plot_fit_model( type, fig_limit ) plots the type (e.g. 'real')
%      spectra together with the fitting of the current model.
%   Arguments:
%     type (string) - name of a function handle converting complex-valued spectra to real-valued output. E.g. real, abs, angle
%     fig_limit (optional, integer) - max. number of plotted dynamics
%
%   Returns:
%     fh - figure handle
%
%   See also ALFONSO/plot_dyn, ALFONSO/plot_dynSeries
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 15, 2018
%
% Revisions: 	0.1 (Oct 15, 2018)
%                   Initial version.
%               0.2 (Oct 19, 2018)
%                   Added some more plotting options for a varying number
%                   of dynamic dimenions.
%               0.3 (Nov 3, 2018)
%                   General improvements. Updated plots for 2 dynamic
%                   dimensions.
%               0.4 (Oct 21, 2019)
%                   Added handling for multiple quantifications.
%               0.4.1 (Oct 23, 2019)
%                   Allow manuel limit of number of plots. (fig_limit)
%               0.4.2 (Oct 23, 2019)
%                   added support for plotting fitted peaks.
%               0.4.3 (Mar 20, 2020)
%                   Some refactoring for axes plotting.
%               0.4.4 (Mar 28, 2020)
%                   Added option to plot also confidence intervals
%               0.4.5 (May 11, 2020)
%                   Some code refactoring for X axis labeling
%               0.4.6 (Jun 05, 2020)
%                   Updated figure names
%               0.4.7 (Jul 07, 2020)
%                   Bugfixed single dimension plots
%               0.5 (Jun 04, 2021)
%                   Bugfixed handling for data that was not averaged.
%               0.5.1 (Jul 14, 2021)
%                   Bugfixed plotting range definition. Bugfixed singelton
%                   dimension handling.
%               0.5.2 (Nov 07, 2021)
%                   Fixed background.
%               0.5.3 (Apr 21, 2022)
%                   Removed apodization of spectral data.
%           TODO: refactoring and unification
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

check_requirements()

if nargin < 2
    type = 'real';
elseif isempty(type)
    type = 'real';
end

if nargin < 3
    fig_limit = [];
end

[~, objfilename ] = fileparts(this.scanparam.filename);

known_dynamics = {'x', 'TI', 'TE', 'TM', 'TR', 'bvalue'};

found_dyn = known_dynamics(ismember(known_dynamics, this.dims));

disp(['Recognized the following dyanmics: ' ALFONSO.var2fstr( found_dyn, '%s', ', ')]);

if length( found_dyn ) > 1
    [param_unit, param_factor] = this.get_dim_display_info( found_dyn(2:end) );
end

n_dyn1 = length(found_dyn);

spec = this.ifft( this.get_data(found_dyn) );

% estimate absolute ppm scale if possible
% TODO: check if still required!
if isfield(this.quant{this.cur_quant}.model.param, 'ppm_ref_signal')
    ppm_ref_shift = 0%-this.quant{this.cur_quant}.output.param.omega(this.quant{this.cur_quant}.model.param.ppm_ref_signal);
else
    ppm_ref_shift = 0;
end
ppm_abs = this.scanparam.ppm_rel + ppm_ref_shift;

% get plotting range according to ppm range
[~,idx1] = min( abs( this.scanparam.ppm_rel-this.reconparam.plotting.ppm_range(1) ) );
[~,idx2] = min( abs( this.scanparam.ppm_rel-this.reconparam.plotting.ppm_range(2) ) );
x_plot_rang_idx = sort([idx1 idx2]);
x_plot_rang = x_plot_rang_idx(1):x_plot_rang_idx(2);

scan_param_list = this.get_scan_param_list();
% construct fitdata permute order to match spec dimension order
[~,fitdata_permute_idx]=ismember(this.dims,scan_param_list);
fitdata_permute_idx(1) = 1; % this is x
fitdata_permute_idx = [1  fitdata_permute_idx+1];
fitdata_permute_idx = unique([fitdata_permute_idx 1:ndims(this.quant{this.cur_quant}.output.fit)], 'stable');

fitdata = squeeze(this.ifft( permute(this.quant{this.cur_quant}.output.fit, fitdata_permute_idx), [], 2));

% ensure we did not loose the first dim in case we only fitted for a single
% species. 
if sum(size(fitdata)>1) == sum(size(spec)>1)
    fitdata = shiftdim(fitdata,-1);
end
    
propfh = str2func(['@(x) ' type '(x)']);

switch n_dyn1
    case 0
        error([mfilename ': cannot find any known dimension. I am currently aware of the follwing ones: ' ALFONSO.var2fstr( known_dynamics ) ])
    case 1
        
        fh = figure;
        fh.Color = [1 1 1];
        hold all
        
        fh.Name = [objfilename '_' this.scanparam.scan_name '_TE' num2str(this.scanparam.TE_s * 1e3) 'ms_' type '_fitmodel_spectrum'];
        
        title(['spectrum @ TE = ' num2str(this.scanparam.TE_s * 1e3) ' ms'])
        
        plot( ppm_abs(x_plot_rang), ...
            propfh( squeeze(fitdata(:,x_plot_rang)) ), 'b', ...
            'LineWidth', 1);
        
        h{1} = plot( ppm_abs(x_plot_rang), ...
            propfh( spec(x_plot_rang) ), ...
            'Color', [0 0 0], ...
            'LineWidth', 3);
        
        h{2} = plot( ppm_abs(x_plot_rang), ...
            propfh( sum(squeeze(fitdata(:,x_plot_rang)),1) ), 'b', ...
            'LineWidth', 3);
        
        h{3} = plot( ppm_abs(x_plot_rang), ...
            propfh( spec(x_plot_rang) ) - propfh( sum(squeeze(fitdata(:,x_plot_rang)),1).' ), 'r', ...
            'LineWidth', 2);
        
        set_XYaxes()
        
        % legend
        legend_txt = {'measured', 'fitted', 'residual'};
        lgd = legend([h{1}(1), h{2}(1), h{3}(1)], legend_txt, 'Location', 'best');
        
    case 2
        
        n_dyn1 = size(spec, 2);
        
        if isempty( fig_limit )
            n_dyn1_max = n_dyn1;
        else
            n_dyn1_max = min([fig_limit n_dyn1]);
        end
        
        if this.reconparam.plotting.plot_fitModel.plot_single_dynamics
            if ((n_dyn1_max < 10) | ~isempty(fig_limit))
                
                for id1 = 1:n_dyn1_max
                    
                    fh{id1} = figure;
                    fh{id1}.Color = [1 1 1];
                    hold all
                    
                    fh{id1}.Name = [objfilename '_' this.scanparam.scan_name '_dynamic' found_dyn{2} '_' found_dyn{2} num2str((this.get_scanparam_val(found_dyn{2},id1)) * 1e3) '_ms' type '_fitmodel_spectrum'];
                    
                    title(['dynamic ' found_dyn{2} ' series @ ' found_dyn{2} ' = ' num2str((this.get_scanparam_val(found_dyn{2},id1)) * 1e3) ' ms'])
                    
                    h{1} = plot( ppm_abs(x_plot_rang), ...
                        propfh( spec(x_plot_rang,id1) ), 'k', ...
                        'LineWidth', 2);
                    
                    h{2} = plot( ppm_abs(x_plot_rang), ...
                        propfh( sum(squeeze(fitdata(:,x_plot_rang,id1)),1) ), 'b', ...
                        'LineWidth', 2);
                    
                    h{3} = plot( ppm_abs(x_plot_rang), ...
                        propfh( spec(x_plot_rang,id1) ) - propfh( sum(squeeze(fitdata(:,x_plot_rang,id1)),1).' ), 'r', ...
                        'LineWidth', 2);
                    
                    if this.reconparam.plotting.plot_fitModel.plot_peaks
                        for iPeak = 1:size(fitdata,1)
                            h{3+iPeak} = plot( ppm_abs(x_plot_rang), propfh( squeeze( fitdata(iPeak, x_plot_rang, id1) ) ), 'b--', 'LineWidth', 1);
                        end
                    end
                    
                    %                     if this.reconparam.plotting.plot_fitModel.plot_CI
                    %                         lb = this.ifft(squeeze(sum(this.quant{this.cur_quant}.output.modelfunc(this.quant{this.cur_quant}.output.xout_CI(1,:)),1).*this.quant{this.cur_quant}.output.scaling_factor));
                    %                         ub = this.ifft(squeeze(sum(this.quant{this.cur_quant}.output.modelfunc(this.quant{this.cur_quant}.output.xout_CI(2,:)),1).*this.quant{this.cur_quant}.output.scaling_factor));
                    %                         h{end+1} = plot( ppm_abs(x_plot_rang), propfh( lb(x_plot_rang,id1) ), '--', 'LineWidth', 0.75, 'color',[0 0 0]+0.1);
                    %                         h{end+1} = plot( ppm_abs(x_plot_rang), propfh( ub(x_plot_rang,id1) ), '--', 'LineWidth', 0.75, 'color',[0 0 0]+0.1);
                    %                     end
                    
                    set_XYaxes()
                    
                    % legend
                    legend_txt = {'measured', 'fitted', 'residual'};
                    lgd = legend([h{1}(1), h{2}(1), h{3}(1)], legend_txt, 'Location', 'best');
                    
                    
                end
            else
                warning(['Single dynamic plot suppressed as this would result in too many plots. (n=' num2str(n_dyn1) ')'])
            end
        end
        
        fh = figure;
        fh.Color = [1 1 1];
        hold all
        
        fh.Name = [objfilename '_' this.scanparam.scan_name '_dynamic' found_dyn{2} '_' type '_fitmodel_spectrum'];
        
        title(['dynamic ' found_dyn{2} ' series'])
        
        n_samples = length(this.scanparam.ppm_rel(x_plot_rang));
        n_dyn1 = size(spec,2);
        
        Y = this.scanparam.ppm_rel(x_plot_rang).' * ones( 1, n_dyn1 );
        Z = ones(n_samples, 1) *  this.get_scanparam_val(found_dyn{2}) .* param_factor(1);
        
        for idyn = n_dyn1:-1:1
            h{1} = plot3( Z(:,idyn), Y(:,idyn), propfh( spec(x_plot_rang,idyn) ), ...
                'Color', [0 0 0], ...
                'LineWidth', 1);
            
            h{2} = plot3( Z(:,idyn), Y(:,idyn), propfh( squeeze( sum(fitdata(:,x_plot_rang,idyn),1) ) ), 'b', 'LineWidth', 1);
            
            h{3} = plot3( Z(:,idyn), Y(:,idyn), propfh( squeeze( shiftdim( sum(fitdata(:,x_plot_rang,idyn),1), 1) ) ) - propfh( spec(x_plot_rang,idyn) ), 'r', 'LineWidth', 1);
            
            if this.reconparam.plotting.plot_fitModel.plot_peaks
                for iPeak = 1:size(fitdata,1)
                    h{3+iPeak} = plot3( Z, Y, propfh( squeeze( fitdata(iPeak,x_plot_rang,:) ) ), 'b--', 'LineWidth', 1);
                end
            end
        end
        
        set_YZaxes()
        
        % x axis
        set_XAxis(found_dyn{2})
        %ax.XTickLabelRotation = -28;

        % legend
        legend_txt = {'measured', 'fitted', 'residual'};
        lgd = legend([h{1}(1), h{2}(1), h{3}(1)], legend_txt, 'Location', 'NorthEast');
        
        
    case 3
        fh = {};
        n_dyn = size(spec);
        n_dyn(1) = [];
        n_dyn_max = arrayfun(@(x) min([fig_limit x]), n_dyn);
        
        dyn_names = found_dyn(2:end);
        
        [dyn_unit, dyn_factor] = this.get_dim_display_info( dyn_names );
        
        n_samples = length(this.scanparam.ppm_rel(x_plot_rang));
        
        for idim = 1:length(dyn_names)
            
            % array of names of others dynamics that the current
            % dynamic will be plotted against
            dyn_other_names = dyn_names(~ismember(dyn_names, dyn_names{idim}));
            
            for dim_other_idx = 1:length(dyn_other_names)
                
                idim_other = find( strcmp( dyn_names, dyn_other_names{dim_other_idx} ) );
                
                % only plot combinations that were not plotted yet
                if (idim_other > idim) || this.reconparam.plotting.plot_fitModel.all_combinations
                    
                    for idyn_dim_other = 1:n_dyn_max(idim_other)
                       
                        unused_dims = (length(found_dyn)+1):ndims(spec);
                        cur_spec = permute( spec, [1 idim+1 idim_other+1 unused_dims] );
                        cur_fitdata = permute( fitdata, [1 2 idim+2 idim_other+2 unused_dims+1] );
                        
                        fh{end+1} = figure;
                        fh{end}.Color = [1 1 1];
                        hold all
                        
                        fh_name = [objfilename '_' this.scanparam.scan_name ...
                            '_dynamic' ALFONSO.var2fstr( dyn_names, '%s', '-' ) ...
                            '_' dyn_names{idim_other} num2str((this.get_scanparam_val(dyn_names{idim_other},idyn_dim_other)) * dyn_factor(idim_other)) dyn_unit{idim_other} ...
                            '_' type '_fitmodel_spectrum'];
                        fh{end}.Name = fh_name;
                        
                        title_txt = [ ...
                            'dynamic ' ALFONSO.var2fstr( dyn_names, '%s', '-' ) ' series'...
                            ' @ ' dyn_names{idim_other} ' = ' num2str((this.get_scanparam_val(dyn_names{idim_other},idyn_dim_other)) * dyn_factor(idim_other)) dyn_unit{idim_other} ...
                            ];
                        
                        title(title_txt)
                        
                        Y = this.scanparam.ppm_rel(x_plot_rang).' * ones( 1, n_dyn(idim) );
                        Z = ones(n_samples, 1) *  this.get_scanparam_val(dyn_names{idim}) .* dyn_factor(idim);
                        
                        for idyn = n_dyn(idim):-1:1
                            h{1} = plot3( Z(:,idyn), Y(:,idyn), propfh( cur_spec(x_plot_rang,idyn,idyn_dim_other) ), ...
                                'Color', [0 0 0], ... 
                                'LineWidth', 1);
                            
                            h{2} = plot3( Z(:,idyn), Y(:,idyn), propfh( squeeze( sum(cur_fitdata(:,x_plot_rang,idyn,idyn_dim_other),1) ) ), 'b', 'LineWidth', 1);
                            
                            h{3} = plot3( Z(:,idyn), Y(:,idyn), propfh( squeeze( shiftdim( sum(cur_fitdata(:,x_plot_rang,idyn,idyn_dim_other),1), 1) ) ) - propfh( cur_spec(x_plot_rang,idyn,idyn_dim_other) ), 'r', 'LineWidth', 1);
                            
                            if this.reconparam.plotting.plot_fitModel.plot_peaks
                                for iPeak = 1:size(fitdata,1)
                                    h{end+iPeak} = plot3( Z(:,idyn), Y(:,idyn), propfh( squeeze( cur_fitdata(iPeak,x_plot_rang,idyn,idyn_dim_other) ) ), 'b--', 'LineWidth', 1);
                                end
                            end
                        end
                        
                        set_YZaxes()
                        
                        % x axis
                        set_XAxis(dyn_names{idim})
                        
                        % legend
                        legend_txt = {'measured', 'fitted', 'residual'};
                        lgd = legend([h{1}(1), h{2}(1), h{3}(1)], legend_txt, 'Location', 'NorthEast');
                    end
                    
                end
            end
        end
        
    case 4
        error('4 dimensions cannot be handled yet! Feel free to implement!')
    otherwise
        error('Not implemented!')
end


    function set_YZaxes()
        % set axis
        ax = gca;
        ax.Box = 'on';
        
        % y axis
        ax.YLabel.String = 'ppm';
        ax.YLim = this.reconparam.plotting.ppm_range;
        ax.YGrid = 'on';
        ax.YMinorGrid = 'on';
        ax.YMinorTick = 'off';
        ax.YAxis.MinorTickValues = this.reconparam.plotting.ppm_range(1):0.1:this.reconparam.plotting.ppm_range(2);
        
        % z axis
        ax.ZLabel.String = [type ' signal (a.u.)'];
        ax.ZAxis.TickValues = 0;
        ax.ZAxis.Exponent = 0; % avoid displaying the exponent in the plot
        ax.ZGrid = 'on';
        ax.ZMinorGrid = 'off';
        
        % adjust view
        ax.View = [-45 35];
    end

    function set_XYaxes()
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

    function set_XAxis( d )
        % set Xaxis according to dimension d
        label_str = d;
        val = this.get_scanparam_val( d );
        
        [unit, factor] = this.get_dim_display_info( d );
        val = val .* factor;
        label_str = [label_str ' (' unit{1} ')'];

        ax = gca;
        ax.XLabel.String = label_str;
        ax.XAxis.TickValues =  val;
        
        ax.XLim = [min(ax.XAxis.TickValues) max(ax.XAxis.TickValues)];
    end

    function check_requirements()
        if isempty( this.quant )
            error(['No quantification found. Run fit_model first...'])
        end
        if ~isfield( this.quant{this.cur_quant}, 'output')
            error(['No output found for quantification #' num2str(this.cur_qunat) '. Consider running fit_model first...'])
        end
    end

end