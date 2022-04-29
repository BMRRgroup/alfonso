function set_data( this, data, dim )
%SET_DATA writes a data array to the ALFONSO.data.
%   E.g. set_data( data, dim ) set the data and corresponding dimension array
%   dim.
%   Example on how to manipulate the data array: Getting and setting data can
%   be done using the same dim cell array if the number of dimensions remains
%   unchanged.
%   > fid = ALFONSO.get_data({'x','average'})
%   The returned fid as at 2 or 3 dimensions (x, averages, all over
%   dimensions collapsed).
%   Manipulate fid, e.g. discard some averages:
%   > fid(:,2:end,:) = []
%   Write back the changed fid using then get_data:
%   > ALFONSO.set_data(fid, {'x','average'})
%
%   See also ALFONSO/get_data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 7, 2018
%
% Revisions:    0.1 (Sep 7, 2018)
%                   Initial version.
%               0.1.1 (May 08, 2020)
%                   Handle initial setting of data correctly.
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

if nargin < 3 % same as all
    
    error('Functions requires data and dim as input arguments!')
    
elseif nargin == 3
    
    if ~isempty(this.quant)
        warning('There are already quantifications available that are linked to the data that gets now overwritten.')
    end
    
    if ischar( dim )
        dim = {dim};
    end
    
    if ~iscell( dim )
        error('dim needs to be a cell array of strings')
    end
    
    % check if this.dims & this.data are empty 
    %   -> if so: initial setting of data -> dims_tmp is passed dim
    if isempty( this.dims ) && isempty( this.data )
        dims_tmp = dim;
    else
        dims_tmp = this.dims;
    end
    
    order = []; % dimension order
    len_count = length( this.dims_siz ); % dimension count
    
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
    
    if (length(dim) + 1) < length(order)
        
        % extend dims array
        dims_siz_tmp = ones(1,length(order));
        orderidx = order(order <= length(this.dims_siz));
        dims_siz_tmp(order <= length(this.dims_siz)) = this.dims_siz(orderidx);
        
        % update changed dimension sizes
        for iD = 1:length(dim)
            di = find( strcmp(this.dims, dim{iD}) );
            if ~isempty(di) % update existing dim size
                if size(data,iD) ~= size(this.data,di)
                    dims_siz_tmp(iD) = size(data,iD);
                end
            else % add new dim size
                dims_siz_tmp(iD) = size(data,iD);
                dims_tmp{order(iD)} = dim{iD};
            end
        end
        
        data = reshape(data, dims_siz_tmp); 
    end
    
    % workaround in case data has dimensions X x 1:
    if length(order) == 1
        order(2) = 2;
    end
    
    data = ipermute( data, order );
    
    this.data = data;
    this.dims = dims_tmp;
    this.squeeze_data_dim;
    
end
end