function biomux=set(biomux, varargin)
%function val=get(biomux_obj, 'PropName',value,'PropName',value, ...)
%Set one or more properties of a biomux object

%get inputs
property_arg_in=varargin;

%Keep evaluating inputs in pairs ('PropName','PropValue')
while length(property_arg_in) >= 2,
    %Grab next property name and value and remove them from list
    property = property_arg_in{1};
    val = property_arg_in{2};
    property_arg_in = property_arg_in(3:end);
    
    %Set the property
    switch lower(property)
        case 'datafile'
            biomux.dataFile = val;    
            
        case 'mirrorfile'
            biomux.mirrorFile = val;
            
        case 'wavelength'
            if biomux.FlagLED
                if (val >= get(biomux,'startWav') && val<=get(biomux,'stopWav')) || (val == 0)
                    biomux.wavelength = val;
                    LEDinfo = get(biomux,'LEDInfo');
                    switch(upper(LEDinfo.communicationType))
                        case 'GPIB' %Using Laser
                            disp([LEDinfo.communicationType ' is not implemented']);
                        case 'DAQ' %Using DAQ
                            if isnumeric(val)
                                wavList = get(biomux,'wavList');
                                commands = {LEDinfo.commands.led1 LEDinfo.commands.led2...
                                    LEDinfo.commands.led3 LEDinfo.commands.led4};
                                for i = 1:size(wavList,2)
                                    if val==wavList(i)
                                        val = commands{i};
                                        break;
                                    end
                                end
                            end
                            LEDS_CONTROL_DAQ(LEDinfo,val);
                        case 'SERIAL'
                            if isnumeric(val)
                                wavList = get(biomux,'wavList');
                                LEDS_CONTROL_ARDUINO(LEDinfo,LEDinfo.commands.leds_off);
                                commands = {LEDinfo.commands.led1 LEDinfo.commands.led2...
                                    LEDinfo.commands.led3 LEDinfo.commands.led4};
                                if val == 0
                                    val = LEDinfo.commands.leds_off;
                                else
                                    for i = 1:size(wavList,2)
                                        if val==wavList(i)
                                            val = commands{i};
                                            pCycle = [40,60,100,55]; %Duty cycle percent
                                            dutyCycle = round(255*pCycle(i)/100); %Determine cycle #
                                            sendCommand = [LEDinfo.commands.duty_cycle num2str(dutyCycle)];
                                            LEDS_CONTROL_ARDUINO(LEDinfo,sendCommand);
                                            break;
                                        end
                                    end
                                end
                            end
                            
                            LEDS_CONTROL_ARDUINO(LEDinfo,val);
                    end
                else
                    error('Wavelength out of range and unchanged.');
                end
            else
                warning('Wavelength unchanged. LEDs are disabled.');
            end
            
        case 'startwav'
            if isnumeric(val)
                val = double(val);
                if(val<get(biomux,'stopWav') || val<=0)
                    warning(['Wavelength unchanged, must be more than: '...
                        num2str(get(biomux,'stopWav')) ' and 0']);
                else
                    biomux.startWav=val;
                    biomux=set(biomux,'wavList',biomux.startWav:get(biomux,'stepWav'):get(biomux,'stopWav'));
                end
            else
                error('startWav must be an integer');
            end
            
        case 'stepwav'
            if isnumeric(val)
                val=double(val);
                range = get(biomux,'stopWav') - get(biomux,'startWav');
                if(val>range || val<=0),
                    warning(['Wavelength unchanged, must be less than: '...
                        num2str(range)]);
                else
                    biomux.stepWav=val;
                    biomux=set(biomux,'wavList',get(biomux,'startWav'):biomux.stepWav:get(biomux,'stopWav'));
                end
            else
                error('stepWav must be an integer');
            end
            
        case 'stopwav'
            if isnumeric(val)
                val=double(val);
                if(val<get(biomux,'startWav') || val<=0),
                    warning(['Wavelength unchanged, must be greater than: '...
                        num2str(get(biomux,'startWav')) ' and 0']);
                else
                    biomux.stopWav=val;
                    biomux=set(biomux,'wavList',get(biomux,'startWav'):get(biomux,'stepWav'):biomux.stopWav);
                end
            else
                error('stopWav must be an integer');
            end
            
        case 'wavlist'
            if isnumeric(val)
                val=double(val);
                flag = (val>=0 & val>=get(biomux,'startWav') & val<=get(biomux,'stopWav'));
                if(sum(flag)~=length(flag))
                    warning(['All wavelengths must be within range: '...
                        num2str(get(biomux,'startWav')) '-' num2str(get(biomux,'stopWav'))]);
                else
                    biomux.wavList=val;
                end
            else
                error('wavList must be an integer');
            end
            
        case 'exposure'
            if isnumeric(val)
                val = double(val);
                if val>0
                    if strcmpi(get(biomux,'camera'),'NikonD7000')    
                        %Determine the closest discrete Nikon exposure to
                        %val and return it
                        cd('..\libraries\Nikon Files\');
                        [val] = NKParameterLUT(val,'exposure','value','value');
                        cd('..\..\matlabFiles\');
                    end
                    
                    %Update camera value
                    biomux.exposure=val;
                    
                    %Update daq measurement time as well
                    biomux = set(biomux,'PDSampleNum',1); %1 is a dummy variable
                    biomux = set(biomux,'Duration',1); %1 is a dummy variable
                else
                    warning('Exposure must be > 0');
                end
            else
                error('Exposure must be an integer');
            end
            
        case 'pdsamplenum'
            %Update daq measurement time as well
            numFrames = get(biomux,'numFrames');
            exposure = get(biomux,'exposure');
            PDSampleRate = get(biomux,'PDSampleRate');
            
            switch numFrames
                case {1,2,3,4,5,6,7,8,9}
                    if get(biomux,'FlagPD')
                        biomux.PDSampleNum=ceil(exposure*numFrames*PDSampleRate); %number of samples on daq for photodetector
                    else
                        biomux.PDSampleNum=ceil(exposure*numFrames*PDSampleRate); %number of samples on daq for photodetector
                    end
                otherwise
                    if get(biomux,'FlagPD')
                        biomux.PDSampleNum=ceil(exposure*ceil(0.1*numFrames)*PDSampleRate); %number of samples on daq for photodetector
                    else
                        biomux.PDSampleNum=ceil(exposure*numFrames*PDSampleRate); %number of samples on daq for photodetector
                    end
            end
            
        case 'duration'
            %Update daq measurement time as well
            exposure = get(biomux,'exposure');
            numFrames = get(biomux,'numFrames');
            PDSampleRate = get(biomux,'PDSampleRate');
            PDSampleNum = get(biomux,'PDSampleNum');
            
            switch numFrames
                case {1,2,3,4,5,6,7,8,9}
                    if get(biomux,'FlagPD')
                        biomux.duration=max([PDSampleNum/PDSampleRate 0.1*numFrames exposure*numFrames]); %time to wait for measurement
                    else
                        biomux.duration=max([0.1*numFrames exposure*numFrames]); %time to wait for measurement
                    end
                otherwise
                    if biomux.FlagPD
                        biomux.duration=max([PDSampleNum/PDSampleRate 0.033*ceil(0.1*numFrames) exposure*ceil(0.1*numFrames)]); %time to wait for measurement
                    else
                        biomux.duration=max([0.01*numFrames exposure*numFrames]); %time to wait for measurement
                    end
            end
            
        case 'cameragain'
            if isnumeric(val)
                val=double(val);
                if(val>0 && val<=45)
                    biomux.cameraGain=val;
                else
                    warning(['Camera Gain must be value within range: 1-45']);
                end
            else
                error('Camera Gain must be an integer');
            end
            
        case 'numframes'
            if isnumeric(val)
                val=double(val);
                if(val>=1 && val<500)
                    biomux.numFrames=val;
                    
                    %Update daq measurement time as well
                    biomux = set(biomux,'PDSampleNum',1); %1 is a dummy variable
                    biomux = set(biomux,'Duration',1); %1 is a dummy variable
                else
                    warning(['numFrames must be value within range: 1-500']);
                end
            else
                error('numFrames must be an integer');
            end
            
        case 'roi'
            if isnumeric(val)
                val=round(val);
                if val==0,
                    val=[0 0 500 500]; %default case [x y w h]
                end;
                if length(val)==4
                    biomux = set(biomux,'XOffset',val(1));
                    biomux = set(biomux,'YOffset',val(2));
                    biomux = set(biomux,'Width',val(3));
                    biomux = set(biomux,'Height',val(4));
                else
                    warning('ROI is unchanged, must be four integers')
                end
            else
                error('ROI must be an integer');
            end
            
        case 'xoffset'
            if isnumeric(val)
                MaxW = get(biomux,'MaxWidth');
                Width = get(biomux,'Width');
                
                if (val(1)+Width)<=MaxW
                    biomux.ROI(1)=val;
                else
                    warning(['XOffset is unchanged. Max limit: ' num2str(MaxW-Width)]);
                end
            else
                error('XOffset must be an integer');
            end
            
        case 'yoffset'
            if isnumeric(val)
                MaxH = get(biomux,'MaxHeight');
                Height = get(biomux,'Height');
                
                if (val+Height)<=MaxH
                    biomux.ROI(2)=val;
                else
                    warning(['YOffset is unchanged. Max limit: ' num2str(MaxH-Height)]);
                end
            else
                error('YOffset must be an integer');
            end
            
        case 'width'
            if isnumeric(val)
                MaxW = get(biomux,'MaxWidth');
                XOffset = get(biomux,'XOffset');
                
                if (XOffset+val)<=MaxW
                    biomux.ROI(3)=val;
                else
                    warning(['Width is unchanged. Max limit: ' num2str(MaxW)]);
                end
            else
                error('Width must be an integer');
            end
            
        case 'height'
            if isnumeric(val)
                MaxH = get(biomux,'MaxHeight');
                YOffset = get(biomux,'YOffset');
                
                if (YOffset+val)<=MaxH
                    biomux.ROI(4)=val;
                else
                    warning(['Height is unchanged. Max limit: ' num2str(MaxH)]);
                end
            else
                error('Height must be an integer');
            end
            
        case 'maxheight'
            if isnumeric(val)
                biomux.MaxHeight=val;
            else
                error('MaxHeight must be an integer');
            end
            
        case 'maxwidth'
            if isnumeric(val)
                p.MaxWidth=val;
            else
                error('MaxWidth must be an integer');
            end
            
        case 'refregion'
            if isnumeric(val)
                val=round(val);
                if val==0,
                    val=[1 1 1 1]; %[x y w h]
                end;
                if length(val)==4,
                    biomux.refRegion=val;
                else
                    warning('refRegion unchanged, must be four integers')
                end
            else
                error('refRegion must be an integer');
            end
            
        case 'flagref' %Reference Region Flag
            if isnumeric(val)
                if(val==0),
                    biomux.FlagRef=0;
                elseif(val==1),
                    if get(biomux,'FlagMir')
                        biomux.FlagRef=1;
                    else
                        biomux.FlagRef=0;
                        error('Mirror normalization must be enabled before reference region');
                    end
                else
                    warning('FlagRef unchanged, must be 0 or 1');
                end
            else
                error('FlagRef must be an integer');
            end
            
        case 'flagmir' %Mirror Flag
            if isnumeric(val)
                if(val==0),
                    biomux.FlagMir=0;
                elseif(val==1),
                    if(exist(get(biomux,'mirrorFile'),'file')~=2),
                        biomux.FlagMir=0;
                        warning([get(biomux,'mirrorFile') '- file does not exist, FlagMir set to 0.']);
                    else
                        biomux.FlagMir=1;
                    end;
                else
                    warning('FlagMir unchanged, must be 0 or 1');
                end
            else
                error('FlagMir must be an integer');
            end
            
        case 'flagpd' %Photodetector Flag
            if isnumeric(val)
                if(val==0),
                    biomux.FlagPD=0;
                elseif(val==1),
                    if ~strcmpi(get(biomux,'PD'),'none')
                        biomux.FlagPD=1;
                    else
                        biomux.FlagPD=0;
                        warning('FlagPD set to 0. No PD is set')
                    end;
                else
                    warning('FlagPD unchanged, must be 0 or 1');
                end
            else
                error('FlagPD must be an integer');
            end
            
        case 'flagled' %Photodetector Flag
            if isnumeric(val)
                if(val==0),
                    biomux.FlagLED=0;
                elseif(val==1),
                    if ~strcmpi(get(biomux,'LEDInfo'),'none')
                        biomux.FlagLED=1;
                    else
                        biomux.FlagLED=0;
                        warning('FlagLED set to 0. No LED is set')
                    end;
                else
                    warning('FlagLED unchanged, must be 0 or 1');
                end
            else
                error('FlagLED must be an integer');
            end
            
        case 'flagcamera' %Photodetector Flag
            if isnumeric(val)
                if(val==0),
                    biomux.FlagCamera=0;
                elseif(val==1),
                    if ~strcmpi(get(biomux,'Camera'),'none')
                        biomux.FlagCamera=1;
                    else
                        biomux.FlagCamera=0;
                        warning('FlagCamera set to 0. No Camera is set')
                    end;
                else
                    warning('FlagCamera unchanged, must be 0 or 1');
                end
            else
                error('FlagCamera must be an integer');
            end
            
        case 'supersweeppause'
            if isnumeric(val)
                val =abs(double(val));
                biomux.superSweepPause=val;
                biomux = set(biomux,'timerObj',1);%1 is a dummy variable
            else
                error('Sweep Pause must be an integer');
            end
            
        case 'timerobj'
            set(biomux.timerObj,'BusyMode','queue','ExecutionMode','fixedSpacing');
            set(biomux.timerObj,'StartDelay',3,'Period',get(biomux,'superSweepPause'));
            set(biomux.timerObj,'TimerFcn', {@drive_super_sweep,biomux}); %call drive_super_sweep(p) every timer cycle
            
        case 'camera'
            if (isa(val,'char')),
                switch upper(val)
                    case 'NONE'
                        biomux = set(biomux,'FlagCamera',0);
                        biomux.camera = 'none';
                        biomux = set(biomux,'ROI', [0 0 0 0]);
                        biomux = set(biomux,'MaxWidth',0);
                        biomux = set(biomux,'MaxHeight',0);
                        warning('Camera not set');
                        
                    case {'RETIGA','RETIGA2000R','RETIGA-2000R'}
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'Retiga2000R';
                        biomux = set(biomux,'ROI', [0 0 1600 1200]);
                        biomux = set(biomux,'MaxWidth',1600);
                        biomux = set(biomux,'MaxHeight',1200);
                        
                    case 'GRASSHOPPER'
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'Grasshopper';
                        biomux = set(biomux,'ROI', [0 0 1384 1036]);
                        biomux = set(biomux,'MaxWidth',1384);
                        biomux = set(biomux,'MaxHeight',1036);
                        
                    case {'GRASSHOPPER3','GRASSHOPPER 3','GRASSHOPPER3_SMALL','GRASSHOPPER3 SMALL','GS3-U3-41C6M-C'}
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'Grasshopper3_Fast';
                        biomux = set(biomux,'ROI', [0 0 1920 1200]);
                        biomux = set(biomux,'MaxWidth',1920);
                        biomux = set(biomux,'MaxHeight',1200);
                        
                    case {'GRASSHOPPER3_BIG','GRASSHOPPER3 BIG','GS3-U3-23S6M-C'}
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'Grasshopper3_Fast';
                        biomux = set(biomux,'ROI', [0 0 2048 2048]);
                        biomux = set(biomux,'MaxWidth',2048);
                        biomux = set(biomux,'MaxHeight',2048);
                        
                    case {'RETIGA4000R','RETIGA-4000R'}
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'Retiga4000R';
                        biomux = set(biomux,'ROI', [0 0 2048 2048]);
                        biomux = set(biomux,'MaxWidth',2048);
                        biomux = set(biomux,'MaxHeight',2048);

                    case {'ROLERA','ROLERA-XR'}
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'Rolera';
                        biomux = set(biomux,'ROI', [0 0 696 520]);
                        biomux = set(biomux,'MaxWidth',696);
                        biomux = set(biomux,'MaxHeight',520);
                        
                    case 'MARLIN'
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'Marlin';
                        biomux = set(biomux,'ROI', [0 0 0 0]);
                        biomux = set(biomux,'MaxWidth',0);
                        biomux = set(biomux,'MaxHeight',0);

                    case {'NIKOND7000','NIKON D7000','NIKON-D7000','NIKON'}
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'NikonD7000';
                        biomux = set(biomux,'ROI', [0 0 4928 3264]);
                        biomux = set(biomux,'MaxWidth',4928);
                        biomux = set(biomux,'MaxHeight',3264);
                        
                    case {'PROSILICA','PROSILICA-GT4905','PROSILICA GT4905'}
                        biomux = set(biomux,'FlagCamera',1);
                        biomux.camera = 'Prosilica';
                        biomux = set(biomux,'ROI', [0 0 4896 3264]);
                        biomux = set(biomux,'MaxWidth',4896);
                        biomux = set(biomux,'MaxHeight',3264);
                        
                    otherwise
                        error('Camera not recognized');
                end
                %Turn off camera color gain warnings
                warning('off','imaq:qimaging:propHealed');
                
            else
                error('Camera must be an string');
            end
        case 'scanstaken'
            if isnumeric(val)
                biomux.scansTaken = val;
            else
                error('ScansTaken must be an integer');
            end
            
        otherwise
            error([property,' is not a valid Biomux property']);
    end;        
end;