function [data data_ref] = DATASET_renormalize(data_raw,data,instr)
%DATASET_renormalize - Renormalizes data by the mirror, reference region, and
%silicon correction. Data_raw is used.

%% Select mirror
fprintf('Select your mirror file\n')
[mirror_file,mirror_path]=uigetfile('*.mat','Mirror File');

if ischar(mirror_file)
    %% Load mirror
    load([mirror_path mirror_file]);
    
    %% Reset data to prenormalization values
    data = data_raw;
    
    %% Spatial normalization (mirror)
    [data] = NORMALIZE_Mirror(data,data_mir);
    
    %% Select reference region
    [data_ref] = SELECT_ReferenceRegion(data);
    
    %% Temporal normalization (reference region)
    [data] = NORMALIZE_ReferenceRegion(data,data_ref);
    
    %% Correction factor (Si Correction)
    [data] = NORMALIZE_SiCorrection(data,instr);
    
else
    fprintf('User has selected not to normalize data.\n');
    
end
end