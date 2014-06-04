function [out] = CAMERA_Rolera(options)
% [out] = CAMERA_Rolera(options) has one input argument and one output
% argument. If 'init' is the input arguments, then out will be a struct()
% contaning the default options. After modifying those options, resuppling
% the options as the input allows one to control the camera and collect
% data

%% FUNCTION VARS
quickexit = 0;
numberofbytespersample = 8; % size of double
mem_engineering_margin = 1.5; % use a number greater than one
max_frames_per_iteration = 10; %timeout if more than twenty

%% SETUP OUTPUTS
out = struct();
out.data = [];

%% SETUP CAMERA OPTIONS from INPUT
capture_mode = 0; % 0 is preview , 1 is frame capture
exposure = 0.02;
timeout = 1000;
ROI = [0 0 696 520];
gain = 1;
capture_number_of_frames = 10;
daq_enabled = 0;
daq_handle = 0;

if nargin > 0
    if (ischar(options) && strcmp(options,'init'))
        options = struct();
        options.capture_mode = capture_mode;
        options.number_of_frames = capture_number_of_frames;
        options.exposure = exposure;
        options.timeout = timeout;
        options.ROI = ROI;
        options.gain = gain;
        options.bitdepth = 12;
        
        out = options;
        quickexit = 1; %just return this
    else %
        if (isfield(options,'capture_mode'))
            if (options.capture_mode >= 0)
                capture_mode = options.capture_mode;
            end
        end
        if (isfield(options,'number_of_frames'))
            if (options.number_of_frames > 0)
                capture_number_of_frames = options.number_of_frames;
            end
        end
        if (isfield(options,'exposure'))
            if (options.exposure > 0)
                exposure = options.exposure;
            end
        end
        if (isfield(options,'timeout'))
            if (options.timeout >= 0)
                timeout = options.timeout;
            end
        end
        if (isfield(options,'ROI'))
            if (options.ROI >= 0)
                ROI = options.ROI;
            end
        end
        if (isfield(options,'gain'))
            if (options.gain >= 0)
                gain = options.gain;
            end
        end
        if (isfield(options,'daq_handle'))
            if (isa(options.daq_handle,'analoginput'))
                daq_enabled = 1;
                daq_handle = options.daq_handle;
            end
        end
    end
end
if (quickexit == 0) %continue
    %% GET ROLERA CAMERA
    % This is the list of the known camera formats
    image_formats = {'MONO16_696x520','MONO16_348x260',...
        'MONO16_174x130','MONO16_87x65','MONO8_696x520',...
        'MONO8_348x260','MONO8_174x130','MONO8_87x65',...
        'BAY16_696X520','BAY8_696x520'};
    
    cameraList = imaqhwinfo('qimaging'); % Figure out which camera is the retiga
    for i = 1:size(cameraList.DeviceInfo,2)
        if strcmpi(cameraList.DeviceInfo(i).DeviceName,'Rolera-XR')
            camera_num = i;
            break;
        end
    end
    
    if(capture_mode==0)
        vid_obj=videoinput('qimaging',camera_num,image_formats{5});
    else
        vid_obj = videoinput('qimaging',camera_num,image_formats{1});
    end
    src_obj = getselectedsource(vid_obj);
    flushdata(vid_obj,'all');
    
    %% SETUP CAMERA FOR IRIS MEASURMENTS    
    %Turn on cooling
    try
        if(~strcmp(get(getselectedsource(vid_obj),'Cooling'),'on'))
            set(getselectedsource(vid_obj),'Cooling','on');
        end
    catch
    end
    
    %Set exposure
    set(src_obj,'Exposure',exposure);
    
    %Set Gain
    set(src_obj,'NormalizedGain',gain);
    
    %Set number of frames per triggering of camera
    set(vid_obj,'FramesPerTrigger',capture_number_of_frames);
    
    %Set ROI
    set(vid_obj,'ROIPosition',ROI);
    
    %Set dataset time out variable
    set(vid_obj,'Timeout',timeout);
    
    
    %% CAPTURE OR PREVIEW
    data = zeros(ROI(4),ROI(3)); %clear data vars
    data_temp = [];
    data_pd = [];
    
    if (capture_mode > 0) %capture mode
        triggerconfig(vid_obj, 'Manual')
        iterations = ceil(capture_number_of_frames/max_frames_per_iteration);
        
        for i = 1:iterations
            clear data_temp;
            frames_taken = min([(capture_number_of_frames-((i-1)*max_frames_per_iteration)) max_frames_per_iteration]);
            set(vid_obj,'FramesPerTrigger',frames_taken);
            start(vid_obj);
            trigger(vid_obj);
            if (daq_enabled > 0)
                trigger(daq_handle);
                data_pd_temp = getdata(daq_handle);
                data_pd(end + 1) = mean(data_pd_temp);
            else
                data_pd = 1;
            end
            temp = getdata(vid_obj,frames_taken);
            data_temp(:,:,:) = temp(:,:,1,:); %remove extra dimension
            data = data + sum(data_temp,3)/capture_number_of_frames; %average data
        end
                
        out.data = data;
        out.data_pd = mean(data_pd);        
        
        delete(vid_obj); % Remove video input object from memory.
    else %preview mode
        closepreview;
        f = figure;
        set(f,'Name','Rolera Preview');
        himage = imagesc(getsnapshot(vid_obj));
        preview(vid_obj,himage);
    end
    
end %quick exit end


