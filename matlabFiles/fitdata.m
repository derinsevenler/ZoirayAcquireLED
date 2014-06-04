function fitted=fitdata(data,ox_nominal,method)
%function fitted=fitdata(data,lambda,ox_nominal,method);
%
%This function fits SRIB data.  The input data can be a 2D matrix
%or a biomux object.
%
%lambda is the wavelengths for the data.  If data is a 2D
%matrix, size(lambda) must equal size(data,1).  If the data
%is a biomux object, lambda is ignored.
%
%ox_nominal is the nominal oxide thickness
%
%method is 'phase', 'CPUdry', 'CPUwet', 'GPUdry', or 'GPUwet' to indicate
%if the fit should be phase or least squares, wet or dry (only matters for
% least squares), and by the CPU or GPU.  CPU runs on any PC while the GPU
%requires an NVIDIA graphics card and appropriate driver
%
%data is a 2D matrix
%The rows (first index) corresponds to the wavelengths and 
%the columns (second index) corresponds to different pixels.
%Hence 2D frames at one wavelength need to be reshapes to
%to a vector.  The output in this case is a vector of the
%oxide thickness determined for each pixel.
%
%data is a 3D matrix
%The rows (first index) corresponds to the wavelengths and 
%the remaing two the columns and rows of the image
%
%data is a biomux object
%In this case, biomux_obj=update_scan_num(biomux_obj) is run
%to find all files of the form:
%[biomux_obj.filename 'DataSet.mat'] and fits the data
%In this case the lambda input is ignored and the wavelengths
%are taken from the data set file.  The fitted data is saved
%in a series of files with the postfix 'Fitted.mat'.
%NOTE: if a corresponding file with the postfix 'Fitted.mat'
%already exists, fitdata will leave the file in tact and 
%won't fit the corresponding DataSet assuming that it was
%already accomplished.  The output is simply the biomux_obj
%in this case.
%
%Note this function requires that the index data files be present in
%a working path directory as well as nLUT() where air, oxide, Si, and
%buffer are designated material 1,2,3,& 4 respectiviely.
%
%
if(isa(data,'double'))   %CASE 2D matrix or 3D matrix
%     %Note: keep consistent with repeated code below
%     switch method
%         case 'phase'
%             [data] = CHECK_ifNormalized(data);
%                     
%             if(strcmp(method,'GPUdry') || strcmp(method,'CPUdry'))
%                 for j=1:size(data_wav,2)
%                     Rsi(j)= real((nLUT(data_wav(j),2) - nLUT(data_wav(j),1)) / (nLUT(data_wav(j),1) + nLUT(data_wav(j),2)))^2;
%                     data(j,:,:)=data(j,:,:).*Rsi(j);
%                 end;
%             end
%             data=reshape(data,size(data,1),size(data,2)*size(data,3));
%             fitted=FitPhase(lambda,data);	
%             fitted=ox_nominal-fitted;
%         case {'GPUdry' 'GPUwet' 'CPUdry' 'CPUwet'}
%             [data] = CHECK_ifNormalized(data));
%             
%             if(strcmp(method,'GPUdry') || strcmp(method,'CPUdry'))
%                 for j=1:size(data_wav,2)
%                     Rsi(j)= real((nLUT(data_wav(j),2) - nLUT(data_wav(j),1)) / (nLUT(data_wav(j),1) + nLUT(data_wav(j),2)))^2;
%                     data(j,:,:)=data(j,:,:).*Rsi(j);
%                 end;
%             end
%             save('tempDataSet.mat','data','data_date','data_pd','data_wav');
%             if(strcmp(method,'GPUdry')) data_fitted=FitGPU('tempDataSet',ox_nominal,'dry'); end;
%             if(strcmp(method,'GPUwet')) data_fitted=FitGPU('tempDataSet',ox_nominal,'wet'); end;
%             if(strcmp(method,'CPUdry')) data_fitted=FitCPU('tempDataSet',ox_nominal,'dry'); end;
%             if(strcmp(method,'CPUwet')) data_fitted=FitCPU('tempDataSet',ox_nominal,'wet'); end;
%         otherwise
%             error('did not recognize fit method');
%     end;
   
