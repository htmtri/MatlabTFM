function outp=TFMTL_disp2(samp)
%%detect bead displacements using PIV  
% build the rgb image to show before and after load bead distribution
tic
n = 0;

j = input('Enter first frame:');
k = input('Enter last frame:');
% j = 1;
% k = 73;

parfor i=j:k
    
    sd = load([samp,'-T',num2str(i+n),'.mat']);
    
    %PIV code to get the bead displ
    [xi,yi,iu,iv,D]=mpiv(sd.nulfimg,sd.loadimg,36,36,0.5,0.5,11,11,1,'mqd',1,0); %img1,img2,xsize,ysize,xoverlap,yoverlap,xmax,ymax,dt,type,recur,plot
    [iu_f,iv_f,iu_s, iv_s] = mpiv_filter(iu,iv, 2, 3.0, 3, 0); %iu,iv,filter 2= median, std_stray, interpolation, plot
    [iu_i, iv_i] = mpiv_smooth(iu_s, iv_s, 0);
    
    %check and replace NaN fielda in iu_i and iu_v with 0
    iu_i(isnan(iu_i))=0;
    iv_i(isnan(iv_i))=0;
    
    [xm,ym]=meshgrid(min(xi):xi(2)-xi(1):max(xi),min(yi):mean(diff(yi)):max(yi));

    %remove drift. the drift will be taken as the x and y displacements at
    %nodes outside  the cell.
    
    iu_m=iu_i;
    iv_m=iv_i;
    [xdata,ydata,bw,xc,yc]=roipoly(sd.cimg,sd.cellTrace(:,1),sd.cellTrace(:,2));
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
		newTrace = expandBoundary([samp,'-T',num2str(i+n)],20)
        [xdata,ydata,bw,xc,yc]=roipoly(sd.cimg,newTrace.xTraceOut,newTrace.yTraceOut);
    catch
        warning('new trace error - trace outside of image edge')
        writeerror([samp,'-T',num2str(i+n)],'TFMTL_Disp2:expand boundary error')
%         [xdata,ydata,bw,xc,yc]=roipoly(sd.cellimg,sd.cellTrace(:,1),sd.cellTrace(:,2));
    end
	
	xgrid = xm';
	ygrid = ym';
	
	[in, on] = inpolygon(xgrid,ygrid,xc,yc);
	iu_m(~in & ~on)=0;
	iv_m(~in & ~on)=0;
	
%    figure,imshow(cimg,[]);
%     hold on, quiver(xm',ym',iu_i,iv_i,'c');
%     quiver(xm',ym',iu_m,iv_m,'r');
%     if exist('cellTrace','var')
%         plot(sd.cellTrace(:,1),sd.cellTrace(:,2),'r.')
%         plot(newTrace.xTraceOut,newTraceyTraceOut,'w.')
%     end
%     hold off
    
    %% Manual bogus removal 
    %remove large displacements in area without beads
    %Selecte polygonal regions where displacement are large but no beads
%     removp=input('Do you want to remove bogus displacements? \n [1 (yes), 0 (No)]: ');
%     iu_m=iu_i-driftx;
%     iv_m=iv_i-drifty;
%     while removp==1
%         [xdata,ydata,bw,xc,yc]=roipoly;
%         bws=imresize(bw,size(iu'));
%         iu_m=iu_m.*(1-bws');
%         iv_m=iv_m.*(1-bws');
%         figure,imshow(cimg,[]);
%         hold on, quiver(xm',ym',iu_i,iv_i,'c');
%         quiver(xm',ym',iu_m,iv_m,'r');
%         if exist('cellTrace','var')
%             plot(cellTrace(:,1),cellTrace(:,2),'r.')
%         end
%         hold off
%         title('Left click to continue removing, Right click to stop');
%         [x,y,removp]=ginput(1);
%     end
    
    %remove ideally the mean displacements should be 0. This is to remove the
    %subpixel level shifts between load and nulf images
    %riu=iu_m-mean(iu_m(:));
    %riv=iv_m-mean(iv_m(:));
    sd.xgrid=xgrid;
    sd.ygrid=ygrid;
    sd.xdisp=iu_m;
    sd.ydisp=iv_m;
    sd.dispnoise=dnoise;
    sd.outcelldisp=dispm;
    
    parwritedispimg(samp,i+n,sd.cimg,sd.xgrid,sd.ygrid,sd.xdisp,sd.ydisp,sd.cellTrace);
    parsavestruct([samp,'-T',num2str(i+n),'.mat'],sd);
    close all
end
toc   
end
