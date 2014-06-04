function handles=single_scan(p,handles,varargin)
%function b_obj=single_scan(b_obj)
%This function takes a single wavelenth scan
%b_obj=single_scan(b_obj) scans wavelengths and records data
%b_obj=single_scan(b_obj,'hist') will show histograms
%b_obj=single_scan(b_obj,'mirror') saves the mean of all pixels
%      at each wavelength using the mirror filename

iris_info.version = handles.version;
iris_info.instr = get(p,'Instrument');

camera = get(p,'camera');
wav_list = get(p,'wavList');
ROI = get(p,'ROI');
exposure = get(p,'exposure');
num_frames = get(p,'numFrames');

%Ensure preview is closed
if ~strcmpi(camera,'NikonD7000')
    closepreview;
    pause(1);
end

%Setup flags
daq_flag=get(p,'FlagPD'); %Is there a PD?
hist_flag=0; %Show histograms instead of images?
mir_flag=0; %Save mean of scan data to mirror file?
quick_exit=1;

if(nargin>=3)
    val=varargin{1};
    if (strcmp(val,'hist')),
        hist_flag=1;
    elseif (strcmp(val,'mirror')),
        mir_flag=1;
        data_mir=zeros(length(wav_list),ROI(4),ROI(3));
    else
        figure; %if this isn't a hist or mirror scan, show it in a big frame
    end;
end;

%initialize large variables
data=zeros(length(wav_list),ROI(4),ROI(3));
data_pd=ones(length(wav_list),1);
data_ref=zeros(length(wav_list),1);

%Connect to Daq card and setup parameters
if(daq_flag),
    PD = get(p,'PD');
    PDSampleRate = get(p,'PDSampleRate');
    PDSampleNum = get(p,'PDSampleNum');
    
    daq_obj = analoginput('nidaq',PD);
    addchannel(daq_obj,0);
    set(daq_obj,'SampleRate',PDSampleRate,'SamplesPerTrigger',PDSampleNum);
    set(daq_obj,'InputType','Differential');
    set(daq_obj,'TriggerType','Manual');
    set(daq_obj,'TriggerRepeat',10*length(wav_list));
    start(daq_obj); %note: start once and trigger many times
end;

cameraStr = (['CAMERA_' camera]);
cameraFunc = str2func(cameraStr);

%Setup camera parameters
settings = cameraFunc('init');
settings.capture_mode = 1;
settings.exposure = exposure;
settings.number_of_frames = num_frames;
settings.timeout = 1000;
if(daq_flag)
    settings.daq_handle = daq_obj; %enable daq acq of photodiode
end

%Camera specific settings
if strcmpi(camera,'NikonD7000')
    %Indicate the LED for color channel extraction
    wavelength = get(p,'wavelength');
    settings.LED = wavelength; % Must include wavelength when capturing images
else
    camera_gain = get(p,'cameraGain');
    settings.gain = camera_gain;
    settings.ROI = ROI;
end

%Main loop - step through each wavelength and record data
disp(['Starting sweep ' datestr(now)])
for n=1:length(wav_list),
    %Set wavelength
    p = set(p,'wavelength',wav_list(n));
    wavelength = get(p,'wavelength');
    disp(['Wavelength is ' num2str(wavelength)]);
    
    if strcmpi(camera,'NikonD7000')
        %Indicate the LED for color channel extraction
        wavelength = get(p,'wavelength');
        settings.LED = wavelength; % Must include wavelength when capturing images
    end
    output = cameraFunc(settings);
    
    axes(handles.axes1);
    if(hist_flag)
        quick_exit=0;
        
        %Extract bitdepth for normalization
        if strcmpi(camera,'NikonD7000')
            bitdepth = 16;
        else
            bitdepth = settings.bitdepth; % Change to num
        end
        
        %Normalize data between 0 and 1
        data = output.data./(2.^bitdepth);
        show(data,'hist');
        title('Histogram: Normalized to percent full','Color','w');
        set(handles.axes1,'XLim',[0 1],'XColor','w','YColor','w');
%         disp(['PD Voltage: ' num2str(output.data_pd)]);
    else
        data(n,:,:)=output.data;
        if ~isfield(output,'data_pd')
            data_pd(n)=1;
        else
            data_pd(n)=output.data_pd;
        end
        show(data(n,:,:),3);
        title(sprintf([datestr(now) ' Wavelength: ' num2str(wav_list(n))]),'Color','w');
    end
end

%Clean up after scan
data_date=datestr(now);
disp([data_date ' Wavelength scan complete '])
p = set(p,'wavelength',wav_list(1)); %go back to first wavelength
clear output initial;

%Stop DAQ
if(daq_flag), stop(daq_obj); delete(daq_obj); end; %free memory

%Save the information
if(quick_exit>0)
    FlagMir = get(p,'FlagMir');
    FlagRef = get(p,'FlagRef');
    dataFile = get(p,'dataFile');
    
    data_ref = ones(length(wav_list),1);
    data_raw = data;
    
    %Normalize by mirror scan (Optional)
    if (FlagMir && mir_flag),
        warning('FlagMir was set to 1 but ignored for current mirror scan');
    elseif FlagMir
        mirFile = get(p,'mirrorFile');
        if (exist(mirFile,'file')==2),
            load(mirFile);
            data=data./data_mir;
            disp('Data normalized pixel-by-pixel with mirror')
        else
            error(['Mirror file: ' mirFile ' not found']);
        end;
    end;
    
    %Normalize by Reference Region (Optional)
    if(FlagRef && ~mir_flag),
        reg = get(p,'refRegion');
        data_ref=mean(mean(data(:,reg(2):reg(2)+reg(4),reg(1):reg(1)+reg(3)),3),2);
        ref_temp = repmat(data_ref,[1 size(data,2) size(data,3)]);
        data=data./ref_temp;
        disp('Data normalized by reference region');
    end;
    
    %Save Data
    if(mir_flag),
        f_name=[dataFile 'Mirror' data_date(13:14) data_date(16:17) data_date(19:20)];
        data_wav_mir=wav_list;
        data_date_mir=data_date;
        data_mir=data;
        data_pd_mir=data_pd;
        save(f_name,'data_mir','data_pd_mir','data_wav_mir','data_date_mir','iris_info')
        p = set(p,'mirrorFile',[f_name '.mat']);
    else
        f_name=[dataFile 'DataSet' data_date(13:14) data_date(16:17) data_date(19:20)];
        data_wav=wav_list;
        save(f_name,'data','data_pd','data_wav','data_date','data_ref','data_raw','iris_info')
        p = set(p,'scansTaken',get(p,'scansTaken')+1);

        p.timeStamp(get(p,'scansTaken'))=datenum(data_date);
    end;
    disp(['saved: ' f_name]),
end
handles.biomux_obj = p;