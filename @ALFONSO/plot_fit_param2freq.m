function fh = plot_fit_param2freq( this )
%PLOT_FIT_PARAM2FREQ plots results from the ALFONSO.fit_param2freq routine
%   fh = ALFONSO.plot_fit_param2freq plots fitted spectrum and returns the
%      figure handle.
%   See also ALFONSO/fit_param2freq
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 27, 2018
%
% Revisions: 	0.1 (Oct 27, 2018)
%               Initial version.
%               0.2 (Oct 21, 2019)
%               Added handling for multiple quantification results.
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

if this.flags.fitParam2Freq
    
    known_dynamics = {'x', 'TI', 'TE', 'TM', 'TR', 'bvalue'};
    
    found_dyn = known_dynamics(ismember(known_dynamics, this.dims));
    
    spec =  this.ifft( this.apodize( this.get_data( {'x', this.quant{this.cur_quant}.fitParam2Freq.param} ) ) );
    
    ppm_abs = this.scanparam.ppm_rel;
    
    param_freq = this.quant{this.cur_quant}.fitParam2Freq.param_freq;
    
    %param_freq(param_freq > 0.5) = 0;
    
    [~, objfilename ] = fileparts(this.scanparam.filename);
    
    % get mask
    mask = smooth( real( spec(:,1)) ./ max(real(spec(:,1))), 30);
    mask(mask < 0.01) = 0;
    %figure;plot(mask)
    mask = logical(mask);
    %param_freq(~mask) = 0;
    
    
    param_freq_plot = param_freq .* 1000;
    max_param_freq = max(param_freq_plot);
    
    spec_plot = abs(real(spec(:,1))) ./ max(abs(real(spec(:,1)))) .* max_param_freq;
    
    
    fh = figure;
    hold all
    
    fh.Name = [objfilename '_' this.scanparam.patient_id '_dynamic' found_dyn{2} '_freq_based_parfit'];
    
    hold all
    title(['Result from frequency based parameter fitting for ' this.quant{this.cur_quant}.fitParam2Freq.param])
    
    plot( ppm_abs, spec_plot, 'k');
    plot( ppm_abs, param_freq_plot, 'r', 'LineWidth', 2);
    
    if isfield(this.quant{this.cur_quant}, 'peaks')
        plot( [ppm_abs(this.quant{this.cur_quant}.peaks.ppm_rel_idx); ppm_abs(this.quant{this.cur_quant}.peaks.ppm_rel_idx)], [spec_plot(this.quant{this.cur_quant}.peaks.ppm_rel_idx) param_freq_plot(this.quant{this.cur_quant}.peaks.ppm_rel_idx)].', 'k.-')
        plot( ppm_abs(this.quant{this.cur_quant}.peaks.ppm_rel_idx), spec_plot(this.quant{this.cur_quant}.peaks.ppm_rel_idx), '*')
        plot( ppm_abs(this.quant{this.cur_quant}.peaks.ppm_rel_idx), param_freq_plot(this.quant{this.cur_quant}.peaks.ppm_rel_idx), '*')
        % add measurements as labels
        text_spacing = max(spec_plot) * 0.5e-1;
        for ipeak = 1:length(this.quant{this.cur_quant}.peaks.ppm)
            text_str = [this.quant{this.cur_quant}.peaks.names{ipeak} ': ' num2str(this.quant{this.cur_quant}.fitParam2Freq.peaks_param(ipeak),2)];
            text(ppm_abs(this.quant{this.cur_quant}.peaks.ppm_rel_idx(ipeak)), ...
                 double(spec_plot(this.quant{this.cur_quant}.peaks.ppm_rel_idx(ipeak)) + text_spacing), ...
                 text_str, ...
                 'HorizontalAlignment', 'left', ...
                 'Rotation', 90, ...
                 'FontWeight', 'bold');
        end
    end
    
    % set axis
    ax = gca;
    ax.Box = 'on';
    
    % X axis
    ax.XLabel.String = 'ppm';
    ax.XDir = 'rev';
    ax.XLim = this.reconparam.plotting.ppm_range;
    ax.XGrid = 'on';
    ax.XMinorGrid = 'on';
    ax.XMinorTick = 'off';
    ax.XAxis.MinorTickValues = this.reconparam.plotting.ppm_range(1):0.1:this.reconparam.plotting.ppm_range(2);
    ax.YLim = [0 max_param_freq*1.1];
    
    % x axis
    %ax.XLabel.String = this.quant{this.cur_quant}.fitParam2Freq.param;
    
    %plot( this.quant{this.cur_quant}.fitParam2Freq.param_freq  .* 1000);
    %plot(data(:,1)./maxn(data(:,1)).*maxn(this.quant{this.cur_quant}.fitParam2Freq.param_freq  .* 1000))
else
    error('Run fitParam2Freq first!')
end
end
