function obj_exists = exists_obj( this, path )
%EXISTIS_OBJ returns information about the existance of an obj file
%   obj_exists = exists_obj( ) checks if object existis in current 
%       path. 
%   obj_exists = exists_obj( dest ) checks if object existis in path. 
%
%   Returns: 
%       obj_exists: 
%           false - if not existing
%           FILENAME - if a single file candidate exists
%           <number of of candidates> - if multiple file canidates exist
%
%   See also ALFONSO/save_obj, ALFONSO/load_obj
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 26, 2020
%
% Revisions:    0.1 (Mar 26, 2020)
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

if nargin < 2
    path = '.';
end

% get acquisition related part of the filename
[~, objfilename ] = fileparts(this.scanparam.filename);

% find all canditates 
obj_cand = rdir([path filesep '*' objfilename '.mat']);

if length(obj_cand) == 1
    [~, obj_exists ] = fileparts(obj_cand.name);
    obj_exists = [obj_exists '.mat'];
    % ensure once more that the file exists
    if ~ exist([path filesep obj_exists],'file')
        obj_exists = false;
    end
elseif ~isempty(obj_cand)
    obj_exists = length(obj_cand);
else
    obj_exists = false;
end

end
