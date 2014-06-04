function [leds] = LEDS_INIT_ARDUINO(port_cfg)
%% [leds] = LEDS_INIT_ARDUINO
% leds is a struct that contains the relevant information for controlling
% the NGA-ARDUINO IRIS-SHIELD interface

leds = struct();
leds.enabled = 0;

leds.communicationType = 'Serial';

leds.commands = struct();
if nargin < 1
    ports = instrhwinfo('serial'); % Added - AR
    leds.host = ports.SerialPorts{1}; % Added - AR
    %leds.host = 'COM11'; % Removed - AR
else
    leds.host = port_cfg;
end

leds.commands.led1 = 'L1';
leds.commands.led2 = 'L2';
leds.commands.led3 = 'L3';
leds.commands.led4 = 'L4';
leds.commands.leds_off = 'O';
leds.commands.leds_on = 'A';
leds.commands.state_status = 'S';
leds.commands.vacuum_on = 'VAC1';
leds.commands.vacuum_on = 'VAC1';
leds.commands.vacuum_off = 'VAC0';
leds.commands.valve_on = 'VAL1';
leds.commands.valve_off = 'VAL0';
leds.commands.pressure = 'P';
leds.commands.front_button0 = 'FB0';
leds.commands.front_button1 = 'FB1';
leds.commands.front_button2 = 'FB2';
leds.commands.duty_cycle = 'D'; %Send the command as D[0-255] or D128

leds.pneumatics = struct();
leds.pneumatics.valve = 0;
leds.pneumatics.vac = 0;
leds.pneumatics.pressure = 0;

%Open connection and set communication protocol
client = serial(leds.host);
set(client, 'BaudRate', 9600, 'StopBits', 1);
set(client, 'Terminator', 'LF', 'Parity', 'none');
set(client, 'FlowControl', 'none');
    
try
    fopen(client);    
    set(client, 'ReadAsyncMode','continuous');
    leds.portnumber = client;
    leds.enabled = 1;
    
    %% CLEAR OUT FIRST ENTRY, BUG WITH ARDUINO
    fprintf(client, sprintf('O\r'));
    data = fscanf(client);
    flushinput(client);
catch
    leds.enabled = 0;
end

