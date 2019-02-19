function sdata=TFMTL_Prep3(samp)
% tic

NulImg=uigetfile('*.TIFF','Pick after trypsin image');
b_org=imread(NulImg);
% b_org=imread('af - Position 1_T0_C0.tiff');
b = bpass(b_org,1,10,0.05*mode(b_org(:)));

FileTif=uigetfile('*.TIF', 'Pick before trysin Image Stack');
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

% list = ['bf' num2str(m) ' - Position 1_T'];

for i = [1:NumberImages]
    load([samp,'-T',num2str(i),'.mat']);
    
    sdata = matfile([samp,'-T',num2str(i),'.mat'],'Writable',true);
    
    rect=sdata.cellrec;
    recs=sdata.rectd;
    cellTrace = sdata.cellTrace;
    cellimg = sdata.cellimg;
    
    %     a_org=imread(FinalImage(:,:,i));
    a_org=FinalImage(:,:,i);
    a = bpass(a_org,1,10,0.05*mode(a_org(:)));
    
    loadimg=imcrop(a,rect);
    
    [xd yd]=im_shift(a,b,recs);
    %If enough to cut
    if rect(2)+yd+rect(4)<size(b,1)
        nulfimg=imcrop(b,rect+[xd yd 0 0]);
        %cut image
        csimg(:,:,1)=double(loadimg)/max(double(loadimg(:)));
        csimg(:,:,2)=double(nulfimg)/max(double(nulfimg(:)));
        csimg(:,:,3)=zeros(size(nulfimg));
        close all;
    else
        sdata=0;
        disp('Not enough to cut')
    end
    % Draw cell edge
    if exist('cellTrace','var')
        figure, imshow(csimg,[])
        hold on
        plot(cellTrace(:,1),cellTrace(:,2),'r.')
        hold off
    else
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
        sdata.CellArea=Cell_Area;
        sdata.Centroid=centroids;
        sdata.Major=MajorAxis;
        sdata.Minor=MinorAxis;
        sdata.Solidity=Solidity;
        sdata.Orientation=Orientation;
        hold on,plot(s{1}(:,2),s{1}(:,1),'r.')
        hold off
        cellx=s{1}(:,2);
        celly=s{1}(:,1);
        cellTrace = [cellx celly];
        figure, imshow(csimg,[])
        hold on,plot(s{1}(:,2),s{1}(:,1),'r.')
        hold off
    end
    
    sdata.loadimg=loadimg;
    sdata.nulfimg=nulfimg;
    sdata.drift=[xd, yd];
    %         save([samp,'-T',num2str(i+n(m)),'.mat'],'-struct','sdata');
    close all %COMMENT THIS OUT IF YOU WANT TO SEE ALL IMAGES (COST MEM)
end
% toc
end

