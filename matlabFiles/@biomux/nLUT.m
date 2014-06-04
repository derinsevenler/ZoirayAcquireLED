function n=nLUT(lam,material)
% function n=nLUT(lam,material);
% This function is a lookup table for the
% refractive index of different materials.
% It requires the material data file to be present.
% *.nnn is the real part of the index and 
% *.kkk is the imaginary part of the index when used

n=0;  %assign 0 until value is determined

if material==1,
    if exist('air.kkk','file')
        xr=load('air.nnn');
        xi=load('air.kkk');
        x=[xr(:,1) (xr(:,2)+j*xi(:,2))];
    else
        x=load('air.nnn');
    end
elseif material==2,
    if exist('si.kkk','file')
        xr=load('si.nnn');
        xi=load('si.kkk');
        x=[xr(:,1) (xr(:,2)+j*xi(:,2))];
    else
        x=load('si.nnn');
    end
elseif material==3,
    if exist('sio2.kkk','file')
        xr=load('sio2.nnn');
        xi=load('sio2.kkk');
        x=[xr(:,1) (xr(:,2)+j*xi(:,2))];
    else
        x=load('sio2.nnn');
    end    
elseif material==4,
    if exist('buffer.kkk','file')
        xr=load('buffer.nnn');
        xi=load('buffer.kkk');
        x=[xr(:,1) (xr(:,2)+j*xi(:,2))];
    else
        x=load('buffer.nnn');
    end 
elseif material==5,
    if exist('au.kkk','file')
        xr=load('au.nnn');
        xi=load('au.kkk');
        x=[xr(:,1) (xr(:,2)+j*xi(:,2))];
    else
        x=load('au.nnn');
    end    
elseif material==6,
    x=load('ebuffer.nnn');
elseif material==7,
    x=load('Hyb0_5.nnn');
elseif material==8,
    x=load('Hyb0_05.nnn');
elseif material==9,
    x=load('NaCl500mM.nnn');
elseif material==10,
    x=load('NaCl50mM.nnn');
elseif material==11,
    x=load('SSC2x.nnn');
elseif material==12,
    x=load('PBS.nnn');    
elseif material==13,
    x=load('high_index.nnn');
elseif material==14,
    x=load('low_index.nnn');    
else
    if exist('air.kkk','file')
        xr=load('air.nnn');
        xi=load('air.kkk');
        x=[xr(:,1) (xr(:,2)+j*xi(:,2))];
    else
        x=load('air.nnn');
    end    
end;
    
%Interpolate value of n between table wavelengths 
xlen=length(x(:,1));
if lam<=x(1,1),  %First check, is lam out of range
    n=x(1,2);
elseif lam>=x(xlen,1),
    n=x(xlen,2);
else
    %find where n falls
    m=1;
    while lam > x(m,1),
        m=m+1;
    end;
    bigger_lam=x(m,1);
    bigger_n=x(m,2);
    smaller_lam=x(m-1,1);
    smaller_n=x(m-1,2);
    
    slope=((bigger_n-smaller_n)/(bigger_lam-smaller_lam));
    offset=bigger_n-slope*bigger_lam;
    n=slope*lam+offset;
end;


