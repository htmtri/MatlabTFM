function outp=TFMTL_disp(samp)
%%detect bead displacements using PIV  
% build the rgb image to show before and after load bead distribution
% tic
n = 0;

for i=[1:28]
    
    load([samp,'-T',num2str(i+n),'.mat']);
    
%     sdata = load([samp,'-T',num2str(i+n),'.mat']);
    sdata = matfile([samp,'-T',num2str(i+n),'.mat'],'Writable',true);
    
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
    [xi,yi,iu,iv,D]=mpiv(nulfimg,loadimg,48,48,0.5,0.5,11,11,1,'mqd',1,0); %img1,img2,xsize,ysize,xoverlap,yoverlap,xmax,ymax,dt,type,recur,plot
    [iu_f,iv_f,iu_s, iv_s] = mpiv_filter(iu,iv, 2, 3.0, 3, 0); %iu,iv,filter 2= median, std_stray, interpolation, plot
    [iu_i, iv_i] = mpiv_smooth(iu_s, iv_s, 0);
    
    %check and replace NaN fielda in iu_i and iu_v with 0
    iu_i(isnan(iu_i))=0;
    iv_i(isnan(iv_i))=0;
    
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
 
    iu_m=iu_i-driftx;
    iv_m=iv_i-drifty;
    
    %% Autoremove displacement outside cell ROI
%     bws=imresize(~bw,size(iu'));
%     iu_m=iu_m.*(1-bws');
%     iv_m=iv_m.*(1-bws');
%     figure,imshow(cimg,[]);
%     hold on, quiver(xm',ym',iu_i,iv_i,'c');
%     quiver(xm',ym',iu_m,iv_m,'r');
%     if exist('cellTrace','var')
%         plot(cellTrace(:,1),cellTrace(:,2),'r.')
%     end
%     hold off
    
    %% Manual bogus removal 
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
        hold on, quiver(xm',ym',iu_i,iv_i,'c');
        quiver(xm',ym',iu_m,iv_m,'r');
        if exist('cellTrace','var')
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
    cim=cimg;
    xgrid=xm';
    ygrid=ym';
    xdisp=iu_m;
    ydisp=iv_m;
    dispnoise=dnoise;
    outcelldisp=dispm;


%     sdata.version=181;
    sdata.cimg=cim;
    sdata.xgrid=xgrid;
    sdata.ygrid=ygrid;
    sdata.xdisp=xdisp;
    sdata.ydisp=ydisp;
    sdata.dispnoise=dispnoise;
    sdata.outcelldisp=outcelldisp;
%     save([samp,'-T',num2str(i+n),'.mat'],'-struct','sdata');
    close all
end
% toc   
end
