function [data] = NORMALIZE_ReferenceRegion(data,data_ref)

ReferenceRegion = repmat(data_ref,[1 size(data,2) size(data,3)]);
data = data ./ ReferenceRegion;
end