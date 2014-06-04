function ref_xy = SELECT_ImageRegion(data)
fig_handle = showAverage(data);
% figure;show(data,2);
%Wait for corners of reference region to be selected
try
    waitforbuttonpress;
    point1 = round(get(gca,'CurrentPoint'));
    waitforbuttonpress;
    point2 = round(get(gca,'CurrentPoint'));
    
    %sort to allow user to select either corner set in any order
    ref_x1 = min([point1(1,1) point2(1,1)]);
    ref_x2 = max([point1(1,1) point2(1,1)]);
    ref_y1 = min([point1(1,2) point2(1,2)]);
    ref_y2 = max([point1(1,2) point2(1,2)]);
    
    ref_xy = [ref_x1 ref_x2 ref_y1 ref_y2];
    close(fig_handle);
catch
    ref_xy = [];
end
end