function fig_handle = showAverage(data)
point = squeeze(mean(data,1));
fig_handle = figure;imshow(point);
end