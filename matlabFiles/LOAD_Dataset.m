function [params] = LOAD_Dataset(fname)
load(fname); %bring in the big data

if exist('data','var')
    params.data = data;
else
    params.data = [];
end
if exist('data_raw','var')
    params.data_raw = data_raw;
else
    params.data_raw = [];
end
if exist('data_ref','var')
    params.data_ref = data_ref;
else
    params.data_ref = [];
end
if exist('data_date','var')
    params.data_date = data_date;
else
    params.data_date = [];
end
if exist('data_pd','var')
    params.data_pd = data_pd;
else
    params.data_pd = [];
end
if exist('data_wav','var')
    params.data_wav = data_wav;
else
    params.data_wav = [];
end
if exist('iris_info','var')
    if isfield(iris_info,'instr')
        params.instr = iris_info.instr;
    else
        params.instr = [];
    end
    if isfield(iris_info,'version')
        params.version = iris_info.version;
    else
        params.version = [];
    end
else
    params.instr = [];
    params.version = [];
end