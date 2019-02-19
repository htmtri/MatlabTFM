function out=TFM_Plot2(samp)
%%2017 Minh modified
% display a message to remind user modify the output file from Ansys and
% uses notepad to edit
load([samp,'.mat']);
sdata=load([samp,'.mat']);
disp('Remove those lines not for nodal displacements at the end of ANSYS solution file PRNSOL**.txt')
system(['NOTEPAD.exe PRNSOL_',samp,'.txt'])

%read positions of nodes in layer 1
% m=readnode(['NLIST_',samp,'.txt'],2,10,50,7);
% nlist=m.nodes;
% xnn=nlist(:,2); ynn=nlist(:,3);
xnn = sdata.xnode;ynn = sdata.ynode; 
xn=xnn/scale;yn=ynn/scale;

% Stress on On Layer 1 due to the load on top surface
ress1=readnode(['PRNSOL_',samp,'.txt'],2,17,37,7);
list_1=ress1.nodes;syz=-list_1(:,6);sxz=-list_1(:,7);
S1=sqrt((syz).^2+(sxz).^2);
Area=meshsize*meshsize;
Force=Area*S1;
totForce=sum(Force);

%Mean Displacement, Mean Stress
D1=sqrt((dxn).^2+(dyn).^2);
Avgdisp=mean(D1);
Avgstress=mean(S1);
Maxstress=max(S1);

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
quiver(sdata.xgrid,sdata.ygrid,sdata.xdisp,sdata.ydisp,'c');
plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
hold off

%plot stress result
B = figure;
imshow(cellimg,[]);
hold on, 
quiver(xn,yn,sxz,syz,'y');
plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
hold off

%plot stressmap result
mx=max(xn);
my=max(yn);
[xssm,yssm]=meshgrid([0:mx],[0:my]);
zmsh=griddata(xn,yn,S1,xssm,yssm);
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
sdata.xstress=sxz;
sdata.ystress=syz;
sdata.stress=S1;
sdata.TFmoment.matrix=mtrs;
sdata.TFmoment.Trace=trace(mtrs);
sdata.TFmoment.eigenvec=D;
sdata.TFmoment.eigenval=W;
sdata.stressmap=zmsh;
sdata.AvgStress=Avgstress;
sdata.maxstress=Maxstress;
sdata.totalForce=totForce;
sdata.NetMoment=NetMoment;
sdata.strainenergy=SE;
save([samp,'.mat'],'-struct','sdata');

fprintf(['Total Force [N]: ', num2str(totForce)]);
fprintf(['\n Maximum Stress [Pa]: ',num2str(Maxstress)]);
fprintf(['\n NetMoment [Nm]: ', num2str(NetMoment)]);
fprintf(['\n StrainEnergy [J]: ', num2str(SE)]);
%S1_cell=S1(nlist(index_cell,1));
% Force Calculation

 %Cell_force=Area*(S1_cell); totForce_cell=sum(Cell_force);
 
 %save([samp,'_data.mat'],'xn','yn','S1','S1_cell','Force','totForce','Cell_force','totForce_cell');


out=1;
