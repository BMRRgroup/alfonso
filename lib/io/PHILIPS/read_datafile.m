function [ sRawComplex, sNoise, dataInfo ] = read_datafile( dataFile )
%READ_DATAFILE reads spectroscopy data from PHILIPS *.data file.
%   [ complexData, noiseData ] = readdatafile( filename ) imports
%   raw data from filename as complex data array and additional noise
%   data array. To do so, some informations about the data need to be
%   passed which can be grabbed using readlistfile(). 


dataInfo = read_listfile( dataFile );

fidData = fopen(dataFile);

% initialize arrays
sNoise = zeros( dataInfo.noiseSize / 4, dataInfo.nCoils );
sRaw = zeros( 2 * dataInfo.nReadoutPoints, dataInfo.nCoils, dataInfo.nSignalAverages, dataInfo.nExtraAttribute1 );

% read noise data
for inch=1:dataInfo.nCoils
     sNoise(1:dataInfo.noiseSize/4, inch)=fread(fidData,dataInfo.noiseSize/4,'float32');
end

% read data
for iDyn = 1:dataInfo.nExtraAttribute1 % this is a hack at the moment and should be dynamically be read from the list file
    for inex=1:dataInfo.nSignalAverages
        for ich=1:dataInfo.nCoils
            sRaw(1:2*dataInfo.nReadoutPoints,ich,inex,iDyn) = fread(fidData,2*dataInfo.nReadoutPoints,'float32');
        end
    end
end
fclose(fidData);

sRawComplex = sRaw(1:2:2*dataInfo.nReadoutPoints,:,:,:) + 1j*sRaw(2:2:2*dataInfo.nReadoutPoints,:,:,:);

end

