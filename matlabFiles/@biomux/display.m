function display(p)
%function display(p)
%Diplays the properties of the Biomux object

stg=sprintf('\n');
stg=[ stg sprintf('Experimental 11/10/2010 Version\n\n') ];
stg=[ stg sprintf('Internal Properties\n') ];

stg=[ stg sprintf('PD in use?  %d\n', get(p,'FlagPD')) ];    
stg=[ stg sprintf('Camera in use?  %s\n', get(p,'camera')) ];
stg=[ stg sprintf('Duration (s):  %.3f\n', get(p,'duration')) ];
stg=[ stg sprintf('scansTaken: %d\n', get(p,'scansTaken')) ];

if(isvalid(get(p,'timerObj')))
    stg=[ stg sprintf('supersweep:  %s\n',get(p.timerObj,'running')) ];
else
    stg=[ stg sprintf('supersweep:  Timer not valid\n') ];
end;

stg=[ stg sprintf('\nConfigurable Properties\n') ];
stg=[ stg sprintf('Filename:  %s\n',get(p,'dataFile')) ];
stg=[ stg sprintf('Mirror reference file:  %s\n',get(p,'mirrorFile')) ];
stg=[ stg sprintf('Wavelength (nm):  %.3f\n',get(p,'wavelength')) ];
stg=[ stg sprintf('Start_wav (nm):  %.3f\n',get(p,'startWav')) ];
stg=[ stg sprintf('Step_wav (nm):  %.3f\n',get(p,'stepWwav')) ];
stg=[ stg sprintf('Stop_wav (nm):  %.3f\n',get(p,'stopWav')) ];
stg=[ stg sprintf('Wav_list length:  %.d\n',length(get(p,'wavList'))) ];
stg=[ stg sprintf('Supersweep_pause (s):  %d\n',get(p,'superSweepPause')) ];
stg=[ stg sprintf('Exposure (s):  %.9f\n',get(p,'exposure')) ];
stg=[ stg sprintf('Camera gain (1-45):  %.1f\n',get(p,'cameraGain')) ];
stg=[ stg sprintf('Num_frames:  %d\n',get(p,'numFrames')) ];
stg=[ stg sprintf('ROI:  %s\n',num2str(get(p,'roi'))) ];
stg=[ stg sprintf('Ref_region:  %s\n',num2str(get(p,'refRegion'))) ];
stg=[ stg sprintf('FlagRef:  %d\n',get(p,'FlagRef')) ];
stg=[ stg sprintf('FlagMir:  %d\n',get(p,'FlagMir')) ];
stg=[ stg sprintf('FlagPD:  %d\n',get(p,'FlagPD')) ];
disp(stg);
