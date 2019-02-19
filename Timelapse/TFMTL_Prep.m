function sdata=TFMTL_Prep(samp)
%% Preparing beads img for PIV. Need cell image input from TFMTL_Trace

n = [0,3,8,15,28,49,62,74,87,100]; %starting frame -1
k = [3,5,7,13,21,13,12,13,13,13]; %ending frame +1

b_org=imread('af - Position 2_T0_C0.tiff');
b = bpass(b_org,1,10,0.05*mode(b_org(:)));

for m = [6:10]
    list = ['bf' num2str(m) ' - Position 2_T'];
    
    for i = [1:k(m)]
%         load([samp,'-T',num2str(i+n(m)),'.mat']);
        
        sdata = load([samp,'-T',num2str(i+n(m)),'.mat']);
        
        rect=sdata.cellrec;
        recs=sdata.rectd;
        cellTrace = sdata.cellTrace;
        cellimg = sdata.cellimg;
        
        if (i-1 < 10) && (m > 5)
            a_org=imread([list '0' num2str(i-1) '_C0.tiff']);
        else
            a_org=imread([list num2str(i-1) '_C0.tiff']);
        end
        
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
            g=regionprops(l,'PixelList','Area')%,'Centroid','MajorAxisLength','MinorAxisLength');
            Cell_Area=g.Area;
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
        save([samp,'-T',num2str(i+n(m)),'.mat'],'-struct','sdata');
        
    end
    close all
end
%save cell outline to a text file
% fid=fopen([prefd,'_cell_pixel.txt'],'w');
% fprintf(fid,'%10.3e \t %10.3e\n',[cellx celly]');
% fclose(fid);
end

