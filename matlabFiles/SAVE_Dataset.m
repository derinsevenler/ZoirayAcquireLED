function SAVE_Dataset(fname,params)


if isfield(params,'data')
    data = params.data;
else
    data = [];
end
if isfield(params,'data_raw')
    data_raw = params.data_raw;
else
    data_raw = [];
end
if isfield(params,'data_ref')
    data_ref = params.data_ref;
else
    data_ref = [];
end
if isfield(params,'data_date')
    data_date = params.data_date;
else
    data_date = [];
end
if isfield(params,'data_pd')
    data_pd = params.data_pd;
else
    data_pd = [];
end
if isfield(params,'data_wav')
    data_wav = params.data_wav;
else
    data_wav = [];
end
if isfield(params,'instr')
    iris_info.instr = params.instr;
else
    iris_info.instr = [];
end
if isfield(params,'version')
    iris_info.version = params.version;
else
    iris_info.version = [];
end

save(fname,'data','data_raw','data_ref','data_date','data_pd','data_wav','iris_info');