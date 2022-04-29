function [ listFileInfo ] = read_listfile( filename )
%READ_LISTFILE extracts information from the PHILIPS *.list file.

[ PATHSTR, FILENAME ] = fileparts(filename);

listFileContent = fileread( [PATHSTR filesep FILENAME '.list'] );

% number of mixes
expr = '(?<=number_of_mixes\s*:\s*)\d*';
listFileInfo.nMixes = str2double(regexp(listFileContent, expr, 'match', 'once'));

% number_of_encoding_dimensions
expr = '(?<=number_of_encoding_dimensions\s*:\s*)\d*';
listFileInfo.nEncodingDimensions = str2double(regexp(listFileContent, expr, 'match', 'once'));

% number_of_dynamic_scans
expr = '(?<=number_of_dynamic_scans\s*:\s*)\d*';
listFileInfo.nDynamicScans = str2double(regexp(listFileContent, expr, 'match', 'once'));

% number_of_cardiac_phases
expr = '(?<=number_of_cardiac_phases\s*:\s*)\d*';
listFileInfo.nCardiacPhases = str2double(regexp(listFileContent, expr, 'match', 'once'));

% number_of_echoes 
expr = '(?<=number_of_echoes\s*:\s*)\d*';
listFileInfo.nEchos = str2double(regexp(listFileContent, expr, 'match', 'once'));

% number_of_locations
expr = '(?<=number_of_locations\s*:\s*)\d*';
listFileInfo.nLocations = str2double(regexp(listFileContent, expr, 'match', 'once'));

%nExtraAttribute 1
expr = '(?<=number_of_extra_attribute_1_values\s*:\s*)\d*';
listFileInfo.nExtraAttribute1 = str2double(regexp(listFileContent, expr, 'match', 'once'));

%nExtraAttribute 2
expr = '(?<=number_of_extra_attribute_2_values\s*:\s*)\d*';
listFileInfo.nExtraAttribute2 = str2double(regexp(listFileContent, expr, 'match', 'once'));

%nSignalAverages
expr = '(?<=number_of_signal_averages\s*:\s*)\d*';
listFileInfo.nSignalAverages = str2double(regexp(listFileContent, expr, 'match', 'once'));

% %number of coil channels
% expr = '(?<=number of coil channels\s*:\s*)\d*';
% listFileInfo.nCoils = str2double(regexp(listFileContent, expr, 'match', 'once'));
%
% the info on the number of coil channels is unfortunately not always
% supplied as "number of coil channels" (e.g. spectroscopy), therefore the 
% readout is done by counting the number of NOI data, which seems to be 
% more robust
expr = 'NOI';
listFileInfo.nCoils = length(regexp(listFileContent, expr, 'match'))-2;

%nReadoutPoints
expr = '(?<=t_range\s*:\s*)\d*';
readoutStart = regexp(listFileContent, expr, 'match', 'once');
expr = '(?<=t_range\s*:\s*\d\s*)\d*';
readoutEnd = regexp(listFileContent, expr, 'match', 'once');
listFileInfo.nReadoutPoints = str2double(readoutEnd) - str2double(readoutStart) + 1;

%noiseSize
expr = '(?<=NOI     0     0     0     0     0     0     0     0     0     0     0     0     \d     0     0     0     0     0\s*)\d*(?=\s*0)';
listFileInfo.noiseSize = str2double(regexp(listFileContent, expr, 'match', 'once'));

end

