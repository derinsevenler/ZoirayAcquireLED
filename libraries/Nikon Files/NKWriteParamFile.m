function NKWriteParamFile(options)
% NKWriteFile(options)
%Write the Nikon_Params text file. All parameters should be the index
% Inputs: options - struct containing parameter fields and values
%
% Outputs:
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

fid = fopen(file, 'wt');

if isnumeric(options.shootingSpeed) %ShootingSpeed
    shootingSpeed = num2str(options.shootingSpeed);
elseif ischar(options.shootingSpeed)
    shootingSpeed = options.shootingSpeed;
else
    shootingSpeed = '0';
end

if isnumeric(options.number_of_frames)%ContinuousShootingNum
    number_of_frames = num2str(options.number_of_frames);
elseif ischar(options.number_of_frames)
    number_of_frames = options.number_of_frames;
else
    number_of_frames = '10';
end

if isnumeric(options.imageFormat)%CompressionLevel
    imageFormat = num2str(options.imageFormat);
elseif ischar(options.imageFormat)
    imageFormat = options.imageFormat;
else
    imageFormat = '3';
end

if isnumeric(options.exposure)%ShutterSpeed
    exposure = num2str(options.exposure);
elseif ischar(options.exposure)
    exposure = options.exposure;
else
    exposure = '39'; %1/160
end

if isnumeric(options.bitdepth)%CompressRAWBitMode
    bitdepth = num2str(options.bitdepth);
elseif ischar(options.bitdepth)
    bitdepth = options.bitdepth;
else
    bitdepth = '1';
end

if isnumeric(options.aperture)%Aperture
    aperture = num2str(options.aperture);
elseif ischar(options.aperture)
    aperture = options.aperture;
else
    aperture = '19';
end

if isnumeric(options.sensitivity)%Sensitivity
    sensitivity = num2str(options.sensitivity);
elseif ischar(options.sensitivity)
    sensitivity = options.sensitivity;
else
    sensitivity = '0';
end
    
parameters = {'ShootingSpeed';'ContinuousShootingNum';'CompressionLevel';...
    'ShutterSpeed';'CompressRAWBitMode';'Aperture';'Sensitivity'};

values = {shootingSpeed; number_of_frames; imageFormat;...
    exposure; bitdepth; aperture; sensitivity};

count = 0;
for i=1:size(parameters,1),
%     fwrite(fid,[parameters{i} ' ' values{i}]);
    count = count+1;
    str{count} = parameters{i};
    count = count+1;
    str{count} = values{i};
end

formatSpec = '%s %s\n';
[nrows,ncols] = size(str);
for col = 1:2:ncols
    fprintf(fid,formatSpec,str{:,col:col+1});
end

fclose(fid);
%cd ..
end