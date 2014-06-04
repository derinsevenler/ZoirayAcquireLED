function SetLEDDutyCycle(LEDinfo,LED, dutyCycle)
%SetLEDDutyCycle(LEDinfo,LED,dutyCycle)
%
%DutyCycle is 0-255

% Question: Does the LED need to be turned on before, after, or both to
% set duty cycle?

%Turn on LED
TurnOnLED(LEDinfo,LED);

%Set duty cycle
cd('..\..\matlabFiles');
sendCommand = [LEDinfo.commands.duty_cycle num2str(dutyCycle)];
[data] = LEDS_CONTROL_ARDUINO(LEDinfo,sendCommand);
cd('..\tools\SetLEDDutyCycle');

%Turn on LED
TurnOnLED(LEDinfo,LED);