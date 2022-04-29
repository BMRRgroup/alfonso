function set_ref_freq( this, varargin )
%SET_REF_FREQ sets the ppm reference by setting acq_window_center_ppm in
% scanparam
%   set_ref_freq( ppm=1.3 ) sets the ppm reference based on the largest present
%       peak in the first dynamic - in this case the largest peak is
%       shifted to 1.3 ppm (e.g. meaningful if methylene if largest peak)
%   set_ref_freq( 'autoset-waterfat', ppm=1.3 ) tries to set the ppm
%       reference based on the methylene peak in the first dynamic.
%       Additionally, a look around for a water-peak is performed and considered.
%       The spectrum is shifted according to the methylene peak to 1.3 ppm.
%
%   Parameters: 
%    - reconparam.set_ref_freq.defaults.mode = ['simple'
%      | 'autoset-waterfat'] sets working mode:
%       - simple: sets largest peak to the passed ppm value
%       - autoset-waterfat: tries to set reference based on the methylene
%       peak to the passed ppm value. Method tries to compensate for the
%       presence of a large water peak. 
%    - reconparam.set_ref_freq.defaults.autoset_waterfat.lookaround_distance_ppm
%      = ppm range (float) expected offset (in ppm) between water and fat peak
%    - reconparam.set_ref_freq.defaults.autoset_waterfat.lookaround_range_ppm 
%      = ppm range (float) ppm range within which water / peak is expected
%    - reconparam.set_ref_freq.defaults.autoset_waterfat.noise_level_factor
%      = (float) noise level factor which used to calculate the peak 
%      threshold: peak_noise_level = mean(noise) + noise_level_factor * 
%      SD(noise)
%    - reconparam.set_ref_freq.defaults.autoset_waterfat.noise_meas_range
%      = [0-1] (float) relative length (rel. to total spectrum) used to 
%      determin noise level
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 26, 2019
%
% Revisions: 	0.1 (Mar 26, 2019)
%                   Initial version.
% 	        	0.1.1 (Feb 28, 2020)
%                   Added autoset mode function: autoset-waterfat
%               0.2 (Oct 09, 2020)
%                   Parameterized autset-waterfat
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

if length( varargin ) == 1 % simple mode which sets ppm based on largest peak
    mode_pars = varargin{1};
    mode = this.reconparam.set_ref_freq.defaults.mode;
elseif length( varargin ) > 1 % autoset modes
    mode = varargin{1};
    mode_pars = varargin{2};
else
    error('ALFONSO.set_ref_freq requires 1 or 2 arguments!')
end

this.get_ppm_scale();

data = this.get_data('x');
data = data(:,1);
data = abs(real(this.ifft( data )));

% ppm_offset needs to be set within the switch statment
switch mode
 
    case 'simple'
        % shift largest peak to requested ppm 
        ppm = mode_pars;
        [~, idx] = max( data );
        ppm_offset = ppm - this.scanparam.ppm_abs(idx);
        
    case 'autoset-waterfat'
        % get largest peak and then do a look around for a
        % waterpeak with a ppm offset of 3.4 ppm 
        % (= 4.7ppm (water) - 1.3 ppm (methylene))
        
        ppm = mode_pars;
        
        % determine the distance between the water and fat peak
        ppm_delta = this.scanparam.ppm_rel(2) - this.scanparam.ppm_rel(1);
        ppm_lookaround_distance = round(this.reconparam.set_ref_freq.defaults.autoset_waterfat.lookaround_distance_ppm / ppm_delta);
        ppm_lookaround_range = round(this.reconparam.set_ref_freq.defaults.autoset_waterfat.lookaround_range_ppm / abs(ppm_delta));
        
        noise_meas_range = round(length(data) * this.reconparam.set_ref_freq.defaults.autoset_waterfat.noise_meas_range);
        % define noise level decision level as mean(noise) + noise_level_factor * std(noise)
        noise_level = mean(data(1:noise_meas_range)) + this.reconparam.set_ref_freq.defaults.autoset_waterfat.noise_level_factor * std(data(1:noise_meas_range));
        
        % find largest peak (this is expected to be water OR methylene)
        [~, idx] = max( data );
        % get array center index of the pontential methylene peak 
        peak_range = [idx-ppm_lookaround_distance-ppm_lookaround_range idx-ppm_lookaround_distance+ppm_lookaround_range];

        [~, look_around_peak_idx] = max( data(peak_range(1):peak_range(2)) );
        look_around_peak_idx = look_around_peak_idx + peak_range(1);
        
        % decide based on the reference 
        if data( look_around_peak_idx ) > noise_level
            reference_peak_ppm = this.scanparam.ppm_abs( look_around_peak_idx );
        else
            reference_peak_ppm = this.scanparam.ppm_abs( idx );
        end
        
        ppm_offset = ppm - reference_peak_ppm;
        
    otherwise
end

this.scanparam.acq_window_center_ppm = ppm_offset;
this.get_ppm_scale();

this.flags.set_ref_freq = 1;

end
