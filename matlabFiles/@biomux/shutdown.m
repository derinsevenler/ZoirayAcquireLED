function b_obj=shutdown(b_obj)
% function b_obj=shutdown(b_obj)
% Clears and closes hardware communication
% Saves biomux object parameters as file with
% name given by b_obj.filename

%Cut communication and clean up.
if ~strcmpi(get(b_obj,'camera'),'NikonD7000')
    closepreview;
end
if strcmp(get(0,'diary'),'on'), diary off; end

if isfield(b_obj.LED,'portnumber')
    fclose(b_obj.LED.portnumber);
end
% if(isa(b_obj.timerObj,'timer') && isvalid(b_obj.timerObj)), stop(b_obj.timerObj); delete(b_obj.timerObj); end;
% 
% %Set values to 0 in case user keeps working
% b_obj.LED=0;
% b_obj.PD=0;
% b_obj.camera=0;
% b_obj.instr=0;
% 
% %Save parameters
% save(b_obj.dataFile,'b_obj');