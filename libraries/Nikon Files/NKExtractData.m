function [output] = NKExtractData(fileRootName, LED)
% [out] = NKExtractData(fileRootName,LED)
%
% Loads the data saved from NKCapture_RA

channel = [3 2 1 1]; %B->Blue, G->Green, Y/R->Red

filename = [fileRootName LED];

temp = NKReadDataFile(filename);
    
%Extract data from the proper channel
switch(upper(LED))%
    % Blue
    case 'BLUE'
        data = double(temp(:,:,channel(1)));
            
    % Green
    case 'GREEN'
    data = double(temp(:,:,channel(2)));
           
    % Yellow
    case 'YELLOW'
        data = double(temp(:,:,channel(3)));
            
    % Red
    case 'RED'
        data = double(temp(:,:,channel(4)));
end
    
%Check for NaN & Output data
output = checkForNaN(data);
end


function data = checkForNaN(data)
if ~isempty(find(isnan(data),1))
    for p = 1:size(data,1)
        if ~isempty(find(isnan(data(p,:,:)),1))
            for o = 1:size(data,2)
                if ~isempty(find(isnan(data(p,o,:)),1))
                    for n = 1:size(data,3)
                        if isnan(data(p,o,n))
                            data(p,o,n) = 0;
                        end
                    end
                end
            end
        end
    end
end
end