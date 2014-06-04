function [out] = CAMERA_Retiga(qimaging_options)
% [out] = CAMERA_Retiga(qimaging_options) has one input argument and one output
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
ROI = [0 0 1600 1200];
gain = 1;
capture_number_of_frames = 10;
daq_enabled = 0;
daq_handle = 0;
camera_pause = 0.5;

if nargin > 0
    if (ischar(qimaging_options) && strcmp(qimaging_options,'init'))
        qimaging_options = struct();
        qimaging_options.capture_mode = capture_mode;
        qimaging_options.number_of_frames = capture_number_of_frames;
        qimaging_options.exposure = exposure;
        qimaging_options.timeout = timeout;
        qimaging_options.ROI = ROI;
        qimaging_options.gain = gain;
        qimaging_options.camera_pause = camera_pause;
        
        out = qimaging_options;
        
        quickexit = 1; %just return this
    else %
        if (isfield(qimaging_options,'capture_mode'))
            if (qimaging_options.capture_mode >= 0)
                capture_mode = qimaging_options.capture_mode;
            end
        end
        if (isfield(qimaging_options,'number_of_frames'))
            if (qimaging_options.number_of_frames > 0)
                capture_number_of_frames = qimaging_options.number_of_frames;
            end
        end
        if (isfield(qimaging_options,'exposure'))
            if (qimaging_options.exposure > 0)
                exposure = qimaging_options.exposure;
            end
        end
        if (isfield(qimaging_options,'timeout'))
            if (qimaging_options.timeout >= 0)
                timeout = qimaging_options.timeout;
            end
        end
        if (isfield(qimaging_options,'ROI'))
            if (qimaging_options.ROI >= 0)
                ROI = qimaging_options.ROI;
            end
        end
        if (isfield(qimaging_options,'gain'))
            if (qimaging_options.gain >= 0)
                gain = qimaging_options.gain;
            end
        end
        if (isfield(qimaging_options,'camera_pause'))
            if (qimaging_options.camera_pause >= 0)
                camera_pause = qimaging_options.camera_pause;
            end
        end
        if (isfield(qimaging_options,'daq_handle'))
            if (isa(qimaging_options.daq_handle,'analoginput'))
                daq_enabled = 1;
                daq_handle = qimaging_options.daq_handle;
            end
        end
    end
end
if (quickexit == 0) %continue
    %% GET RETIGA CAMERA
    % this just lists the known formats from camera
    retiga_formats = {'MONO16_1600x1200','MONO16_200x150',...
        'MONO16_400x300','MONO16_800x600','MONO8_1600x1200',...
        'MONO8_200x150','MONO8_400x300','MONO8_800x600',...
        'RGB16_1600x1200','RGB16_200x150','RGB16_400x300',...
        'RGB16_800x600','RGB8_1600x1200','RGB8_200x150',...
        'RGB8_400x300','RGB8_800x600'};
    if(capture_mode==0)
        vid_obj=videoinput('qimaging',1,retiga_formats{5});
    else
        vid_obj = videoinput('qimaging',1,retiga_formats{1});
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
    
    image_size = get(vid_obj,'ROIPosition');
%     mem_size = (capture_number_of_frames*image_size(3)*image_size(4)) ...
%         *(numberofbytespersample*mem_engineering_margin);
%     imaqmem(mem_size); %resize memory for
    
    %% CAPTURE OR PREVIEW
%     data_pd = 1; % clear photodiode vars
    data = zeros(image_size(4),image_size(3)); %clear data vars
    data_temp = [];
    data_pd = [];
    
    if (capture_mode > 0) %capture mode
        triggerconfig(vid_obj, 'Manual')
        iterations = ceil(capture_number_of_frames/max_frames_per_iteration);
%         mem_size = (capture_number_of_frames/iterations*image_size(3)*image_size(4)) ...
%             *(numberofbytespersample*mem_engineering_margin);
%         imaqmem(mem_size); %resize memory for
        
        for i = 1:iterations
            clear data_temp;
            frames_taken = min([(capture_number_of_frames-((i-1)*max_frames_per_iteration)) max_frames_per_iteration]);
            set(vid_obj,'FramesPerTrigger',frames_taken);
            start(vid_obj);
%             pause(0.5);
            trigger(vid_obj);
            if (daq_enabled > 0)
                trigger(daq_handle);
%                 pause(camera_pause);
                data_pd_temp = getdata(daq_handle);
                data_pd(end + 1) = mean(data_pd_temp);
            else
%                 pause(camera_pause);
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
        set(f,'Name','Retiga Preview');
        himage = imagesc(getsnapshot(vid_obj));
        preview(vid_obj,himage);
    end
    
end %quick exit end


