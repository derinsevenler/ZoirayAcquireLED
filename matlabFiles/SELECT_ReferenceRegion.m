function [data_ref] = SELECT_ReferenceRegion(data)
fprintf('Select corners of reference region\n');
ref_xy = SELECT_ImageRegion(data(1,:,:));

if not(isempty(ref_xy))
    cut = data(:,ref_xy(3):ref_xy(4), ref_xy(1):ref_xy(2));
    data_ref = reshape(mean(mean(cut,3),2),size(data,1),1);
else
    disp('No reference region selected. Set to 1.');
    data_ref = ones(1,size(data,1));
end