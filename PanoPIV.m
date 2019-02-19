function outp = PanoPIV(pc,bf,af)

%% Load img for PIV

loadimg = bf;
cellimg = pc;
nulfimg = af;


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
cellTrace(:,1)=s{1}(:,2);
cellTrace(:,2)=s{1}(:,1);
% figure, imshow(csimg,[])
% hold on,plot(s{1}(:,2),s{1}(:,1),'r.')
% hold off

cimg(:,:,3)=zeros(size(loadimg));
tempr=double(loadimg)/(mean(double(loadimg(:)))+5*std(double(loadimg(:))));
tempg=double(nulfimg)/(mean(double(nulfimg(:)))+5*std(double(nulfimg(:))));
ids=find(tempr>1);
tempr(ids)=1;
ids=find(tempg>1);
tempg(ids)=1;
cimg(:,:,1)=tempr;
cimg(:,:,2)=tempg;


%PIV code to get the bead displ
[xi,yi,iu,iv,D]=mpiv(nulfimg,loadimg,32,32,0.5,0.5,11,11,1,'mqd',1,0); %img1,img2,xsize,ysize,xoverlap,yoverlap,xmax,ymax,dt,type,recur,plot
[iu_f,iv_f,iu_s, iv_s] = mpiv_filter(iu,iv, 2, 3.0, 3, 0); %iu,iv,filter 2= median, std_stray, interpolation, plot
[iu_i, iv_i] = mpiv_smooth(iu_s, iv_s, 0);

%check and replace NaN fielda in iu_i and iu_v with 0
iu_i(isnan(iu_i))=0;
iv_i(isnan(iv_i))=0;

[xm,ym]=meshgrid([min(xi):xi(2)-xi(1):max(xi)],[min(yi):mean(diff(yi)):max(yi)]);

%remove drift. the drift will be taken as the x and y displacements at
%nodes outside  the cell.

iu_m=iu_i;
iv_m=iv_i;
[xdata,ydata,bw,xc,yc]=roipoly(cimg,cellTrace(:,1),cellTrace(:,2));
bws=imresize(bw,size(iu'));
bws=bws';
ids=find(bws(:)==0);
driftx=mean(iu_m(ids));
drifty=mean(iv_m(ids));

dispm=sqrt(iu_m(ids).^2+iv_m(ids).^2);
dnoise=nanstd(dispm);

iu_m=iu_i-driftx;
iv_m=iv_i-drifty;

newTrace = expandbw(cellTrace,50);
[xdata,ydata,bw2,xc,yc]=roipoly(cimg,newTrace(:,1),newTrace(:,2));
bws=imresize(~bw2,size(iu'));
iu_m=iu_m.*(1-bws');
iv_m=iv_m.*(1-bws');
figure,imshow(cimg,[]);
hold on, quiver(xm',ym',iu_i,iv_i,'c');
quiver(xm',ym',iu_m,iv_m,'r');
if exist('cellTrace','var')
    plot(cellTrace(:,1),cellTrace(:,2),'r.')
end
hold off

figure,
imshow(cimg,[]);
hold on
quiver(xm',ym',iu_m,iv_m,'c');
if exist('cellTrace','var')
    plot(cellTrace(:,1),cellTrace(:,2),'r.')
end
hold off

%remove bogus inside cell
removp=input('Do you want to remove bogus displacements? \n [1 (yes), 0 (No)]: ');
while removp==1
    [xdata,ydata,bw,xc,yc]=roipoly;
    bws=imresize(bw,size(iu'));
    iu_m=iu_m.*(1-bws');
    iv_m=iv_m.*(1-bws');
    figure,imshow(cimg,[]);
      hold on, quiver(xm',ym',iu_i,iv_i,'c');
        quiver(xm',ym',iu_m,iv_m,'r');
        if exist('cellTrace','var')
          plot(cellTrace(:,1),cellTrace(:,2),'r.')
        end
     hold off
     title('Left click to continue removing, Right click to stop');
     [x,y,removp]=ginput(1);
end

figure,
imshow(cimg,[]);
hold on
quiver(xm',ym',iu_m,iv_m,'c');
if exist('cellTrace','var')
    plot(cellTrace(:,1),cellTrace(:,2),'r.')
end
hold off

assignin('base','cimg',cimg)
assignin('base','xgrid',xm')
assignin('base','ygrid',ym')
assignin('base','xdisp',iu_m)
assignin('base','ydisp',iv_m)

% outp.cimg=cimg;
% outp.xgrid=xm';
% outp.ygrid=ym';
% outp.xdisp=iu_m;
% outp.ydisp=iv_m;
% outp.dispnoise=dnoise;
% outp.outcelldisp=dispm;
end

