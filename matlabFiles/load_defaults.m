function [device_defAns roi wav_list]=load_defaults

fid = fopen('defaults.txt', 'r');
defaults_str = fscanf(fid, '%c', [inf]);  %read all
fclose(fid);

% mat_str=cell2mat(regexpi(defaults_str,'do9481_dev:\w*;','match'));
% if(mat_str), mat_str=cell2mat(regexpi(mat_str,':\w*;','match'));
%    do9481_dev=mat_str(2:end-1); else do9481_dev='none';
% end;
% mat_str=cell2mat(regexpi(defaults_str,'do9472_dev:\w*;','match'));
% if(mat_str), mat_str=cell2mat(regexpi(mat_str,':\w*;','match'));
%    do9472_dev=mat_str(2:end-1); else do9472_dev='none';
% end;
mat_str=cell2mat(regexpi(defaults_str,'PD_Controller:\w*;','match'));
if(mat_str), mat_str=cell2mat(regexpi(mat_str,':\w*;','match'));
   pd=mat_str(2:end-1); else pd='none';
end;
mat_str=cell2mat(regexpi(defaults_str,'LED_Controller:\w*;','match'));
if(mat_str), mat_str=cell2mat(regexpi(mat_str,':\w*;','match'));
   LED=mat_str(2:end-1); else LED='none';
end;
mat_str=cell2mat(regexpi(defaults_str,'Camera:\w*;','match'));
if(mat_str), mat_str=cell2mat(regexpi(mat_str,':\w*;','match'));
   camera=mat_str(2:end-1); else camera='none';
end;
mat_str=cell2mat(regexpi(defaults_str,'Instrument:\w*;','match'));
if(mat_str), mat_str=cell2mat(regexpi(mat_str,':\w*;','match'));
   instr=mat_str(2:end-1); else instr='none';
end;

device_defAns = { pd, LED , camera, instr};
roi=[0 0 1 1];
wav_list=0;

mat_str=cell2mat(regexpi(defaults_str,'roi:.*?];','match'));
if(mat_str), split_cells=regexpi(mat_str,'\s*','split');
    if size(split_cells,2)==6, %4 #'s plus '[' and ']'
        for n=1:4, roi(n)=str2num(cell2mat(split_cells(n+1))); end;
    else
        warning('roi definition found in defaults.txt but wrong size. Syntax example: roi:[ 0 0 100 100 ];')
    end;
end;


mat_str=cell2mat(regexpi(defaults_str,'Wav_list:.*?];','match'));
if(mat_str), split_cells=regexpi(mat_str,'\s*','split');
    if size(split_cells,2)>2, %#'s plus '[' and ']'
        for n=1:(size(split_cells,2)-2), wav_list(n)=str2num(cell2mat(split_cells(n+1))); end;
    else
        warning('wav_list found in defaults.txt but wrong syntax. Example wav_list:[ 500 510 520 ];')
    end;
end;