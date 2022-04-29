function set_file( this, filename )
%SET_FILE correctly sets scanparam.filepathname and scanparam.filename
%   E.g. set_file( filename ) set the input filename. This can be a
%   ALFONSOobj file (.mat) or supported raw data file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	September 26, 2018
%
% Revisions: 	1.0 (Sep 26, 2018)
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

[PATHSTR, NAME, EXT] = fileparts( filename );

if strcmpi(EXT, '.mat') % assume that .mat including saved ALFONSOobj was passed
    this.load_obj(filename);
else
    this.scanparam.filepathname = [PATHSTR filesep];
    this.scanparam.filename = [NAME EXT];
end

end