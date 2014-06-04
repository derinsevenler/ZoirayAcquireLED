function [options] = NKReadParamFile()
% [options] = NKReadFile()
%Reads in the Nikon_Params text file. If the file doesn't exist, it writes
%one with the default values.
%
% Inputs:
%
% Outputs: options - struct containing parameter fields and values
%
% Default Values:
%    ShootingSpeed = 0 = ContinuousHighSpeed
%    ContinuousShootingNum 10 = 10
%    CompressionLevel 3 = RAW
%    ShutterSpeed = 39 = 1/160s
%    CompressRAWBitMode 1 = 14-bit
%    Aperture 19 = 32
%    Sensitivity 0 = 100
%
%Tested on 4/25/2014 - Pass

file = 'Nikon_Params.txt';

if ~(exist(file)==2)
    fid = fopen(file, 'w+');
    fclose(fid);
end

fid = fopen(file, 'r');
data = textscan(fid, '%s');  %reads into cell array
fclose(fid);

%If the file is empty, load default values and rewrite the text file
writeFlag = 0;
if isempty(data{1})
    writeFlag = 1;
    parsedString = {'ShootingSpeed','0',...
        'ContinuousShootingNum','10',...
        'CompressionLevel','3',...
        'ShutterSpeed','39',...
        'CompressRAWBitMode','1',...
        'Aperture','19',...
        'Sensitivity','0'};
else
    parsedString = data{1};
end

index = find(strcmpi(parsedString,'ShootingSpeed'));
options.shootingSpeed = str2double(parsedString{index+1});

index = find(strcmpi(parsedString,'ContinuousShootingNum'));
options.number_of_frames = str2double(parsedString{index+1});

index = find(strcmpi(parsedString,'CompressionLevel'));
options.imageFormat = parsedString{index+1};

index = find(strcmpi(parsedString,'ShutterSpeed'));
options.exposure = parsedString{index+1};

index = find(strcmpi(parsedString,'CompressRAWBitMode'));
options.bitdepth = parsedString{index+1};

index = find(strcmpi(parsedString,'Aperture'));
options.aperture = str2double(parsedString{index+1});

index = find(strcmpi(parsedString,'Sensitivity'));
options.sensitivity = str2double(parsedString{index+1});

if writeFlag
    NKWriteFile(options);
end