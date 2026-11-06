function [data, dim_out] = get_data( this, dim )
%GET_DATA returns the data array according to passed dim
%   E.g. set_data( data, dim )
%
%   The last dimension merges all remaining dimensions that were not
%   specified in dim but exist in the dataset.
%
%   If no arguments passed: returns the array as it is
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 7, 2018
%
% Revisions: 	1.0 (Sep 7, 2018)
%                   Initial version.
%               1.1 (Aug 23, 2022)
%                   Bugfix: correct handling in case data is a vector
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


if nargin == 1
    
    data = this.data;
    
    dim_out = this.dims;
    
else
    
    if ischar(dim)
        dim = {dim};
    end
    
    if ~iscell(dim)
        error('ALFONSO:get_data:InvalidDimType', ...
            'dim must be a cell array of character vectors. Got: %s', class(dim))
    end
    
    if ~isvector(this.data) % make sure data is not yet a vector
        
        % find all
        order = [];
        len_count = length( this.dims_siz );
        
        for iD = 1:length(dim)
            if ~strcmp(dim{end},'rest')
                pos = ismember( this.dims, dim{iD} );
                if sum(pos) == 1
                    order(end+1) = find(pos);
                else
                    order(end+1) = len_count + 1;
                    len_count = len_count + 1;
                end
            end
        end
        
        % add left over dimensions to order array
        data_dims = 1:length( this.dims_siz );
        add_dims = data_dims(~ismember(data_dims, order));
        order(end+1:end+length(add_dims)) = add_dims;
        
        data = permute( this.data, order );
        
        if length(order) > length(dim)
            
            % extend dims array
            dims_siz_tmp = ones(1,length(order));
            dims_siz_tmp(1:length(this.dims_siz)) = this.dims_siz;
            
            if strcmp(dim{end},'rest')
                data = reshape(data, [dims_siz_tmp(order(1:length(dim)-1)) prod(dims_siz_tmp(order(length(dim):end)))]);
            else
                data = reshape(data, [dims_siz_tmp(order(1:length(dim))) prod(dims_siz_tmp(order(length(dim)+1:end)))]);
            end
            
        end
        
    else
        data = this.data;
    end
    
    if nargout > 1
        dim_out = dim;
    end
    
end

end