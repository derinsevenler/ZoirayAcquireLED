function p=super_sweep(p,handles)
%function biomux_obj=super_sweep(biomux_obj)
%
camera = get(p,'camera');
timerObj = get(p,'timerObj');
superSweepPause = get(p,'superSweepPause');

if ~strcmpi(camera,'NikonD7000')
    closepreview;
end

if(isa(timerObj,'timer') && isvalid(timerObj))
    if(strcmp(get(p.timerObj,'running'),'off'))
        disp(['Starting Super Sweep ' datestr(now)])
        set(timerObj,'StartDelay',3,'Period',superSweepPause);
        %note: need to repass obj to drive_super_sweep with following line
        set(timerObj, 'TimerFcn', {@drive_super_sweep,p,handles});
        start(timerObj);
    else
        warning(['Super sweep already running']);
    end;
else
    error('Timer not valid; Hardware was shutdown; Sweep aborted')
end;

