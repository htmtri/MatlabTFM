function outp=TFM_disp(varargin)
%%detect bead displacements using PIV  
% build the rgb image to show before and after load bead distribution
switch nargin
    case 0
        disp('Missing inputs')
        outp=0;
        return;  
    case 1
    outp=varargin{1};
    nulfimg=outp.nulfimg;
    loadimg=outp.loadimg;
    cellTrace=outp.cellTrace;
    case 2
    nulfimg=varargin{1};
    loadimg=varargin{2};
    a=sum(size(nulfimg)-size(loadimg));
      if a~=0
          disp('Images must be the same dimensions')
          outp=0;
          return;    
      end
    case 3
    nulfimg=varargin{1};
    loadimg=varargin{2};
    cellTrace=varargin{3};
        a=sum(size(nulfimg)-size(loadimg));
      if a~=0
          disp('Images must be the same dimensions')
          outp=0;
          return;    
      end
    otherwise
        disp('Too many inputs')
        outp=0;
        return;     
end

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
[xi,yi,iu,iv,D]=mpiv(nulfimg,loadimg,32,32,0.5,0.5,11,11,1,'mqd',0,0);
[iu_f,iv_f,iu_i, iv_i] = mpiv_filter(iu,iv, 2, 3.0, 3, 0);

[xm,ym]=meshgrid([min(xi):xi(2)-xi(1):max(xi)],[min(yi):mean(diff(yi)):max(yi)]);
figure,imshow(cimg,[]);
hold on, quiver(xm',ym',iu_i,iv_i,'c');
if exist('cellTrace','var')
plot(cellTrace(:,1),cellTrace(:,2),'r.')
else
title('Please trace the cell outline');
disp('Please trace the cell outline in the figure');
[bwc,xc,yc]=roipoly;
reg=bwlabel(bwc);
[s,l]=bwboundaries(bwc);
hold on,plot(s{1}(:,2),s{1}(:,1),'r.')
cellTrace(:,1)=s{1}(:,2);
cellTrace(:,2)=s{1}(:,1);     
end
hold off


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

%remove large displacements in area without beads
%Selecte polygonal regions where displacement are large but no beads
removp=input('Do you want to remove bogus displacements? \n [1 (yes), 0 (No)]: ');
iu_m=iu_i-driftx;
iv_m=iv_i-drifty;
while removp==1
    [xdata,ydata,bw,xc,yc]=roipoly;
    bws=imresize(bw,size(iu'));
    iu_m=iu_m.*(1-bws');
    iv_m=iv_m.*(1-bws');
    figure,imshow(cimg,[]);
      hold on, quiver(xm',ym',iu_i,iv_i,'c','Autoscale','off');
        quiver(xm',ym',iu_m,iv_m,'r','Autoscale','off');
        if exist('CellTrace','var')
          plot(cellTrace(:,1),cellTrace(:,2),'r.')
        end
     hold off
     title('Left click to continue removing, Right click to stop');
     [x,y,removp]=ginput(1);
end
    
%remove ideally the mean displacements should be 0. This is to remove the
%subpixel level shifts between load and nulf images
%riu=iu_m-mean(iu_m(:));
%riv=iv_m-mean(iv_m(:));

outp.xgrid=xm';
outp.ygrid=ym';
outp.xdisp=iu_m;
outp.ydisp=iv_m;
outp.dispnoise=dnoise;
outp.outcelldisp=dispm;

