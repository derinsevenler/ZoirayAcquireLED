function data = GrabImage(camera,exposure, ROI)
%GrabImage(exposure, ROI)
%
% Snaps and returns an image

cd('..\..\matlabFiles');

cameraStr = (['CAMERA_' camera]);
cameraFunc = str2func(cameraStr);

%Setup camera parameters
settings = cameraFunc('init');
settings.capture_mode = 1;
settings.exposure = exposure;
settings.number_of_frames = 5;
settings.timeout = 1000;
settings.gain = 1;
settings.ROI = ROI;

%Camera specific settings
if strcmpi(camera,'NikonD7000')
    %Indicate the LED for color channel extraction
    wavelength = get(p,'wavelength');
    settings.LED = wavelength; % Must include wavelength when capturing images
end

%Acquire data
output = cameraFunc(settings);
data = output.data;

cd('..\tools\SetLEDDutyCycle');