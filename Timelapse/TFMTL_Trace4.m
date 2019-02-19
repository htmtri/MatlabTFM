%% Preparing cell region, cell boundary trace, and drift region for cell
% Traction Force timelapse analysis. Input: name of sample
function out=TFMTL_Trace4(varargin)
prefd=varargin{1} % name of the sample

%define region enclosing the cell (for ALL timelapse img)
rect=[248.7500  177.7500  862.5000  640.5000]
rect(3)=(round(rect(3)/32)+1)*32-1;
rect(4)=(round(rect(4)/32)+1)*32-1;

%define region far away from the cell (for ALL timelapse img)
recs=[340.2500  686.2500  159.0000  153.0000]
recs(3)=(round(recs(3)/32)+1)*32-1;
recs(4)=(round(recs(4)/32)+1)*32-1;

FileTif=uigetfile('*.TIF', 'Pick Phase Tiff Stack');
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');

TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
    TifLink.setDirectory(i);
    FinalImage(:,:,i)=TifLink.read();
end
TifLink.close();

cond = input('Do you want to look through tiff stack to get ROI? \n [1 (yes), 0 (No)]: ');
if cond == 1
    implay(FinalImage)
    disp('-GO TO TOOLS>COLORMAP, CHANGE MIN-MAX TO ADJUST BRIGHTNESS/CONTRAST.')
    disp('-LOOK THROUGH ALL FRAMES.')
    disp(['GO TO FILE>PRINT TO FIGURE TO EXPORT FRAME' ...
        'TO GET REGION THAT ENCLOSE CELL IN ALL FRAME AND' ...
        ' REGION THAT DO NOT HAVE CELL IN ANY FRAME.'])
end

cond2 = input('Are you ready to define ROI? \n [1 (yes), 0 (No)]: ');
if cond2 == 1
    imshow(FinalImage(:,:,NumberImages),[])
    disp('Please select region enclosing the cell')
    rect = round(getrect)
    rect(3)=(round(rect(3)/32)+1)*32-1;
    rect(4)=(round(rect(4)/32)+1)*32-1;
    disp('Please select region without cell')
    recs = round(getrect)
    recs(3)=(round(recs(3)/32)+1)*32-1;
    recs(4)=(round(recs(4)/32)+1)*32-1;
else %USING PREDEFINE ROI
    disp('Using default ROI. Remember to modify ROI in script.')
end
%Scale factor, please modify it accordingly
scal1=input('Enter scale [um/px]: ');
if isempty(scal1)
    scal1=0.161e-6 % 40x objective;
else
    scal1=scal1*1e-6
end

version=input('Enter ANSYS version: ');
if isempty(version)
    version=181 %ANSYS version
end

gel.E=input('Enter gel stiffness [Pa]: ');
if isempty(gel.E)
    gel.E=7500 %Gel stiffness
end

%% Replace i value if necessary
for i = [1:NumberImages]
    cellimg=imcrop(FinalImage(:,:,i),rect);
    
    figure, imshow(cellimg,[])
    title('Please trace the cell outline');
    disp('Please trace the cell outline in the figure');
    [bwc,xc,yc]=roipoly;
    reg=bwlabel(bwc);
    [s,l]=bwboundaries(bwc);
    g=regionprops(l,'PixelList','Area','Centroid','MajorAxisLength','MinorAxisLength','Solidity','Orientation');
    Cell_Area=g.Area;
    centroids = cat(1, g.Centroid);
    MajorAxis = g.MajorAxisLength;
    MinorAxis = g.MinorAxisLength;
    Solidity = g.Solidity;
    Orientation = g.Orientation;
    hold on,plot(s{1}(:,2),s{1}(:,1),'r.')
    hold off
    cellx=s{1}(:,2);
    celly=s{1}(:,1);
    cellTrace = [cellx celly];
    out.cellTrace=cellTrace;
    
    %gel dimensions as the image size scaled for ansys. Thickness is set to be 64um;
    gel.height=100*1e-6; %400.0*scal1;
    gel.length=double(size(cellimg,2))*scal1;
    gel.width=double(size(cellimg,1))*scal1;
    
    %Save output
    out.cellrec=rect;
    out.noframes=NumberImages;
    out.rectd=recs;
    out.cellimg=cellimg;
    out.CellArea=Cell_Area;
    out.Centroid=centroids;
    out.Major=MajorAxis;
    out.Minor=MinorAxis;
    out.Solidity=Solidity;
    out.Orientation=Orientation;
    out.gel=gel;
    out.scale=scal1;
    out.version=version;
    save([prefd,'-T',num2str(i),'.mat'],'-struct','out');
    close all %COMMENT THIS OUT IF YOU WANT TO SEE ALL IMAGES (COST MEM)
end
end