function fit_param2freq( this, dim )
%FIT_PARAM2FREQ performs a parameter fitting in frequency domain
%   This function makes use of Carl Ganters least_squares_varpro_gss_cg
%   function to perfrom a frequncy dependend parameter fitting.
%
%   VERY EXPERIMENTAL
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 24, 2018
%
% Revisions: 	0.1 (Oct 24, 2018)
%					Initial version.
%               1.1 (Oct 21, 2019)
%                   Added handling for multiple quantifications.
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


if ~exist('dim','var') && length(this.dims) > 2
    error([mfilename ': can only handle 2 dims! Pass dim as argument!'])
elseif ~exist('dim','var')
    dim = 2;
end

used_dims = this.dims([1 dim]);

spec = real( this.ifft( this.get_data( used_dims ) ) );

% atm we take the first dynamic in all not-selected dimensions
spec = spec(:,:,1);

spec = ALFONSO.apodize( spec );

this.quant{this.cur_quant}.fitParam2Freq.param = used_dims{2};

switch used_dims{2}
    case 'TR'
        x_in = this.get_scanparam_val(used_dims{2});
        TE = this.get_scanparam_val('TE');
        TM = this.get_scanparam_val('TM');
        if isempty(TM)
            TM = 0;
        end
        x_in = x_in - 0.5 * TE(1) - TM(1);
        
        x_scaling_factor = 1e-3;
        %figure;hold all;plot(this.quant{this.cur_quant}.fitParam2Freq.param_freq);plot(abs(spec))
    case 'TI'
        x_in = this.get_scanparam_val(used_dims{2});
        x_scaling_factor = 1;
    otherwise
        x_in = this.get_scanparam_val(used_dims{2});
        x_scaling_factor = 1000;
end

this.quant{this.cur_quant}.fitParam2Freq.param_freq = lsvp( x_in, spec, used_dims{2}, x_scaling_factor);

if iscell(this.quant) && isfield(this.quant{this.cur_quant}, 'peaks')
    if isfield(this.quant{this.cur_quant}.peaks, 'ppm')
        this.quant{this.cur_quant}.fitParam2Freq.peaks_param = this.quant{this.cur_quant}.fitParam2Freq.param_freq(this.quant{this.cur_quant}.peaks.ppm_rel_idx);
    end
end

% set flag 
this.flags.fitParam2Freq = 1;

    function param_map = lsvp ( x, data, param, scaling_factor )
        
        % Fitting function:
        switch param
            case 'TI'
                f = @( x_, ga_, p_ ) ( 1 - 2 * exp( - ga_ .* x_ ) );
                ub = 8 * scaling_factor;
                data = data ./ max(data(:));
            case 'TR'
                f = @( x_, ga_, p_ ) ( 1 - exp( - ga_ .* x_ ) );
                ub =  8 * scaling_factor;
            otherwise
                f = @( x_, ga_, p_ ) ( exp( - ga_ .* x_ ) );
                data = abs(data);
                data = data ./ max(data(:));
                ub = 0.2e-3 * scaling_factor;
        end
        
        x = x .* scaling_factor;
        
        % abs_err of gamma(fitting paramter):
        err = 1e-8;
        
        % perform fitting
        [ ~, ~, ga, ~ ] = least_squares_varpro_gss_cg( x, data, [], f, 0, ub, [], err );
        
        % prepare output
        ga = 1./ga;
        
        ga = ga ./ scaling_factor;
        
        param_map = ga;
        
        % debug: 
%         figure;
%         hold all;
%         plot( param_map .* 1000);
%         spec_scaling_factor = maxn(param_map .* 1000) ./ maxn(real(data(:,1)));
%         plot(real(data(:,1)).*spec_scaling_factor)
%         
%         %d1 = smooth(diff(real(data(:,1))), 0.1, 'rlowess');
%         d1 = smooth(diff(real(data(:,1))), 4);
%         d2 = smooth(diff(d1), 8);
%         d3 = smooth(diff(d2), 16);
%         
%         zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0);  % Returns Zero-Crossing Indices Of Argument Vector
%         
%         d1zx = zci(d1);    
%         
%         % ensure we do not overshoop vector size
%         if max(d1zx) > length(d2)
%             d1zx(d1zx == max(d1zx)) = [];
%         end
%         
%         % peaks: 
%         x_peaks = d1zx( d2(d1zx) < 0 );
%         
%         d2zx = zci(d2);    
%         % ensure we do not overshoop vector size
%         if max(d2zx) > length(d3)
%             d2zx(d2zx == max(d2zx)) = [];
%         end
%         x_peaks2 = d2zx( d3(d2zx) > 0 );
%         
%         spec_scaling_factor = maxn(param_map .* 1000) ./ maxn(d1);
%         plot(d1.*spec_scaling_factor)
%         plot(d1zx, zeros(size(d1zx)), 'k*')
%         plot( x_peaks, zeros(size( x_peaks)), 'r*')
%         spec_scaling_factor = maxn(param_map .* 1000) ./ maxn(d2);
%         plot(d2.*spec_scaling_factor)
%         spec_scaling_factor = maxn(param_map .* 1000) ./ maxn(d3);
%         plot(d3.*spec_scaling_factor)
%         plot(d2zx, zeros(size(d2zx)), 'ko')
%         plot( x_peaks2, zeros(size( x_peaks2)), 'ro')
        
    end

end

