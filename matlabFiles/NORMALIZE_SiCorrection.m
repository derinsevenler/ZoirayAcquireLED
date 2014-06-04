function [data] = NORMALIZE_SiCorrection(data,instr)

[param]=LOAD_InfoFile(instr,'SiCorrection');
data = data .* repmat(param.SiCorrection,[1 size(data,2) size(data,3)]);
end