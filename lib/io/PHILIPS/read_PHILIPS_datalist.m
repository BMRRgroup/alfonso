function [ data, info, noise ] = read_PHILIPS_datalist( dataFile )
%READ_PHILIPS_DATALIST reads MRS data from a .data / .list file pair
%   [ data, info, noise ] = read_PHILIPS_datalist( dataFile ) returns data,
%      info and noise information from the passed dataFile and 
%      corresponding list file. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Feb 25, 2019
%
% Revisions:    0.1 (Feb 25, 2019)
%					Initial version.
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

[ data, noise, info ] = read_datafile( dataFile );


end

