function squeeze_data_dim( this )
%SQUEEZE_DATA_DIM squeezes singular dims in data
%   ALFONSO.squeeze_data_dim()
%   See also ALFONSO/set_data, ALFONSO/get_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 7, 2018
%
% Revisions: 	1.0 (Sep 7, 2018)
%				Initial version.
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

% construct complete dims_siz
% (this ensures that singular dimensions at the end are treated correctly)
dims_siz = ones(length(this.dims),1);
dims_siz(1:numel(size(this.data))) = size(this.data);

red_dims = find(dims_siz == 1);

% handle exceptions when dims_size is actually a vector
red_dims(red_dims > length(this.dims)) = [];

this.dims(red_dims) = [];
this.data = squeeze(this.data);
this.dims_siz = size(this.data);

end