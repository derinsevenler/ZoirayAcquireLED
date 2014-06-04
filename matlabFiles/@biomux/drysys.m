function drysys(p)
%drysys(biomux_obj) 
%dries system system

p.pump_speed=4;
p.flow_bypass=1;
p.pump_direction='f';
p.valve=1; pause(90);
p.valve=2; pause(90);
p.valve=3; pause(90);
p.valve=4; pause(90);
p.valve=5; pause(90);
p.flow_bypass=0; pause(180);
p.pump_direction='s';

