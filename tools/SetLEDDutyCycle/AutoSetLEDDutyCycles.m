function [exposure,LED_dutyCycle] = AutoSetLEDDutyCycles(COMinfo, camera, LEDs, relativeLED, exp, ROI)
%AutoSetLEDDutyCycles(COMinfo,camera,LEDs,relativeLED, exp, ROI)
%
% Automatically determines the LEDs duty cycle.
% The relative LED is turned on, the duty cycle of the LED starts at 20%
% and increases until the median value of the histogram is 70% of the full
% capacity.
%
% If 70% full capacity is not achieved by 100% duty cycle, the exposure
% time is incremented and the algorithm repeats.
%
% Once the exposure is found for the relative LED, the duty cycle for
% the other LEDs is determined for 70% full capacity.
%
% Variables:
%   COMinfo - struct of the LED communication. Run CAMERA_[camera]('init')
%   Camera - String identifier for the camera (e.g. Grasshopper3)
%   LEDs - Cell of strings containing the LED identifiers
%   relativeLED - string identifier of the calibration LED
%   exp - a numeric array containing [start step stop] exposures
%   ROI - an array [left top width height] to determine the analyzed area

%Variables
maxDC = 255;
initDC = floor(maxDC.*0.2);
stepDC = 5;
startExp = exp(1)/1000;
stepExp = exp(2)/1000; %ms
stopExp = exp(3)/1000;
pBitdepth = 70;  % [%] target percentage of the bitdepth

%Get bitdepth
cd('..\..\matlabFiles');
cameraStr = (['CAMERA_' camera]);
cameraFunc = str2func(cameraStr);
settings = cameraFunc('init');
cd('..\tools\SetLEDDutyCycle')

full_capacity = 2^settings.bitdepth;


%Determine the exposure time for the calibration LED
dutyCycle = initDC - stepDC;
exposure = startExp;
thresh = floor(full_capacity * pBitdepth/100);
stopFlag = 1;

disp(['Target capacity: ' num2str(thresh)]);

while stopFlag
    if(dutyCycle > maxDC)
        %If 100% duty cycle isn't good enough, reset and increment exposure
        dutyCycle = initDC;
        exposure = exposure + stepExp;
    else
        %Increment dutyCycle
        dutyCycle = dutyCycle + stepDC;
    end
    
    %Set the duty cycle
    SetLEDDutyCycle(COMinfo,relativeLED,dutyCycle);
    
    %Snap an image
    data = GrabImage(camera, exposure, ROI);
    
    if (max(max(data)) ~= 0)
        %Determine median capacity
        cap = median(reshape(data,1,size(data,1)*size(data,2)),2);
        disp(['Median capacity: ' num2str(cap)]);
        
        %If the median capacity is over the threshold, stop
        if((cap >= thresh)||(exposure>=stopExp))
            stopFlag = 0;
        end
    else 
       disp('No image acquired! Check camera connection and repeat.');
       error('Camera Not Connected');
    end
end
    
disp(['Exposure is: ' num2str(exposure)]);
disp(['LED duty is: ' num2str(dutyCycle)]);

LED_dutyCycle = zeros(size(LEDs));

%Cycle through every LED to determine the right duty cycle for this
%exposure
for i = 1:size(LEDs,2)
    dutyCycle = initDC - stepDC;
    stopFlag = 1;

    while stopFlag
        if(dutyCycle >= maxDC)
            %Cannot exceed 100% duty cycle
            dutyCycle = maxDC;
        else
            %Increment dutyCycle
            dutyCycle = dutyCycle + stepDC;
        end
        
        %Set the duty cycle
        SetLEDDutyCycle(COMinfo,LEDs{i},dutyCycle);
    
        %Snap an image
        data = GrabImage(camera, exposure, ROI);
        
        %Determine current median capacity
        cap = median(reshape(data,1,size(data,1)*size(data,2)),2);
        disp(['Median capacity: ' num2str(cap)]);
        
        %If the median capacity is over the threshold, stop
        if ((cap >= thresh) || dutyCycle == maxDC)
            stopFlag = 0;
            LED_dutyCycle(i) = dutyCycle;
        end
    end
end

% disp(['Exposure is: ' num2str(exposure)]);
% disp(['LEDs duty are: ' num2str(LED_dutyCycle)]);
end