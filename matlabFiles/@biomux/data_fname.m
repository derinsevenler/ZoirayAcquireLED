function f_name=data_fname(p,varargin)
%data_filename=data_fname(biomux_obj,val)
%Function to return filename of data set # given by val
%val must be between 1 and biomux.scansTaken
%
%note: use biomux_obj=update_scan_num(biomux_obj) to bring
%biomux_obj.scansTaken current.
%
%Alternate use:
%fitted_filename=data_fname(biomux_obj,val,'fitted')
%Again, use update_scan_num() to bring the scan number current.
%
%note in either case, this function does not ensure that the file
%exists.  Use update_scan_num() to bring the biomux_obj list of
%Data_Sets current. Use exist() to check if file other than DataSet
%exists on hard drive.

switch nargin
    case 0
        error('Must input the requested data set number')
    case 2 %assume that user is looking for a Data Set filename
        val=varargin{1};
        if(isa(val,'char')),
            error('Single input must be a number');
        end
        val=round(double(varargin{1}));
        if (val>0 && val<=get(p,'scansTaken'))
            time_stamps=get(p,'timeStamp');
            date_s=datestr(time_stamps(val));
            f_name=[get(p,'dataFile') 'DataSet' date_s(13:14) date_s(16:17) date_s(19:20) '.mat'];
        else
            error(['Data set # must be > 0 and less than scansTaken: ' num2str(get(p,'scansTaken'))])
        end
    case 3 %user is specifying the index number and the postfix
        val=round(double(varargin{1}));
        name=char(varargin{2});
        if(~(strcmp(name,'Fitted') || strcmp(name,'DataSet'))),
            warning([name '  is not a recognized file postfix, expect Fitted or DataSet']);
        end;
        if (val>0 && val<=get(p,'scansTaken')),
            time_stamps=get(p,'timeStamp');
            date_s=datestr(time_stamps(val));
            f_name=[get(p,'dataFile') name date_s(13:14) date_s(16:17) date_s(19:20) '.mat'];
        else
            error(['Data set # must be > 0 and less than scansTaken: ' num2str(get(p,'scansTaken')])
        end
    otherwise
        error('Wrong number of inputs.')
end;
        