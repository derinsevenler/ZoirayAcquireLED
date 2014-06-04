function output=take_frame(p,varargin)
% function frame=take_frame(b_obj);
% b_obj.num_frames frames are aquired, averaged, and returned
% as a single frame.  The frame is also displayed in true contrast.

camera = get(p,'camera');
exposure = get(p,'exposure');
num_frames = get(p,'numFrames');

if ~strcmpi(camera,'NikonD7000')
    closepreview;
end

disp('Acquiring frame')
cameraStr = (['CAMERA_' camera]);
cameraFunc = str2func(cameraStr);

%Setup camera parameters
settings = cameraFunc('init');
settings.capture_mode = 1;
settings.exposure = exposure;
settings.number_of_frames = num_frames;
settings.timeout = 1000;
settings.gain = get(p,'cameraGain');
settings.ROI = get(p,'ROI');

%Camera specific settings
if strcmpi(camera,'NikonD7000')
    %Indicate the LED for color channel extraction
    wavelength = get(p,'wavelength');
    settings.LED = wavelength; % Must include wavelength when capturing images
end

%Acquire data
output = cameraFunc(settings);

if(nargin==2)
    if(strcmp(varargin(1),'hist'))
        %Extract bitdepth for normalization
        if strcmpi(camera,'NikonD7000')
            bitdepth = 16;
        else
            bitdepth = settings.bitdepth; % Change to num
        end
        
        %Normalize data between 0 and 1
        data = output.data./(2.^bitdepth);
        show(data,'hist');
        title('Histogram: Normalized to percent full');
    end
else
    show(output.data,2);
end
disp('Acquisition complete')