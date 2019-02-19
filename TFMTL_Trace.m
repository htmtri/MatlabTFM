%% Preparing
function out=TFMTL_Trace(varargin)
disp('Saving files ...')
prefd=varargin{1}

%define region enclosing the cell (for ALL timelapse img)
rect=[335.7500 327.7500 575 575];
rect(3)=(round(rect(3)/32)+1)*32-1;
rect(4)=(round(rect(4)/32)+1)*32-1;

%define region far away from the cell (for ALL timelapse img)
recs=[896.7500 210.7500 223 223];
recs(3)=(round(recs(3)/32)+1)*32-1;
recs(4)=(round(recs(4)/32)+1)*32-1;

n = [0,3,8,15,28,49,62,74,87,100]; %starting frame -1
k = [3,5,7,13,21,13,12,13,13,13]; %ending frame +1

%Scale factor, please modify it accordingly
scal1=input('Enter scale [um/px]: ');
if isempty(scal1)
scal1=0.161e-6 % 40x objective;
end

version=input('Reenter ANSYS version: ');
if isempty(version)
    version=181 %ANSYS version
end

gel.E=input('Reenter gel stiffness [Pa]: ');
if isempty(gel.E)
    gel.E=7500 %Gel stiffness
end

for m = [10]
    % list = ['bf1 - Position 2_T']; %prename
    list = ['bf' num2str(m) ' - Position 2_T'];
    
    for i = [1:k(m)]
        if (i-1 < 10) && (m > 5)
            c=imread([list '0' num2str(i-1) '_C1.tiff']);
        else
            c=imread([list num2str(i-1) '_C1.tiff']);
        end
        %     c=imread([list num2str(i-1) '_C1.tiff']);
        cellimg=imcrop(c,rect);
        figure, imshow(cellimg,[])
        title('Please trace the cell outline');
        disp('Please trace the cell outline in the figure');
        [bwc,xc,yc]=roipoly;
        reg=bwlabel(bwc);
        [s,l]=bwboundaries(bwc);
        g=regionprops(l,'PixelList','Area')%,'Centroid','MajorAxisLength','MinorAxisLength');
        Cell_Area=g.Area;
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
        out.rectd=recs;
        out.cellimg=cellimg;
        out.CellArea=Cell_Area;
        out.gel=gel;
        out.scale=scal1;
        out.version=version;
        save([prefd,'-T',num2str(i+n(m)),'.mat'],'-struct','out');
    end
    close all
end
end