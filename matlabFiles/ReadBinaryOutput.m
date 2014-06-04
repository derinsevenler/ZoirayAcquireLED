function [scale, thickness, offset] = ReadBinaryOutput(file_name)
    fid = fopen(file_name);
    x = fread(fid, 1, 'int32');
    y = fread(fid, 1, 'int32');
    scale = fread(fid, [x,y], 'float64=>float64');
    thickness = fread(fid, [x,y], 'float64=>float64');
    offset = fread(fid, [x,y], 'float64=>float64');
    fclose(fid);  
    