function p=drive_super_sweep(t_obj,event,p, handles)
%function biomux_obj=super_sweep(biomux_obj)
%
disp('Super sweep timer - start next wavelength sweep')
p=single_scan(handles.biomux_obj,handles);

