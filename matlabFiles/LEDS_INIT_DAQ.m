function [leds] = LEDS_INIT_DAQ(port_cfg)
%% [leds] = LEDS_INIT_ARDUINO
% leds is a struct that contains the relevant information for controlling
% the NGA-ARDUINO IRIS-SHIELD interface

leds = struct();
leds.enabled = 0;
leds.communicationType = 'DAQ';

leds.commands = struct();
leds.commands.led1 = 'L1';
leds.commands.led2 = 'L2';
leds.commands.led3 = 'L3';
leds.commands.led4 = 'L4';
leds.commands.led5 = 'L5';
leds.commands.led6 = 'L6';
leds.commands.led7 = 'L7';
leds.commands.led8 = 'L8';
leds.commands.leds_off = 'O';
leds.commands.leds_on = 'A';
leds.commands.state_status = 'S';

try
    %Detect device
    if nargin < 1
        ports = daqhwinfo('nidaq');
        leds.host = ports.InstalledBoardIds{1};
    else
        leds.host = port_cfg;
    end
    
    %Open a connection
    leds.portnumber = digitalio('nidaq',leds.host);
    addline(leds.portnumber,0:7,'out',{'L0','L1','L2','L3','L4','L5','L6','L7'});
    
    %Default state - LED 1 on
    LEDS_CONTROL_DAQ(leds.portnumber,leds.commands.leds1);
    leds.enabled = 1;
catch
    leds.enabled = 0;
end

