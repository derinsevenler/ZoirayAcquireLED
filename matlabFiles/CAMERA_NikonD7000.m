function [out] = CAMERA_NikonD7000(options)
%[out] = CAMERA_NikonD7000(options)
%  Loads the options into the Nikon
%    Preview: capture_mode = 0
%    Acquire Images: capture_mode = 1
%
%[options] = CAMERA_NikonD7000('init')
%  If 'init' is the input arguments, then out will be a struct()
%
%Tested on 5/1/2014

%% FUNCTION VARS
quickexit = 0;

%% SETUP OUTPUTS
out = struct();
out.data = [];

%% SETUP CAMERA OPTIONS from INPUT
capture_mode = 0; % 0 is preview , 1 is frame capture
LED = 'Blue';
ROI = [0 0 500 500];
maxWidth = 4928;
maxHeight = 3264;
gain = 1; % // multiplier


if nargin > 0
    cd '..\libraries\Nikon Files';
    if (ischar(options) && strcmp(options,'init'))
        %Load values
        [options] = NKReadParamFile();
        options.capture_mode = capture_mode;
        options.LED = LED;
        options.ROI = ROI;
        options.gain = gain;
        
        %Convert indices to values
        [options.exposure] = NKParameterLUT(options.exposure,'EXPOSURE','index','value');
        
        out = options;
        quickexit = 1; %just return this 
    else
        if (isfield(options,'ROI'))
            if ((options.ROI(1) >= 0) && (options.ROI(2) >= 0) &&...
                (options.ROI(1)+options.ROI(3)<=maxWidth) &&...
                (options.ROI(2)+options.ROI(4)<=maxHeight))
                ROI = options.ROI;
            else
                ROI = [0 0 maxWidth maxHeight];
            end
            
            left = ROI(1);
            width = ROI(3);
            top = ROI(2);
            height = ROI(4);
        end
        if(isfield(options,'gain'))
            if(gain>0)
                gain = options.gain;
            else
                gain = 1;
            end
        end
    end
    
    if (quickexit == 0) %continue
        %% SETUP CAMERA FOR IRIS MEASURMENTS
        
        if ~(getParameterValue('LockExposure')) %Check that LockExposure has been set
            display(['Exposure is not locked. Place and focus on the mirror slide.'....
                ' Next, press the AE button on the camera to Lock Exposure.'])
        else
            
            %Convert values to indices for writing
            [options.exposure] = NKParameterLUT(options.exposure,'EXPOSURE','value','index');
        
            %Write value to text files
            NKWriteParamFile(options); %Exposure should be written as the index
                        
            %Load the text files
            loadParameters();
            
            %% CAPTURE OR PREVIEW
            if (options.capture_mode > 0) %capture mode
                LED = getLED(options.LED);
                captureImage(options.number_of_frames, LED, 'Temp')
                data = NKExtractData('Temp', LED);
                out.data = data(top+1:top+height,left+1:left+width).*gain;% index starts with 1
                out.data_pd = 1;
                
                %TESTED
            else %preview mode
                previewImage();
            end
            
        end
    end
    cd('..\..\matlabFiles\');
end
end

function temp = getParameterValue(parameter)
%temp = getParameterValue(parameter)
%
% Queries the Nikon D7000 for the value of a parameter
if isValidString(parameter)
    functionFile = 'NKParameters.exe';
    systemCommand = [functionFile ' ' parameter];
    response = sendCommand(systemCommand);
    if strcmpi(response(1:4),'true')
        temp = 1;
    else
        temp = 0;
    end 
end
end

function loadParameters()
%setParameters()
%
% Invokes NKParameters.exe with no arguments.
% This method loads Nikon_Params.txt into the camera

functionFile = 'NKParameters.exe -Load';
sendCommand(functionFile);
end

function previewImage()
%previewImage()
%
% Turns on or off preview
systemCommand = 'NKLiveView.exe';
sendCommand(systemCommand);
end

function captureImage(numImages, LED, rootName)
%captureImage(numImages, LED, rootName)
%
% Captures multiple images
% Files will be saved in [rootName][LED][number].NEF format

if numImages > 0
    functionFile = 'NKCaptureImage.exe';
    systemCommand = [functionFile ' ' num2str(numImages) ' ' LED ' ' rootName];
    sendCommand(systemCommand);
else
    display('Cannot capture images. Number of images is negative.');
end
end

function flag = isValidString(parameter)
%flag = isValidParameter(parameter)
%
% Checks if a parameter is a valid option

strOptions = {'EVInterval','CompressionLevel','LockExposure',...
    'ShutterSpeed','Aperture','Sensitivity','WBMode','AEAFLockButton',...
    'ShootingSpeed','ShootingLimit','SensitivityInterval',...
    'IsoControl','NoiseReduction','ExposureDelay',...
    'ContinuousShootingNum','NoiseReductionHighISO','CompressRAWBitMode',...
    'PictureControl','ShootingLimit'};

flag = ~isempty(find(strcmpi(parameter,strOptions),1));
end

function response = sendCommand(systemCommand)
[nothing response] = system(systemCommand);
end

function LED = getLED(wavelength)
if isnumeric(wavelength)
    if wavelength <= 500
        LED = 'Blue';
    elseif wavelength <= 550
        LED = 'Green';
    elseif wavelength <= 600
        LED = 'Yellow';
    else
        LED = 'Red';
    end
else
    switch upper(wavelength)
        case {'L1','BLUE','LED1'}
            LED = 'Blue';
        case {'L2','GREEN','LED2'}
            LED = 'Green';
        case {'L3','YELLOW','AMBER','LED3'}
            LED = 'Yellow';
        case {'L4','RED','LED4'}
            LED = 'Red';
    end
end
end

function paramStr = extractString(value,strOptions,indexOptions)
%systemValue = extractString(value,strOptions,indexOptions)
% This function extracts the string corresponding with value
% 
% Value can be a string or integer
% strOptions is a cell of strings
% indexOptions is an array of integers
%
% systemValue is returned with a string for setting the parameter or -1 if
% value was invalid

if isnumeric(value)
    paramStr = int2str(indexOptions(indexOptions == value));
else
    switch value
        case strOptions
            paramStr = int2str(find(strcmpi(value,strOptions))-1); %-1 since cs indices start at 0
        otherwise
            paramStr = -1;
    end
end
end