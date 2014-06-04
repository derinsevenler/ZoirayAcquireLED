function [data] = LEDS_CONTROL_DAQ(leds,command)
%% [data] = LEDS_CONTROL_DAQ(leds,command)

l = [];

switch command
    case 'L1'
        l = [1 0 0 0 0 0 0 0];
    case 'L2'
        l = [0 1 0 0 0 0 0 0];
    case 'L3'
        l = [0 0 1 0 0 0 0 0];
    case 'L4'
        l = [0 0 0 1 0 0 0 0];
    case 'L5'
        l = [0 0 0 0 1 0 0 0];
    case 'L6'
        l = [0 0 0 0 0 1 0 0];
    case 'L7'
        l = [0 0 0 0 0 0 1 0];
    case 'L8'
        l = [0 0 0 0 0 0 0 1];
    case 'O'
        l = [0 0 0 0 0 0 0 0];
    case 'A'
        l = [1 1 1 1 1 1 1 1];
    case 'S'
        data = 1;
        return;
end

% if ~isempty(l)
    putvalue(leds.portnumber,l);
end