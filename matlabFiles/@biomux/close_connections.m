function b_obj=close_connections(b_obj)
% function b_obj=shutdown(b_obj)
% Clears and closes hardware communication
% Saves biomux object parameters as file with
% name given by b_obj.filename

%Cut communication and clean up.
camera = get(b_obj,'camera');

if ~strcmpi(camera,'NikonD7000')
    closepreview;
end

if(isa(b_obj.timerObj,'timer') && isvalid(b_obj.timerObj)), stop(b_obj.timerObj); delete(b_obj.timerObj); end;

%Set values to 0 in case user keeps working
b_obj.LED=0;
b_obj.PD=0;
b_obj.camera=0;
b_obj.instr=0;