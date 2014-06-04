function b=loadobj(a)
%function saveobj(biomux_obj)
%function to load a biomux object
b=a;

%reset values to check their legitamacy
set(b,'wavelength',b.wavelength);
set(b,'pump_speed',b.pump_speed);
set(b,'pump_direction',b.pump_direction);
set(b,'flow_bypass',b.flow_bypass);
set(b,'valve',b.valve);
set(b,'laser_power',b.laser_power);
set(b,'exposure',b.exposure);
set(b,'num_frames',b.num_frames);
set(b,'roi',b.roi);
set(b,'use_mref',b.use_mref);
set(b,'use_pd',b.use_pd);

b.timer_obj=timer;

%look for data in directory with same root name
b=update_scan_num(b);

