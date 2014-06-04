function q = subsasgn(p,index,val)
% SUBSASGN Define index assignment for asset objects
switch index.type
case '()'
   error('Array indexing not supported for biomux object');
case '.'
   switch index.subs
   case 'filename'
      q=set(p,'dataFile',val);
   case 'wavelength'
      q=set(p,'wavelength',val);
   case 'mirrorFile'
      q=set(p,'mirrorFile',val);
   case 'start_wav'
      q=set(p,'startWav',val);
   case 'step_wav'
      q=set(p,'stepWav',val);
   case 'stop_wav'
      q=set(p,'stopWav',val);
   case 'wav_list'
      q=set(p,'wavList',val);
   case 'exposure'
      q=set(p,'exposure',val);
   case 'cameraGain'
      q=set(p,'cameraGain',val);
   case 'numFrames'
      q=set(p,'numFrames',val);
   case 'roi'
      q=set(p,'roi',val);
   case 'refRegion'
      q=set(p,'refRegion',val);
   case 'FlagRef'
      q=set(p,'FlagRef',val);
   case 'FlagMir'
      q=set(p,'FlagMir',val);
   case 'FlagPD'
      q=set(p,'FlagPD',val);
   case 'superSweepPause'
      q=set(p,'superSweepPause',val);
   otherwise
      error('Invalid field name')
   end
end