function SAVE_Fitted(fname,params)


if isfield(params,'data_fitted')
    data_fitted = params.data_fitted;
else
    data_fitted = [];
end
if isfield(params,'data_date')
    data_date = params.data_date;
else
    data_date = [];
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

save(fname,'data_fitted','data_date','data_wav','iris_info');