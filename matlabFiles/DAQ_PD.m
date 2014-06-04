function [out] = DAQ_PD(PD_options)
% [out] = CAMERA_GrassHopper(grass_options) has one input argument and one output
% argument. If 'init' is the input arguments, then out will be a struct()
% contaning the default options. After modifying those options, resuppling
% the options as the input allows one to control the camera and collect
% data
%%%%%%%%%%%%%%%%%%%%%%%NOT FINISHED
%% FUNCTION VARS
quickexit = 0;

%% SETUP OUTPUTS
out = struct();
out.data = [];

%% SETUP CAMERA OPTIONS from INPUT
if nargin > 0
    if (ischar(grass_options) && strcmp(grass_options,'init'))
        grass_options = struct();
        grass_options.capture_mode = capture_mode;
        grass_options.number_of_frames = capture_number_of_frames;
        grass_options.exposure = exposure;
        grass_options.save_raw_integer_data = save_raw_integer_data;
        grass_options.daq_handle = 0;
        out = grass_options;
        quickexit = 1; %just return this
    else %
        if (isfield(grass_options,'capture_mode'))
            if (grass_options.capture_mode >= 0)
                capture_mode = grass_options.capture_mode;
            end
        end
        if (isfield(grass_options,'number_of_frames'))
            if (grass_options.number_of_frames > 0)
                capture_number_of_frames = grass_options.number_of_frames;
            end
        end
        if (isfield(options,'exposure'))
            if (options.exposure > 0)
                exposure = options.exposure;
            end
        end
        if (isfield(options,'sample_number'))
            if (options.sample_number >= 0)
                sample_number = options.sample_number;
            end
        end
        if (isfield(options,'sample_rate'))
            if (options.sample_rate >= 0)
                sample_rate = options.sample_rate;
            end
        end
    end
end
if (quickexit == 0) %continue
    %% GET GRASSHOPPER CAMERA
    daq_obj = analoginput('nidaq',p.PD);
    addchannel(daq_obj,0);
    
    %% SETUP PD FOR IRIS MEASURMENTS
    
    set(daq_obj,'SampleRate',sample_rate,'SamplesPerTrigger',sample_number);
    set(daq_obj,'InputType','Differential');
    set(daq_obj,'TriggerType','Manual');
    set(daq_obj,'TriggerRepeat',10*length(p.wav_list));
    
    %% CAPTURE OR PREVIEW
    start(daq_obj); %note: start once and trigger many

end %quick exit end

