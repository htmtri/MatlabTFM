function out=TFM_Prep2(varargin)
%% Preparation for traction force image process and traction force calculation
if nargin==0
% if no input parameters. ask user to select images to process
% foldn=uigetdir('','Pick up the folder with TFM images');
% cd(foldn);
[filec pathname]=uigetfile('*.TIFF', 'Pick the Phase contrast image file of the cell');
disp(['Cell Phase contrast image is ',filec])
[filea pathname]=uigetfile('*.TIFF', 'Pick the Fluorescent image of the beads before Trypsin');
disp(['Bead image before Trypsin is ',filea])
[fileb pathname]=uigetfile('*.TIFF', 'Pick the Fluorescent image of the beads after Trypsin');
disp(['Bead image after Trypsin is ',fileb])
out.folder=pathname;
out.cfile=filec;
out.bfile=fileb;
out.afile=filea;
elseif nargin==3
pathname=pwd;
pathname=[pathname,filesep];
filec=varargin{1};
disp(['Cell Phase contrast image is ',filec])
filea=varargin{2};
disp(['Bead image before Trypsin is ',filea])
fileb=varargin{3};
disp(['Bead image after Trypsin is ',fileb])
out.folder=pathname;
out.cfile=filec;
out.bfile=fileb;
out.afile=filea;
else
disp('Need three parameters for image names');
out=0;
return
end

%Read images
c=imread([pathname,filec]);
a_org=imread([pathname,filea]);
b_org=imread([pathname,fileb]);

%Bandpass Filter Beads Img for better SNR

a=bpass(a_org,0,10,0.05*mode(a_org(:))); %bpass(im,noise[0/1],fsize [6-9 for 0.1um],threshold)
b=bpass(b_org,0,10,0.05*mode(b_org(:))); 

% %%make a colored image using loaded as red,unloaded as green to show bead shifts
% cimg(:,:,1)=double(a)/max(double(a(:)));
% cimg(:,:,2)=double(b)/max(double(b(:)));
% cimg(:,:,3)=zeros(size(b));


%get user input to select a rectangular region enclosing the cell
figure,imshow(c,[])
title('Please select a rectangle region enclosing the cell');
disp('Please select a rectange region enclosing the cell');
rect=round(getrect);
rect(3)=(round(rect(3)/32)+1)*32-1;
rect(4)=(round(rect(4)/32)+1)*32-1;
loadimg=imcrop(a,rect);
cellimg=imcrop(c,rect);

figure,imshow(c,[])
title('Please select a rectangle region far away from any cell');
disp('Please select a rectange region far away from any cell');
recs=round(getrect);
recs(3)=(round(recs(3)/32)+1)*32-1;
recs(4)=(round(recs(4)/32)+1)*32-1;
[xd yd]=im_shift(a,b,recs);
%If enough to cut
if rect(2)+yd+rect(4)<size(b,1)
nulfimg=imcrop(b,rect+[xd yd 0 0]);
%cut image
csimg(:,:,1)=double(loadimg)/max(double(loadimg(:)));
csimg(:,:,2)=double(nulfimg)/max(double(nulfimg(:)));
csimg(:,:,3)=zeros(size(nulfimg));
close all;

%old version:
%csimg(:,:,1)=double(loadimg)/max(double(loadimg(:)));
%csimg(:,:,2)=double(nulfimg)/max(double(nulfimg(:)));
%csimg(:,:,3)=zeros(size(nulfimg));

% Draw cell edge
figure, imshow(cellimg,[])
title('Please trace the cell outline');
disp('Please trace the cell outline in the figure');
[bwc,xc,yc]=roipoly;
reg=bwlabel(bwc);
[s,l]=bwboundaries(bwc);
g=regionprops(l,'PixelList','Area');
Cell_Area=g.Area;
hold on,plot(s{1}(:,2),s{1}(:,1),'r.')
hold off
cellx=s{1}(:,2);
celly=s{1}(:,1);
figure, imshow(csimg,[])
hold on,plot(s{1}(:,2),s{1}(:,1),'r.')
hold off

%Scale factor, please modify it accordingly
scaleb=input('Scale bar (um/pixel): ');
if isempty(scaleb)
scal1=0.161e-6 % 40x objective;
else
scal1=scaleb*1e-6
end

% User input Gel stiffness
egel=input('Gel Stiffness (Pa): '),
if isempty(egel)
gel.E=9000
else
gel.E=egel;
end

% User input ANSYS version
ver=input('ANSYS version: '),
if isempty(ver)
    version=130
else    
    version=ver;
end

%save images and results

disp('Saving files ...')
prefd=input('Please specify sample name: ','s');

%write the 16bit tiff images
%imwrite(loadimg,[prefd,'_beads_Load.tif']);
%imwrite(nulfimg,[prefd,'_beads_relax.tif']);
%imwrite(cellimg,[prefd,'_cell_load.tif']);

%write the 8 bit jpeg images for view
%imwrite(uint8(loadimg/256),[prefd,'_beads_Load.jpg']);
%imwrite(uint8(nulfimg/256),[prefd,'_beads_relax.jpg']);
%imwrite(uint8(cellimg/256),[prefd,'_cell_load.jpg']);


%gel dimensions as the image size scaled for ansys. Thickness is set to be 64um;
gel.height=100*1e-6; %400.0*scal1;
gel.length=double(size(cellimg,2))*scal1;
gel.width=double(size(cellimg,1))*scal1

%save the results in a .mat file. (Area in pixel^2, cell outline in pixel)
%save([prefd,'_cond.mat'],'cellimg','loadimg','nulfimg','scal1','Cell_Area','cellx','celly','gel');
out.cellimg=cellimg;
out.loadimg=loadimg;
out.nulfimg=nulfimg;
out.cellrec=rect;
out.rectd=recs;
out.drift=[xd, yd];
out.scale=scal1;
out.CellArea=Cell_Area;
out.cellTrace=[cellx celly];
out.gel=gel;
out.version=version;
save([prefd,'.mat'],'-struct','out');
%save cell outline to a text file
fid=fopen([prefd,'_cell_pixel.txt'],'w');
fprintf(fid,'%10.3e \t %10.3e\n',[cellx celly]');
fclose(fid);
else
    out=0;
    disp('Not enough to cut')
end

