function RUN_SetDutyCycle(varargin)
%RUN_SetDutyCycle(varargin)
%
% Constructs:
%  RUN_SetDutyCycle(COM_Port)
%    e.g RUN_SetDutyCycle('COM5');
%
%  RUN_SetDutyCycle(COM_Port, Camera)
%    e.g RUN_SetDutyCycle('COM5','Grasshopper3');
%
%  RUN_SetDutyCycle(COM_Port, Camera, LEDs)
%    e.g RUN_SetDutyCycle('COM5','Grasshopper3',{'Blue','Green'});
%
%  RUN_SetDutyCycle(COM_Port, Camera, LEDs, weak led)
%    e.g RUN_SetDutyCycle('COM5','Grasshopper3',{'Blue','Green'},'Green');
%
%  RUN_SetDutyCycle(COM_Port, Camera, LEDs, weak led, [start step stop] exposure)
%    e.g RUN_SetDutyCycle('COM5','Grasshopper3',{'Blue','Green'},'Green', 1);
%
%  RUN_SetDutyCycle(COM_Port, Camera, LEDs, weak led, [start step stop] exposure, ROI)
%    e.g RUN_SetDutyCycle('COM5','Grasshopper3',{'Blue','Green'},'Green', 1, [0 0 500 500]);


port_cfg = 'COM5';
camera = 'Grasshopper3';
LEDs = {'Blue','Green','Yellow','Red'};
weakLED = 'Yellow';
expStart= 0.000001; %ms
expStep = 0.000001;
expStop = 0.00001;
ROI = [0 0 500 500];
p = pwd;

switch nargin
    case 1
        if ischar(varargin{1})
            port_cfg = varargin{1};
        end
    case 2
        if ischar(varargin{1})
            port_cfg = varargin{1};
        end
        if ischar(varargin{2})
            camera = varargin{2};
        end
    case 3
        if ischar(varargin{1})
            port_cfg = varargin{1};
        end
        if ischar(varargin{2})
            camera = varargin{2};
        end
        if iscellstr(varargin{3})
            LEDs = varargin{3};
        end
    case 4
        if ischar(varargin{1})
            port_cfg = varargin{1};
        end
        if ischar(varargin{2})
            camera = varargin{2};
        end
        if iscellstr(varargin{3})
            LEDs = varargin{3};
        end
        if ischar(varargin{4})
            weakLED = varargin{4};
        end
    case 5
        if ischar(varargin{1})
            port_cfg = varargin{1};
        end
        if ischar(varargin{2})
            camera = varargin{2};
        end
        if iscellstr(varargin{3})
            LEDs = varargin{3};
        end
        if ischar(varargin{4})
            weakLED = varargin{4};
        end
        if isnumeric(varargin{5})
            exp = varargin{5}./1000;
            switch size(exp,2)
                case 1
                    expStart= exp(1);
                    expStep = expStart;
                    expStop = expStart*50;
                case 2
                    expStart= exp(1);
                    expStep = exp(2);
                    expStop = expStart*50;
                case 3
                    expStart= exp(1);
                    expStep = exp(2);
                    expStop = exp(3);
            end
        end
    case 6
        if ischar(varargin{1})
            port_cfg = varargin{1};
        end
        if ischar(varargin{2})
            camera = varargin{2};
        end
        if iscellstr(varargin{3})
            LEDs = varargin{3};
        end
        if ischar(varargin{4})
            weakLED = varargin{4};
        end
        if isnumeric(varargin{5})
            exp = varargin{5}./1000;
            switch size(exp,2)
                case 1
                    expStart= exp(1);
                    expStep = expStart;
                    expStop = expStart*50;
                case 2
                    expStart= exp(1);
                    expStep = exp(2);
                    expStop = expStart*50;
                case 3
                    expStart= exp(1);
                    expStep = exp(2);
                    expStop = exp(3);
            end
        end
        if isnumeric(varargin{6})
            if(size(varargin{6},2) == 2)
                ROI(1:2) = varargin{6};
            elseif(size(varargin{6},2) == 4)
                ROI = varargin{6};
            end
        end
end

%If it fails, disconnect and end
try
    %Connect to the LED controller
    cd('..\..\matlabFiles');
    [COMinfo] = LEDS_INIT_ARDUINO(port_cfg);
    cd('..\tools\SetLEDDutyCycle');
    
    %Run the auto-calibration algorithm
    [exposure,LED_dutyCycle] = AutoSetLEDDutyCycles(COMinfo, camera,...
        LEDs, weakLED, [expStart*1000 expStep*1000 expStop*1000], ROI);
    
    disp(['Exposure is: ' num2str(exposure)]);
    disp(['LEDs are: ' num2str(LED_dutyCycle)]);
    
    %Display the histograms for verification
    for i = size(LEDs,2)
        DisplayHist(camera,LEDs{i});
    end
catch
    cd(p);
    fclose(COMinfo.portnumber);
end