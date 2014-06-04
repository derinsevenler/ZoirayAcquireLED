function TurnOnLED(LEDinfo,LED)
%SetLED(LEDinfo,LED)
%
% Turns off all LEDs then turns on LED

cd('..\..\matlabFiles');
LEDS_CONTROL_ARDUINO(LEDinfo,LEDinfo.commands.leds_off);

switch upper(LED)
    case {'BLUE','LED1','L1'}
        LED = LEDinfo.commands.led1;
    case {'GREEN','LED2','L2'}
        LED = LEDinfo.commands.led2;
    case {'YELLOW','AMBER','LED3','L3'}
        LED = LEDinfo.commands.led3;
    case {'RED','LED4','L4'}
        LED = LEDinfo.commands.led4;
end

sendCommand = [LED];
[data] = LEDS_CONTROL_ARDUINO(LEDinfo,sendCommand);

cd('..\tools\SetLEDDutyCycle');