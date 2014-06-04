function DisplayHist(camera,LED)
%function DisplayHist()
%This function takes an image and displays the hist in a figure

%Get an image
data = GrabImage(camera,LED);

%Get the bitdepth
cd('..\..\matlabFiles');
cameraStr = (['CAMERA_' camera]);
cameraFunc = str2func(cameraStr);
settings = cameraFunc('init');
bitdepth = 2^settings.bitdepth;

%Normalize data between 0 and 1
data_norm = data./(2.^bitdepth);
figure;
show(data_norm,'hist');
title(['Histogram: ' LED]);

cd('..\tools\SetLEDDutyCycle')
end