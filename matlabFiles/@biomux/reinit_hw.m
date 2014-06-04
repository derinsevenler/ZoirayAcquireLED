function p=reinit_hw(p)
% b_obj=biomux(b_obj);
% function to reinitialize hardware connections for biomux object

arg1 = get(p,'PD');
LED =  get(p,'LEDinfo');
arg2 = LED.communicationType;
arg3 = get(p,'Camera');
arg4 = get(p,'instrument');

p = biomux(arg1,arg2,arg3,arg4);