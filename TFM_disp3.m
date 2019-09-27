function TFM_disp3(samp)
%%detect bead displacements using PIV  
% build the rgb image to show before and after load bead distribution
% Minh 2016 revision: remove NaN disp
% Minh 2017 revision: recursive run, added mpiv_smooth
% Minh 2019 revision (ver3): revamp input system, now require the name of .mat file 
% containing preprocessed data remove all displacement outside (cell boundaries+20px)

% load([samp,'.mat']);

sdata = load([samp,'.mat']);

cimg(:,:,3)=zeros(size(sdata.loadimg));
tempr=double(sdata.loadimg)/(mean(double(sdata.loadimg(:)))+5*std(double(sdata.loadimg(:))));
tempg=double(sdata.nulfimg)/(mean(double(sdata.nulfimg(:)))+5*std(double(sdata.nulfimg(:))));
tempr(tempr>1)=1;
tempg(tempg>1)=1;
cimg(:,:,1)=tempr;
cimg(:,:,2)=tempg;


%PIV code to get the bead displ
[xi,yi,iu,iv,D]=mpiv(sdata.nulfimg,sdata.loadimg,32,32,0.5,0.5,11,11,1,'mqd',1,0); %img1,img2,xsize,ysize,xoverlap,yoverlap,xmax,ymax,dt,type,recur,plot
[iu_f,iv_f,iu_s, iv_s] = mpiv_filter(iu,iv, 2, 3.0, 3, 0); %iu,iv,filter 2= median, std_stray, interpolation, plot
[iu_i, iv_i] = mpiv_smooth(iu_s, iv_s, 0);

%check and replace NaN field in iu_i and iu_v with 0
iu_i(isnan(iu_i))=0;
iv_i(isnan(iv_i))=0;

[xm,ym]=meshgrid([min(xi):xi(2)-xi(1):max(xi)],[min(yi):mean(diff(yi)):max(yi)]);
figure,imshow(cimg,[]);
hold on, 
quiver(xm',ym',iu_i,iv_i,'c');
plot(sdata.cellTrace(:,1),sdata.cellTrace(:,2),'r.')
hold off


%remove drift. the drift will be taken as the x and y displacements at
%nodes outside  the cell. 

iu_m=iu_i;
iv_m=iv_i;
[xdata,ydata,bw,xc,yc]=roipoly(cimg,sdata.cellTrace(:,1),sdata.cellTrace(:,2));
bws=imresize(bw,size(iu'));
bws=bws';
ids=find(bws(:)==0);
driftx=mean(iu_m(ids));
drifty=mean(iv_m(ids));

dispm=sqrt(iu_m(ids).^2+iv_m(ids).^2);
dnoise=nanstd(dispm);

iu_m=iu_i-driftx;
iv_m=iv_i-drifty;

%% Autoremove displacement outside cell ROI
try
    newTrace = expandBoundary(samp,20);
    [xdata,ydata,bw2,xc,yc]=roipoly(cimg,newTrace.xTraceOut,newTrace.yTraceOut);
catch
   warning('Expand Boundary inceed image bound.') 
    [xdata,ydata,bw2,xc,yc]=roipoly(cimg,sdata.cellTrace(:,1),sdata.cellTrace(:,2));
end
bws=imresize(~bw2,size(iu'));
iu_m=iu_m.*(1-bws');
iv_m=iv_m.*(1-bws');
figure,imshow(cimg,[]);
hold on, quiver(xm',ym',iu_i,iv_i,'c');
quiver(xm',ym',iu_m,iv_m,'r');
plot(sdata.cellTrace(:,1),sdata.cellTrace(:,2),'r.')
hold off

%%
%remove large displacements in area without beads
%Selecte polygonal regions where displacement are large but no beads
removp=input('Do you want to remove bogus displacements? \n [1 (yes), 0 (No)]: ');
while removp==1
    [xdata,ydata,bw,xc,yc]=roipoly;
    bws=imresize(bw,size(iu'));
    iu_m=iu_m.*(1-bws');
    iv_m=iv_m.*(1-bws');
    figure,
    imshow(cimg,[]);
    hold on, 
    quiver(xm',ym',iu_i,iv_i,'c');
    quiver(xm',ym',iu_m,iv_m,'r');
    plot(sdata.cellTrace(:,1),sdata.cellTrace(:,2),'r.')
    hold off
    title('Left click to continue removing, Right click to stop');
    [x,y,removp]=ginput(1);
end
    
%remove ideally the mean displacements should be 0. This is to remove the
%subpixel level shifts between load and nulf images
%riu=iu_m-mean(iu_m(:));
%riv=iv_m-mean(iv_m(:));

sdata.cimg=cimg;
sdata.xgrid=xm';
sdata.ygrid=ym';
sdata.xdisp=iu_m;
sdata.ydisp=iv_m;
sdata.dispnoise=dnoise;
sdata.outcelldisp=dispm;

save([samp,'.mat'],'-struct','sdata')

