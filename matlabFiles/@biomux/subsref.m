function q = subsref(p,index)
%SUBSREF Define field name indexing for Biomux objects
switch index.type
    case '()'
        error('Array indexing not supported for biomux object')
    case '.'
        switch index.subs
            case 'dataFile'
                q=p.dataFile;
            case 'mirrorFile'
                q=p.mirrorFile;
            case 'wavelength'
                q=p.wavelength;
            case 'startWav'
                q=p.startWav;
            case 'stepWav'
                q=p.stepWav;
            case 'stopWav'
                q=p.stopWav;
            case 'wavList'
                q=p.wavList;
            case 'exposure'
                q=p.exposure;
            case 'cameraGain'
                q=p.cameraGain;
            case 'numFrames'
                q=p.numFrames;
            case 'roi'
                q=p.roi;
            case 'refRegion'
                q=p.refRegion;
            case 'FlagRef'
                q=p.FlagRef;
            case 'FlagMir'
                q=p.FlagMir;
            case 'FlagPD'
                q=p.FlagPD;
            case 'timeStamp'
                q=p.timeStamp;
            case 'scansTaken'
                q=p.scansTaken;
            case 'timerObj'
                q=p.timerObj;
            case 'superSweepPause'
                q=p.superSweepPause;
            otherwise
                error('Invalid field name')
        end
    case '{}'
        error('Cell array indexing not supported by class')
end