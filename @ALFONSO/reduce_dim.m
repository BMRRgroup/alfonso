function param_values = reduce_dim( this, dim, idx )
%REDUCE_DIM reduces the numer of entries in a dimension
%   param_values = ALFONSO.reduce_dim( dim, idx) reduces values in dim and 
%       returns a sequence parameter remaining parameter values
%
%   See also ALFONSO/data_info
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 19, 2022
%
% Revisions:    0.1 (Oct 19, 2022)
%					Initial version.
%
% Authors: 
%
%   stefan.ruschke@tum.de
% 
% --------------------------------
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

switch dim 
    case {'x'}
        
        % validate selected idices - equidistant sampling required! 
        if sum(abs(diff(idx,2))) > 0
            error('ALFONSO:reduce_dim:NonEquidistant', ...
                'Equidistant sampling required for dimension reduction.')
        end
        
        % update data
        FID = this.get_data( {'x'} );
        this.set_data( FID( idx, :), {'x'} );
        
        % update meta
        this.scanparam.n_sample = length( idx );
        this.scanparam.bandwidth_Hz = this.scanparam.bandwidth_Hz / (idx(2) - idx(1));
        if isfield( this.scanparam, 'sampling_time_s')
            this.scanparam.sampling_time_s = this.scanparam.sampling_time_s( idx );
        end
        this.get_ppm_scale();
        
        param_values = (1 / this.scanparam.bandwidth_Hz) .* (1:length(idx));
        
    case {'TI', 'TE', 'TM', 'bvalue'}
        error('ALFONSO:reduce_dim:NotImplemented', ...
            'Dimension "%s" reduction is not yet implemented.', dim)
    case {'aver'}
        error('ALFONSO:reduce_dim:NotImplemented', ...
            'Dimension "%s" reduction is not yet implemented.', dim)
    otherwise
        error('ALFONSO:reduce_dim:UnsupportedDim', ...
            'Cannot handle dimension "%s" in reduce_dim.', dim)
end

end
