function b_obj=saveobj(a)
%function saveobj(biomux_obj)
%function to save data stored in a biomux object
b_obj=a;

%Set values to 0;  Hardware will need to be reinitialized by user
b_obj.do9481_obj=0;
b_obj.do9472_obj=0;
b_obj.daq_str=0;
b_obj.las_obj=0;
b_obj.vid_mod=0;
b_obj.vid_scr=0;
b_obj.timer_obj=0;