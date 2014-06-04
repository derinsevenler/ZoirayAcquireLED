function [param]=LOAD_InstrumentParams(instr,fields)
% [param]=load_instr_params(instr,fields)
% Inputs: instr - Instrument's name (String)
%         fields - Parameters to be returned (String or cell array)
%
% Outputs: param - Parameter values found (double)
cd '..\libraries\Fitting Files'
file = ['Info_' instr '.txt'];

if exist(file,'file')==2
    fid = fopen(file, 'r');
    data = textscan(fid, '%s');  %reads into cell array
    fclose(fid);
    
    if find(strcmpi(fields,'spectrum_size'))
        match = strcmpi('spectrum_size',data{1}); %Determine if the field is in the text file
        match_ind = find(match)+1; %Grab index of match and increment to data
        param.spectrum_size = str2double(data{1}(match_ind));
    end
    
    if find(strcmpi(fields,'theta_size'))
        match = strcmpi('theta_size',data{1}); %Determine if the field is in the text file
        match_ind = find(match)+1; %Grab index of match and increment to data
        param.theta_size = str2double(data{1}(match_ind));
    end
    
    if find(strcmpi(fields,'SiCorrection'))
        match = strcmpi('SiCorrection',data{1}); %Determine if the field is in the text file
        match_ind = find(match)+1; %Grab index of match and increment to data
        param.SiCorrection = str2double(data{1}(match_ind:match_ind+3));
    end
else
    disp(['Info file ' file ' does not exist in ' pwd]);
    disp('No parameters loaded. Error will occur.')
    
end
cd('..\..\matlabFiles\');