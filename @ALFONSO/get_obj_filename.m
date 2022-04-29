function objfilename = get_obj_filename( this )
%GET_OBJ_FILENAME returns the default filename used for storing the object
%   objfilename = ALFONSO.get_obj_filename()
%
%   The default filename has the following format: 
%       TIMESTEP_ALFONSO_rawfilename.mat
%   where the TIMESTEMP has the format yyyymmdd_HHMMSS. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 30, 2020
%
% Revisions:    0.1 (Mar 30, 2020)
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

[~, objfilename ] = fileparts(this.scanparam.filename);
objfilename = [datestr(now, 'yyyymmdd_HHMMSS') '_ALFONSO_' objfilename '.mat' ];

end
