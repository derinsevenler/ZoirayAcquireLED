function p=update_scan_num(varargin)
%function biomux_obj=update_scan_num(biomux_obj);
%This function will scan for data files that have been saved
%with the same root filename.  The time stamps of the files
%are then made into the biomux_obj.timeStamp list which is used
%to keep track of data sets. It also updates biomux_obj.scansTaken.
%The function is helpful when collecting data before fitting since 
%biomux_obj.scansTaken can fall out of date
%
%Alternate use:
%function biomux_obj=update_scan_num(biomux_obj,'Fitted');
%Use to place a list of fitted files in biomux_obj.timeStamp.
%Note that biomux_obj.scansTaken will be updated in this case as well
%to the number of fitted scans found with the root filename.  This is
%useful when processing data using a biomux object

switch nargin
    case 1
        p=varargin{1};
        name='DataSet';
    case 2
        p=varargin{1};
        name=char(varargin{2});
    otherwise
        error('update_scan_num should have a biomux object input and optionaly ''Fitted'' or ''DataSet''');
end;

if(strcmp(name,'DataSet')),
    dirfiles=dir(strcat(p.filename,'DataSet','*.mat'));
    if size(dirfiles,1),
        for n=1:length(dirfiles),
            file_postfix=cell2mat(regexp(dirfiles(n).name,'DataSet\d\d\d\d\d\d.mat','match'));
    %       dv=datevec(dirfiles(n).datenum);%get yr mon & day (Matlab ver dep)
            try dv=datevec(dirfiles(n).date); %get yr mon & day (Matlab ver dep)
            catch %if datevec fails due to different date format
                datevec_tymd(dirfiles(n).date);  %instead uses tymd format (like Hebrew)
            end
            dv(4)=str2num(file_postfix(8:9)); %tweak hour to match filename
            dv(5)=str2num(file_postfix(10:11)); %tweak min to match filename
            dv(6)=str2num(file_postfix(12:13)); %tweak sec to match filename
            time_list(n)=datenum(dv);
        end;
        p.timeStamp=sort(time_list);
        p.scansTaken=length(time_list);
    else
        warning(['No data sets found of root: ' p.filename])
    end;
elseif(strcmp(name,'Fitted')), 
    dirfiles=dir(strcat(p.filename,'Fitted','*.mat'));
    if size(dirfiles,1),
        for n=1:length(dirfiles),
            file_postfix=cell2mat(regexp(dirfiles(n).name,'Fitted\d\d\d\d\d\d.mat','match'));
    %       dv=datevec(dirfiles(n).datenum);%get yr mon & day (Matlab ver dep)
            try dv=datevec(dirfiles(n).date); %get yr mon & day (Matlab ver dep)
            catch %if datevec fails due to different date format
                datevec_tymd(dirfiles(n).date);  %instead uses tymd format (like Hebrew)
            end
            %dv
            %disp(file_postfix),
            dv(4)=str2num(file_postfix(7:8)); %tweak hour to match filename
            dv(5)=str2num(file_postfix(9:10)); %tweak min to match filename
            dv(6)=str2num(file_postfix(11:12)); %tweak sec to match filename
            %dv
            time_list(n)=datenum(dv);
        end;
        p.timeStamp=sort(time_list);
        p.scansTaken=length(time_list);
    else
        warning(['No data sets found of root: ' p.filename])
    end;
else
    error([name '  is not a recognized file postfix, expect Fitted or DataSet']);
end;