function val=get(p, propName)
%function val=get(biomux_obj, propName)
%Get and pass back property value for a biomux object
%Only works for one property per call
switch lower(propName)
    case 'datafile'
        val=p.dataFile;
    case 'wavelength'
        val=p.wavelength;        
    case 'mirrorfile'
        val=p.mirrorFile;
    case 'startwav'
        val=p.startWav;
    case 'stepwav'
        val=p.stepWav;
    case 'stopwav'
        val=p.stopWav;
    case 'wavlist'
        val=p.wavList;
    case 'exposure'
        val=p.exposure;
    case 'pdsamplenum'
        val=p.PDSampleNum;
    case 'pdsamplerate'
        val=p.PDSampleRate;
    case 'cameragain'
        val=p.cameraGain;
    case 'numframes'
        val=p.numFrames;
    case 'roi'
        val=p.ROI;
    case 'xoffset'
        val=p.ROI(1);
    case 'yoffset'
        val=p.ROI(2);
    case 'width'
        val=p.ROI(3);
    case 'height'
        val=p.ROI(4);
    case 'maxheight'
        val=p.MaxHeight;
    case 'maxwidth'
        val=p.MaxWidth;
    case 'refregion'
        val=p.refRegion;
    case 'flagref'
        val=p.FlagRef;
    case 'flagmir'
        val=p.FlagMir;
    case 'flagpd'
        val=p.FlagPD;
    case 'timestamp'
        val=p.timeStamp;
    case 'scanstaken'
        val=p.scansTaken;
    case 'timerobj'
        val=p.timerObj;
    case 'duration'
        val=p.duration;
    case 'supersweeppause'
        val=p.superSweepPause;
    case 'ledinfo'
        val=p.LED;
    case 'pd'
        val=p.PD;
    case 'camera'
        val=p.camera;
    case 'instrument'
        val=p.instr; 
    otherwise
        error([propName,' is not a valid Biomux property']);
end;
