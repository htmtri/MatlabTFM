function out=TFMTL_Plot(samp)
%%2018 Minh modified
% display a message to remind user modify the output file from Ansys and
% uses notepad to edit

n = 0;

for i = [1:30]
close all
load([samp,'-T',num2str(i+n),'.mat']);
sdata=load([samp,'-T',num2str(i+n),'.mat']);
% disp('Remove those lines not for nodal displacements at the end of ANSYS solution file PRNSOL**.txt')
% system(['NOTEPAD.exe PRNSOL_',samp,'-T',num2str(i+n),'.txt'])

%read positions of nodes in layer 1
% m=readnode(['NLIST_',samp,'-T',num2str(i+n),'.txt'],2,10,50,7);
% nlist=m.nodes;
% xnn=nlist(:,2)+xgrid(1)*scale; ynn=nlist(:,3)+ygrid(1)*scale;
xnn = sdata.xnode; ynn = sdata.ynode;
xn=xnn/scale;yn=ynn/scale;

% Stress on On Layer 1 due to the load on top surface
ress1=readnode(['PRNSOL_',samp,'-T',num2str(i+n),'.txt'],2,17,37,7);
list_1=ress1.nodes;syz=-list_1(:,6);sxz=-list_1(:,7);
S1=sqrt((syz).^2+(sxz).^2);
Area=meshsize*meshsize;
SForce=Area*S1;
totForce=sum(SForce);
Avgstress=mean(S1);
Maxstress=max(S1);

%read reaction force
forcedatan=readnode(['PRNLD_',samp,'-T',num2str(i+n),'.txt'],2,17,37,4);
Fxn=-forcedatan.nodes(:,2);
Fyn=-forcedatan.nodes(:,3);
RForce=sqrt((Fxn).^2+(Fyn).^2);
totRForce=sum(RForce);
Sxn=Fxn./Area;
Syn=Fyn./Area;
S2=RForce./Area;
AvgRstress=mean(S2);
MaxRstress=max(S2);

displacement=readnode(['PRNSOL_U',samp,'-T',num2str(i+n),'.txt'],2,17,37,5);
Dxn=displacement.nodes(:,2);
Dyn=displacement.nodes(:,3);

%Mean Displacement, Mean Stress
D1=sqrt((dxn).^2+(dyn).^2);
D2=sqrt((Dxn).^2+(Dyn).^2);
Avgdisp=mean(D1);
Avgdispsol=mean(D2);

%StrainEnergy
SE = Area.*sum(dxn.*sxz + dyn.*syz)/2;
%Traction Moment
mtrs=[sum(xnn.*sxz) (sum(xnn.*syz)+sum(ynn.*sxz))/2;(sum(xnn.*syz)+sum(ynn.*sxz))/2 sum(ynn.*syz)]*Area;
[D, W]=eig(mtrs);
NetMoment=trace(mtrs);

%plot displacement result
A = figure;
imshow(sdata.cimg,[]);
hold on,
quiver(xn,yn,dxn,dyn,'c');
plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
hold off
saveas(A,[samp,'-T',num2str(i+n),'disp'],'png');

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
saveas(B,[samp,'-T',num2str(i+n),'Force'],'png');

%plot stressmap result
mx=max(xn);
my=max(yn);
[xssm,yssm]=meshgrid([0:mx],[0:my]);
zmsh=griddata(xn,yn,S1,xssm,yssm);
C = figure; 
imagesc(zmsh);colormap(jet);colorbar;
% imshow(zmsh,jet(round(Maxstress)));colobar;
hold on, plot(cellTrace(:,1),cellTrace(:,2),'w','LineWidth',2);
cbar=colorbar;
set(get(cbar,'ylabel'),'String','Stress [Pa]','fontsize', 20);
set(cbar, 'fontsize', 20);
saveas(C,[samp,'-T',num2str(i+n),'map'],'png');

% Results report
sdata.AvgDisp=Avgdisp;
sdata.AvgDispSol=Avgdispsol;
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
sdata.Rstress=S2;
sdata.TFmoment.matrix=mtrs;
sdata.TFmoment.Trace=trace(mtrs);
sdata.TFmoment.eigenvec=D;
sdata.TFmoment.eigenval=W;
sdata.stressmap=zmsh;
sdata.Avgstress=Avgstress;
sdata.maxstress=Maxstress;
sdata.AvgRstress=AvgRstress;
sdata.MaxRstress=MaxRstress;
sdata.totRForce=totRForce;
sdata.totalForce=totForce;
sdata.NetMoment=NetMoment;
sdata.strainenergy=SE;
save([samp,'-T',num2str(i+n),'.mat'],'-struct','sdata');

fprintf(['Total Force [N]: ', num2str(totForce)]);
fprintf(['\n Maximum Stress [Pa]: ',num2str(Maxstress)]);
fprintf(['\n NetMoment [Nm]: ', num2str(NetMoment)]);
fprintf(['\n StrainEnergy [J]: ', num2str(SE)]);
%S1_cell=S1(nlist(index_cell,1));
% Force Calculation

 %Cell_force=Area*(S1_cell); totForce_cell=sum(Cell_force);
 
 %save([samp,'_data.mat'],'xn','yn','S1','S1_cell','Force','totForce','Cell_force','totForce_cell');

end
out=1;
