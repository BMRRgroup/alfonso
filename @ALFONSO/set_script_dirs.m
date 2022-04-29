function set_script_dirs( this )
%SET_SCRIPT_DIRS sets reconparam.script
%   ALFONSO.set_script_dirs() tries to automatically set reconparam.script.
%   Usually this method is automatically called and does not need to be
%   manually called. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 17, 2020
%
% Revisions: 	0.1 (Mar 17, 2020)
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

this.reconparam.script.directory = mfilename('fullpath');
this.reconparam.script.modeldir = [fileparts(fileparts(this.reconparam.script.directory)) filesep 'models' filesep];

end
