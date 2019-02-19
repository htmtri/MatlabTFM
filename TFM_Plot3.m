function out=TFM_Plot3(samp)
%%2018 Minh modified
% 2018/08 revision: read force directly from PRNLD file (using reaction force)
% instead of construct force from stress and area value
%%
% display a message to remind user modify the output file from Ansys and
% uses notepad to edit
load([samp,'.mat']);
sdata=load([samp,'.mat']);
disp('Remove those lines not for nodal displacements at the end of ANSYS solution file PRNSOL**.txt')
system(['NOTEPAD.exe PRNSOL_',samp,'.txt'])
system(['NOTEPAD.exe PRNLD_',samp,'.txt'])
system(['NOTEPAD.exe PRNSOL_U',samp,'.txt'])
Area=meshsize*meshsize;

%read positions of nodes in layer 1
% m=readnode(['NLIST_',samp,'.txt'],2,10,50,7);
% nlist=m.nodes;
% xnn=nlist(:,2)+xgrid(1)*scale; ynn=nlist(:,3)+ygrid(1)*scale;
xnn = sdata.xnode; ynn = sdata.ynode;
xn=xnn/scale;yn=ynn/scale;

% Stress on On Layer 1 due to the load on top surface
ress1=readnode(['PRNSOL_',samp,'.txt'],2,17,37,7);
list_1=ress1.nodes;syz=-list_1(:,6);sxz=-list_1(:,7);
S1=sqrt((syz).^2+(sxz).^2);
SForce=Area*S1;
totSForce=sum(SForce);
Avgstress=mean(S1);
Maxstress=max(S1);

%read reaction force
forcedatan=readnode(['PRNLD_',samp,'.txt'],2,17,37,4);
Fxn=-forcedatan.nodes(:,2);
Fyn=-forcedatan.nodes(:,3);
RForce=sqrt((Fxn).^2+(Fyn).^2);
totForce=sum(RForce);
Sxn=Fxn./Area;
Syn=Fyn./Area;
R1=RForce./Area;
AvgRstress=mean(R1);
MaxRstress=max(R1);


%read displacement
displacement=readnode(['PRNSOL_U',samp,'.txt'],2,17,37,5);
Dxn=displacement.nodes(:,2);
Dyn=displacement.nodes(:,3);

xcell=(cellTrace(:,1));
ycell=(cellTrace(:,2));
Incell=inpolygon(xn,yn,xcell,ycell);
index_cell=find(Incell==1);
out_cell=find(Incell==0);

figure
imshow(cimg,[])
hold on
% quiver(sdata.xgrid,sdata.ygrid,sdata.xdisp*scale,sdata.ydisp*scale,'c')
% quiver(xn(out_cell),yn(out_cell),dxn(out_cell),dyn(out_cell),'m')
% quiver(xn(out_cell),yn(out_cell),Dxn(out_cell),Dyn(out_cell),'r')
% quiver(xn(out_cell),yn(out_cell),Dxn(out_cell)-dxn(out_cell),Dyn(out_cell)-dyn(out_cell),'y')
quiver(xn,yn,dxn,dyn,'m')
quiver(xn,yn,Dxn,Dyn,'r')
quiver(xn,yn,Dxn-dxn,Dyn-dyn,'y')
plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
hold off

%Mean Displacement, Mean Stress
D1=sqrt((dxn(out_cell)).^2+(dyn(out_cell)).^2);
D2=sqrt((Dxn(out_cell)-dxn(out_cell)).^2+(Dyn(out_cell)-dyn(out_cell)).^2)./(D1+1e-15);
everythin=[xn yn dxn dyn Dxn Dyn sqrt((Dxn-dxn).^2+(Dyn-dyn).^2) sqrt(dxn.^2+dyn.^2)];
Avgdisp=mean(D1);

%StrainEnergy
SE = Area.*sum(dxn.*sxz + dyn.*syz)/2;
%Traction Moment
mtrs=[sum(xnn.*sxz) (sum(xnn.*syz)+sum(ynn.*sxz))/2;(sum(xnn.*syz)+sum(ynn.*sxz))/2 sum(ynn.*syz)]*Area;
[D, W]=eig(mtrs);
NetMoment=trace(mtrs);

%plot displacement result
A = figure;
imshow(cimg,[]);
hold on,
quiver(xgrid,ygrid,xdisp,ydisp,'c');
plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
hold off

%plot stress result
B = figure;
imshow(cellimg,[]);
hold on,
% quiver(xn,yn,sxz,syz,'y');
% quiver(xn,yn,dxn,dyn,'c');
% quiver(xn,yn,Fxn,Fyn,'y');
quiver(xn,yn,Fxn,Fyn,'y')
plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
hold off


%plot stressmap result
mx=max(xn);
my=max(yn);
[xssm,yssm]=meshgrid([0:mx],[0:my]);
% zmsh=griddata(xn,yn,S1,xssm,yssm);
zmsh=griddata(xn,yn,R1,xssm,yssm);
C = figure;
imagesc(zmsh);colormap(jet);colorbar;
hold on, plot(cellTrace(:,1),cellTrace(:,2),'w','LineWidth',2);
% quiver(xgrid,ygrid,xdisp,ydisp,'c', 'Autoscale', 'off');
cbar=colorbar;
set(get(cbar,'ylabel'),'String','Stress [Pa]','fontsize', 20);
set(cbar, 'fontsize', 20);

% Results report
sdata.AvgDisp=Avgdisp;
sdata.MaxDisp=max(D1);
sdata.xn=xn;
sdata.yn=yn;
sdata.Dxn=Dxn;
sdata.Dyn=Dyn;
sdata.xstress=sxz;
sdata.ystress=syz;
sdata.xRstress=Sxn;
sdata.yRstress=Syn;
sdata.stress=S1;
sdata.Rstress=R1;
sdata.TFmoment.matrix=mtrs;
sdata.TFmoment.Trace=trace(mtrs);
sdata.TFmoment.eigenvec=D;
sdata.TFmoment.eigenval=W;
sdata.stressmap=zmsh;
sdata.Avgstress=Avgstress;
sdata.maxstress=Maxstress;
sdata.AvgRstress=AvgRstress;
sdata.maxRstress=MaxRstress;
sdata.totalSForce=totSForce;
sdata.totalForce=totForce;
sdata.NetMoment=NetMoment;
sdata.strainenergy=SE;
save([samp,'.mat'],'-struct','sdata');

fprintf(['Total Force [N]: ', num2str(totForce)]);
% fprintf(['\n Maximum Stress [Pa]: ',num2str(Maxstress)]);
% fprintf(['\n NetMoment [Nm]: ', num2str(NetMoment)]);
% fprintf(['\n StrainEnergy [J]: ', num2str(SE)]);
%S1_cell=S1(nlist(index_cell,1));
% Force Calculation

%Cell_force=Area*(S1_cell); totForce_cell=sum(Cell_force);

%save([samp,'_data.mat'],'xn','yn','S1','S1_cell','Force','totForce','Cell_force','totForce_cell');


out=1;
end
