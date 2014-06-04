function p=biomux(varargin)
%p=biomux_obj=biomux();
%p=biomux_obj=biomux(biomux);
%p=biomux_obj=biomux(PD dev, LED dev, Camera, Instrument);
%
%Biomux contructor.  Instantiates a biomux object.
%0 inputs: Returns biomux object without hardware communication
%1 input:  The object passed in is returned (e.g. p=biomux(p))
%4 inputs: p=biomux(PD,LED,camera,instr)
% 
% PD - Device # for the DAQ card of the photodetector
%
% LED - Device # for addressing the light source
%
% Camera - Name of the imaging device (string)
%
% Instrument - Instrument name for 
% 
%Typical for LED System: 
%   p=biomux_obj=biomux('Dev2','Dev1','Nikon','IRIS1');
%
%Notes:
% v5 was written on  4/29/14 by Alex Reddington
%  Laser control was removed (See v4 or earlier for laser controls)
%  Overhauled for modularity

%Switch according to number of inputs
switch nargin  
    case 1
        %This case is requested by MATLAB protocol
        %It may be used as a check that an item
        %is an object of a particular class
        if (isa(varargin{1},'biomux')), %asking "is this a biomux object?"
            p = varargin{1}; %if so, return it
        else
            error('Wrong argument type'), %otherise produce an error
        end;
        
    case {0, 4}
        if(nargin==0),
            %%
            %0 inputs means no hardware will be used
            arg1='none';
            arg2='none';
            arg3='none';
            arg4='none';
        else
            %%
            %4 inputs for initializing hardware
            arg1=varargin{1}; %PD dev
            arg2=varargin{2}; %LED dev
            arg3=varargin{3}; %Camera name
            arg4=varargin{4}; %Instrument name
        end;
        
        %%
        
        %Public (external) Variables
        p.dataFile='BiomuxDataFile';
        p.mirrorFile='';
        p.exposure=1/30;
        p.cameraGain=1;
        p.numFrames=10;
        p.ROI=[0 0 500 500];
        p.MaxWidth = 500;
        p.MaxHeight = 500;
        p.refRegion=[1 1 1 1]; %default reference region [x y w h];
        
        p.wavelength=455;
        p.startWav=400;
        p.stepWav=1;
        p.stopWav=800;
        p.wavList=p.startWav:p.stepWav:p.stopWav; %actual list of wavelengths used
        p.timerObj = timer; %timer for super sweep
        
        %Software Flags 
        p.FlagRef = 0; %Reference Region
        p.FlagMir = 0; %Mirror Norm
        p.FlagPD = 0;
        p.FlagLED = 0;
        p.FlagCamera = 0;
        
        %Hardware Device #s
        p.PD = 0; %ID for photodetector device
        p.LED = 0; %ID for LED device
        p.camera = 0; %Camera name
        p.instr = 0; 
        
        %Private (internal) variables
        p.PDSampleRate=10000; %Sampling frequency on daq for photodetector
        p.PDSampleNum=ceil(p.exposure*ceil(0.1*p.numFrames)*p.PDSampleRate); %Number of samples on daq for photodetector
        p.duration=max([p.PDSampleNum/p.PDSampleRate 0.033*ceil(0.1*p.numFrames) p.exposure*ceil(0.1*p.numFrames)]); %time to wait for measurement
        p.superSweepPause=5;
        p.timeStamp=zeros(1000,1); %time stamps is a list of data sets taken using time stamps as ID
        p.scansTaken=0; %this will be the same as the length of the p.time_stamps (# of data sets)
        
        %Define class
        p=class(p,'biomux');  
       
        %% INITIALIZE HARDWARE
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% arg1 - Initialize device for Analog Input (Photodiode)      %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (isa(arg1,'char')),
            if strcmpi(arg1,'none'),
                %Disable PD
                p.PD = 'none';
                p.FlagPD = 0;
                disp('No PD device');
                
            elseif strcmpi(arg1(1:3),'Dev')
                %Store input in PD
                p.PD = arg3;
                p.FlagPD = 1;
                disp(['PD device: '  arg3]);
                
            else
                p.PD = 'none';
                p.FlagPD = 0;
                error(['Improper PD device: '  arg3]);
                
            end
        else
            p.PD = 'none';
            p.FlagPD = 0;
            error('First input must be char string, e.g. Dev1');
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% arg2 - Initialize device for light source (LED)             %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (isa(arg2,'char')),
            if strcmpi(arg2,'none'),
                p.LED = 'none';
                p.FlagLED = 0;
                
                disp('No Light Source');
                
            elseif sum(strcmpi(arg2(1:3),{'NGA','USB','COM'}))
                p.FlagLED = 1;
                p.wavelength=455;
                p.wavList=[455 518 598 635];
                
                %Init Commands - Default LED 1 on
                if sum(strcmpi(arg2,{'NGA','USB'}))
                    [p.LED] = LEDS_INIT_ARDUINO();
                else
                    [p.LED] = LEDS_INIT_ARDUINO(arg2);
                end
                
                disp(['Light Source: ' arg2]);
                
            elseif strcmpi(arg2(1:3),'Dev')
                p.FlagLED = 1;
                p.wavelength=455;
                p.wavList=[455 518 598 635];
                
                %Init Commands - Default LED 1 on
                if sum(strcmpi(arg2,{'NGA','USB'}))
                    [p.LED] = LEDS_INIT_DAQ();
                else
                    [p.LED] = LEDS_INIT_DAQ(arg2);
                end
                
                disp(['Light Source: ' arg2]);

            else
                p.LED = 'none';
                p.FlagLED = 0;
                error(['Incorrect Light Source: ' arg2]);
            end
        else %Inputs are numbers, so use as address for Laser (SRIB System)
            p.LED = 'none';
            p.FlagLED = 0;
            error('Second input must be char string, e.g. Dev1');
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% arg3 - Initialize camera                                    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (isa(arg3,'char')),
            switch upper(arg3)
                case 'NONE'
                    p.FlagCamera = 0;
                    p.camera = 'none';
                    p.ROI = [0 0 0 0];
                    
                    disp(['Camera: ' p.camera]);
                case {'RETIGA','RETIGA2000R','RETIGA-2000R'}
                    p.FlagCamera = 1;
                    p.camera = 'Retiga2000R';
                    p.ROI = [ 0 0 1600 1200];
                    
                    disp(['Camera: ' p.camera]);
                case {'GRASSHOPPER'}
                    p.FlagCamera = 1;
                    p.camera = 'Grasshopper';
                    p.ROI = [ 0 0 1384 1036];
                    
                    disp(['Camera: ' p.camera]);
                case {'GRASSHOPPER3','GRASSHOPPER 3','GRASSHOPPER3_SMALL','GRASSHOPPER3 SMALL','GS3-U3-41C6M-C'}
                    p.FlagCamera = 1;
                    p.camera = 'Grasshopper3_Fast';
                    p.ROI = [ 0 0 1920 1200];
                    
                    disp(['Camera: ' p.camera]);
                case {'GRASSHOPPER3_BIG','GRASSHOPPER3 BIG','GS3-U3-23S6M-C'}
                    p.FlagCamera = 1;
                    p.camera = 'Grasshopper3_Fast';
                    p.ROI = [ 0 0 2048 2048];
                    
                    disp(['Camera: ' p.camera]);
                case {'RETIGA4000R','RETIGA-4000R'}
                    p.FlagCamera = 1;
                    p.camera = 'Retiga4000R';
                    p.ROI = [ 0 0 2048 2048];
                    
                    disp(['Camera: ' p.camera]);
                case {'ROLERA','ROLERA-XR'}
                    p.FlagCamera = 1;
                    p.camera = 'Rolera';
                    p.ROI = [0 0 696 520];
                    
                    disp(['Camera: ' p.camera]);
                case 'MARLIN'
                    p.FlagCamera = 1;
                    p.camera = 'Marlin';
                    p.ROI = [0 0 0 0];
                    
                    disp(['Camera: ' p.camera]);
                case {'NIKOND7000','NIKON D7000','NIKON-D7000','NIKON'}
                    p.FlagCamera = 1;
                    p.camera = 'NikonD7000';
                    p.ROI = [0 0 4948 3280];
                    
                    disp(['Camera: ' p.camera]);
                case {'PROSILICA','PROSILICA-GT4905','PROSILICA GT4905'}
                    p.FlagCamera = 1;
                    p.camera = 'Prosilica';
                    p.ROI = [0 0 4896 3264];
                    
                    disp(['Camera: ' p.camera]);
                otherwise
                    p.FlagCamera = 0;
                    p.camera = 'none';
                    p.ROI = [0 0 0 0];
                    
                    error('Third input is not a recognized camera');
            end
            p.MaxWidth = p.ROI(3);
            p.MaxHeight = p.ROI(4);
            
            %Turn off camera color gain warnings
            warning('off','imaq:qimaging:propHealed');
        else
            p.FlagCamera = 0;
            p.camera = 'none';
            
            error('Third input must be char string, e.g. Retiga');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% arg4 - Initialize instrument                                %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if (isa(arg4,'char')),
            p.instr = arg4;
            disp(['Instrument: ' p.instr]);
        else
            p.instr = 0;
            error('Fourth input must be char string, e.g. IRIS1');
        end
        
        %% Initialize timer object for super sweep
        set(p.timerObj,'BusyMode','queue','ExecutionMode','fixedSpacing');
        set(p.timerObj,'StartDelay',3,'Period',p.superSweepPause);
        set(p.timerObj,'TimerFcn', {@drive_super_sweep,p}); %call drive_super_sweep(p) every timer cycle
 
        %% SET HARDWARE (take defaults and call set())
%         set(p,'wavelength',p.wavelength);
%         set(p,'exposure',p.exposure);
%         set(p,'cameraGain',p.cameraGain);
%         set(p,'numFrames',p.numFrames);
%         set(p,'ROI',p.ROI);
%         set(p,'refRegion',p.refRegion);
        
    otherwise
        error('Wrong number of input arguments')
end;