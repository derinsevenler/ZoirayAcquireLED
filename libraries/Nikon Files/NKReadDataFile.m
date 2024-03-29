function image = NKReadDataFile(rootname)
%From SingleParticleGUI (CAMERA_readfile.m)
%Reads the header and data files generated by NKCapture_RA

%Read in the Header file
fp = fopen(['.\' rootname '.chdr']);
a = textscan(fp,'%d');
fclose(fp);

Header.xstart = double(a{1}(1));
Header.ystart = double(a{1}(2));
Header.xsize = double(a{1}(3));
Header.ysize = double(a{1}(4));
Header.xbin = double(a{1}(5));
Header.ybin = double(a{1}(6));
Header.numChannels = double(a{1}(14));

%Now the image is read using the information in the header
fp = fopen(['.\' rootname  '.cdat']);

%HOW DOES THIS READ OUT?
matrix = fread(fp,[Header.xsize,Header.ysize],'*uint16');
fclose(fp);

image = double(matrix'); 

%image;
%imshow(image,[4.94e4 5.82e4])