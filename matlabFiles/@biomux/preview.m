function preview(p)
%Overloaded preview function
camera = get(p,'camera');
exposure = get(p,'exposure');
num_frames = get(p,'numFrames');

if ~strcmpi(camera,'NikonD7000')
    closepreview;
    pause(1);
end

cameraStr = (['CAMERA_' camera]);
cameraFunc = str2func(cameraStr);

%Setup camera parameters
settings = cameraFunc('init');
settings.capture_mode = 0;
settings.exposure = exposure;
settings.number_of_frames = num_frames;
settings.timeout = 1000;

%Camera specific settings
if(strcmpi(camera,'NikonD7000'))   
    %Indicate the LED for color channel extraction
    wavelength = get(p,'wavelength');
    settings.LED = wavelength; % Must include wavelength when capturing images
else
    camera_gain = get(p,'cameraGain');
    ROI = get(p,'ROI');
    settings.gain = camera_gain;
    settings.ROI = ROI;
end

%Turn on preview
cameraFunc(settings);