function [data] = CHECK_ifNormalized(fname,params)

if ((params.data(1,1,1)>2) || (params.data(2,1,1)>2)...
        ||(params.data(3,1,1)>2)||(params.data(4,1,1)>2))
    fprintf('Data is not normalized. Need to renormalize.\n');
    
    if isfield(params,'data_raw')
        [params.data params.data_ref] = DATASET_renormalize(params.data_raw,...
            params.data,params.instr);

        disp(['Resaving: ' fname]);
        SAVE_Dataset(fname,params);
    else
        fprintf('Data_raw not found. Unable to renormalize.\n');
    end
else
    fprintf('Data properly normalized.\n');
end

data = params.data;
end