function [paramStr] = NKParameterLUT(val,parameter,input_option,output_option)
%[paramStr] = NKExpValue(val,input_option,output_option)
%
% This function returns either the index or value of the Nikon parameter. 
% The index is needed to set the camera. The value is for the GUI.
%
% val (string|integer) - Value or Index to look-up
% parameter (string) - Capability being changed
% input_option (string) [value|index]- indicates the input is a value or index
% output_option (string) [value|index] - indicates if the output should be a value or index
%
% paramStr (string|integer) - returned index is string and value is integer

paramStr = '';

parameter_func = str2func(['options_' upper(parameter)]);

[indexOptions strOptions] = parameter_func();
counter = size(indexOptions,2)+1; %+1 for initial decrement

switch upper(input_option)
    case 'VALUE' %ONLY SHOULD BE USED FOR EXPOSURE AND OTHER NUMERIC PARAMETERS
        %Look up the closest discrete Nikon option
        if isnumeric(val) 
            %Do nothing
        else
            val = str2num(val);
        end
        searching = 1;
        while searching
            counter=counter-1; %indexing counter
            if val<=str2num(strOptions{counter})%Use str2num. str2double doesn't work with fractions like 1/1.3
                searching = 0;
                ind = counter;
            end
            if counter == 1
                ind = counter;
                searching = 0;
            end
        end
        
    case 'INDEX'
        %The val is the index. Use it to look up the strOption
        if isnumeric(val)
            %Do Nothing
        else
            val = str2num(val);
        end
        ind = find(val == indexOptions);
end

switch upper(output_option)
    case 'INDEX'
        paramStr = num2str(indexOptions(ind));
    case 'VALUE'
        paramStr = str2num(strOptions{ind}); %str2double is unable to convert odd fractions, e.g. 1/1.3
end
end

%% Index and string cells
%These values were manually collected by setting then reading a parameter,
%e.g. system('NKParameters.exe Aperture 1'); [nothing data] = system('NKParameters.exe Aperture')

function [indexOptions strOptions] = options_EXPOSURE() %aka ShutterSpeed
%Raw indices & strings
% indexOptions = 0:56;
% strOptions = {'x 1/250','1','2','3','4','5','6','10','8','6',...
%     '10','4','3','13','2','15','1.3','1','1/1.3','1/1.6',...
%     '20','1/2.5','1/3','1/4','1/5','25','1/8','1/10','1/13','1/15',...
%     '30','1/25','1/30','1/40','1/50','1/60','1/80','1/100','1/125','1/160',...
%     '1/200','1/250','1/320','1/400','1/500','1/640','1/800','1/1000','1/1250','1/1600',...
%     '1/2000','1/2500','1/3200','1/4000','1/5000','1/6400','1/8000'};

%Sorted highest to lowest...duplicates deleted
indexOptions = [30 25 20 15 13 7 8 6 5 4 3 2 ...
    16 17 18 19 21:24 26:29 31:56]; 
strOptions = {'30','25','20','15','13','10','8','6','5','4','3','2',...
    '1.3','1','1/1.3','1/1.6','1/2.5','1/3','1/4','1/5','1/8','1/10',...
    '1/13','1/15','1/25','1/30','1/40','1/50','1/60','1/80','1/100',...
    '1/125','1/160','1/200','1/250','1/320','1/400','1/500','1/640',...
    '1/800','1/1000','1/1250','1/1600','1/2000','1/2500','1/3200',...
    '1/4000','1/5000','1/6400','1/8000'};
end

function [indexOptions strOptions] = options_APERTURE()
%Raw indices & strings
% indexOptions = [0:23]; 
% strOptions = {'3.8','4.0','4.5','5','5.6','6.3','7.1','8','10','11','13',
%     '14','14','16','18','20','20','25','22','32','25','25','29'};

%Sorted highest to lowest...duplicates deleted
% indexOptions=[ 19 , 22 , 17 ,  18 ,  15 ,  14 ,  13 ,  11 ,  10 ,   9 ,...
%      8  ,  7 ,   6  ,   5  ,   4  ,  3 ,   2  ,  1 ,   0];
% strOptions = {'32','29','25', '22', '20', '18', '16', '14', '13', '11',...
%     '10', '8', '7.1', '6.3', '5.6', '5', '4.5', '4', '3.8'};

%%%%%%%%%% ODDITY! %%%%%%%%%%%
%Values have restricted themselves to <25
indexOptions=[ 17 ,  18 ,  15 ,  14 ,  13 ,  11 ,  10 ,   9 ,...
     8  ,  7 ,   6  ,   5  ,   4  ,  3 ,   2  ,  1 ,   0];
strOptions = {'25', '22', '20', '18', '16', '14', '13', '11',...
    '10', '8', '7.1', '6.3', '5.6', '5', '4.5', '4', '3.8'};
end

function [indexOptions strOptions] = options_SHOOTINGSPEED()
%Raw indices & strings
indexOptions = 0:4; 
strOptions = {'5 frames / second','4 frames / second','3 frames / second',...
     '2 frames / second','1 frame / second'};

end
function [indexOptions strOptions] = options_CONTINUOUSSHOOTINGNUM()
%Errors on values >100
%Values >15 are set to 15 by the camera
%15 may be the maximum....

%Raw indices & strings
% indexOptions = 2:15; 
% strOptions = {'2','3','4','5','6','7','8','9','10','11','12','13','14','15'};

%Sorted highest to lowest
indexOptions = 15:-1:2; 
strOptions = {'15','14','13','12','11','10','9','8','7','6','5','4','3','2'};
end

function [indexOptions strOptions] = options_COMPRESSIONLEVEL()
%Raw indices & strings
indexOptions = 0:6; 
strOptions = {'JPEG Basic','JPEG Normal','JPEG Fine','RAW',...
    'RAW + JPEG Basic','RAW + JPEG Normal','RAW + JPEG Fine'};

end


function [indexOptions strOptions] = options_SENSITIVITY()
%There are more options with the name "Hi-2.0". These were ignored

%Raw indices & strings
% indexOptions = 0:18; 
% strOptions = {'100','125','160','200','250','320','400','500','640','800',...
%     '1000','1250','1600','2000','2500','3200','4000','5000','6400'};

%Sorted highest to lowest
indexOptions = 18:-1:0; 
strOptions = {'6400','5000','4000','3200','2500','2000','1600','1250',...
    '1000','800','640','500','400','320','250','200','160','125','100'};
end