elseif(isa(data,'biomux'))  %CASE biomux object  
    b_obj = data; %make it clear this is a biomux_obj (not much memory)
    b_obj = update_scan_num(b_obj); %search for DataSets
    fitted = 0; %don't return fit data for biomux_obj case
    
    %Step for every data set that's been collected by biomux_obj
    for n=1:b_obj.scansTaken,
        fname_fitted=data_fname(b_obj,n,'Fitted');
        if(exist(fname_fitted,'file')~=2),
            %fitted file not found, so we'll fit it.
            fname_dataset = data_fname(b_obj,n,'DataSet');
            disp(['Will fit:  ' fname_dataset]);
            [params] = LOAD_Dataset(fname_dataset);
            [data] = CHECK_ifNormalized(fname_dataset,params);
            
            switch method
                case {'GPUdry' 'GPUwet' 'CPUdry' 'CPUwet'}
                    if(strcmp(method,'GPUdry')) 
                        [instr] = params.instr;
                        [fit_params] = [1 ox_nominal 0];
                        fitted = FitGPU(data,fit_params,instr);
                        params.data_fitted = fitted.ox;                        
                    end;
            end
            SAVE_Fitted(fname_fitted,params);
            disp(['saved: ' fname_fitted]),
        else
            disp(['Already fit:  ' fname_fitted]);
        end;
    end;
    disp('Fitting Complete');
%CASE data is neither double or biomux object
else
    error('Data must be a biomux object or a 2D matrix of type double');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%           These models are for the SRIB algorithm          %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fitted=FitGPU(data,init_param,fittinginstr)
%GPU fitting algorithm for IRIS and CaFE
% Written by Dylan Jackson - Dec. 2012
% Implemented by Alexander Reddington - Jul. 2013

params = LOAD_InstrumentParams(fittinginstr,{'spectrum_size','theta_size'});
cd '..\libraries\Fitting Files'

%Need to be written for every dataset
FIDinit = fopen('init.bin','w');
FIDdata = fopen('data.bin','w');
FIDdims = fopen('dims.bin','w');
FIDparam = fopen('param.bin','w');

modelType = 2; %this ensures the correct path in the CUDA app...
[z x y] = size(data);
lambda = [455 518 598 635];
prec = 1e-8;

init_param = repmat(init_param',[1 x y]); %Initial Guess -  Will be set by GUI
data_dims = [x y z params.spectrum_size params.theta_size 0 0 lambda modelType];
init = [length(data_dims) prec];

fwrite(FIDparam, init_param, 'float');
fwrite(FIDinit, init, 'float');
fwrite(FIDdata, data, 'float');
fwrite(FIDdims, data_dims,'int');
fclose('all');

tic
[status,result] = system('CaFE_single_complex.exe');
toc

if (status~=0)
    error('CUDA application exited with an error... please ensure .exe and .bin files are colocated!');
end

% read in output file...
out = fopen('output.bin','rb');
cd('..\..\matlabFiles\');
beta = fread(out,[3,x*y],'float');
fclose(out);

[beta(2,:) b] = CHECK_ifNaNInf(beta(2,:),-1);

fitted.ox = reshape(beta(2,:),[x y]); %PHASE
% fitted.amp = reshape(beta(1,:),[x y]); %AMP
% fitted.dc = reshape(beta(3,:).*single((beta(3,:))>=0),[x y]); %DC
% fitted.res = zeros(size(fitted.ox)); %residuals
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%           These models are for the SRIB algorithm          %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function ox=FitPhase(lambda,data)
% %fit by phase shift
% D=fft(data);
% phase=angle(D(2,:))-pi/2;
% ox=mean(lambda)*phase/(4*pi);
% 
% function ox=FitGPU(fname,ox_nom,wetdry)
% %fit on the GPU using the external ZoirayAlgorthim.exe application
% ConvertToBinary(fname);
% if(strcmp(wetdry,'wet')),  
%     system(strcat('C:\User_Scratch\LocalTools\ZoirayAlgorithm.exe --gpu --wet --input="',fname,'.zoi" --output="',fname,'.bin" --dnom=',num2str(ox_nom),' --max=',num2str(ox_nom+50),' --min=',num2str(ox_nom-50')));
% else
%     system(strcat('C:\User_Scratch\LocalTools\ZoirayAlgorithm.exe --gpu --input="',fname,'.zoi" --output="',fname,'.bin" --dnom=',num2str(ox_nom),' --max=',num2str(ox_nom+50),' --min=',num2str(ox_nom-50')));
% end;
% [scale,ox,offset]=ReadBinaryOutput([fname '.bin']);
% return
% 
% function ox=FitCPU(fname,ox_nom,wetdry)
% %fit on the CPU using the external ZoirayAlgorithm.exe application
% ConvertToBinary(fname);
% if(strcmp(wetdry,'wet')),  
%     system(strcat('C:\User_Scratch\LocalTools\ZoirayAlgorithm.exe --wet --input="',fname,'.zoi" --output="',fname,'.bin" --dnom=',num2str(ox_nom),' --max=',num2str(ox_nom+50),' --min=',num2str(ox_nom-50')));
% else
%     system(strcat('C:\User_Scratch\LocalTools\ZoirayAlgorithm.exe --input="',fname,'.zoi" --output="',fname,'.bin" --dnom=',num2str(ox_nom),' --max=',num2str(ox_nom+50),' --min=',num2str(ox_nom-50')));
% end;
% [scale,ox,offset]=ReadBinaryOutput([fname '.bin']);
% return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
