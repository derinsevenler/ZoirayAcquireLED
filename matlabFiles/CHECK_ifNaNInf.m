function [data num] = CHECK_ifNaNInf(data,val)
%data = CHECK_ifNaNInf(data)
%
% data should be a 1 or 2d array
% Determines if the data points lie within limits. If data is >1e6, <0,
% NaN, or Inf, it is set to -1.

maximum_ox = 1e6;
[dim1 dim2] = size(data);

if dim1 > 1
    d = reshape(data, 1, dim1*dim2);
else
    d = data;
end

[a b] = find(d>=maximum_ox | d< 0 | isnan(d) | isinf(d));
num = size(b,2);
d(b)=val;

if dim1 > 1
    data = reshape(d, dim1, dim2);
else
    data = d;
end

end