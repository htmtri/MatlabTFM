function out=TFM_Plot4(samp)
%%2018 Minh modified
% 2018/08 revision: solving for force using PRNLD file (reaction force)
% instead of construct force from stress and area value. Displacement is
% also reconstruct using PRNSOL_U
%%
% display a message to remind user modify the output file from Ansys and
% uses notepad to edit
% load([samp,'.mat']);
sdata=load([samp,'.mat']);

Area=sdata.meshsize*sdata.meshsize;
xnn = sdata.xnode; ynn = sdata.ynode;
xn=xnn/sdata.scale;yn=ynn/sdata.scale;

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

%verifying disp and prnsol_u
% Incell=inpolygon(xn,yn,sdata.cellTrace(:,1),sdata.cellTrace(:,2));
% index_cell=find(Incell==1);
% out_cell=find(Incell==0);
% figure
% imshow(cimg,[])
% hold on
% quiver(sdata.xgrid,sdata.ygrid,sdata.xdisp*scale,sdata.ydisp*scale,'c')
% quiver(xn(out_cell),yn(out_cell),dxn(out_cell),dyn(out_cell),'m')
% quiver(xn(out_cell),yn(out_cell),Dxn(out_cell),Dyn(out_cell),'r')
% quiver(xn(out_cell),yn(out_cell),Dxn(out_cell)-dxn(out_cell),Dyn(out_cell)-dyn(out_cell),'y')
% quiver(xn,yn,dxn,dyn,'m')
% quiver(xn,yn,Dxn,Dyn,'r')
% quiver(xn,yn,Dxn-dxn,Dyn-dyn,'y')
% plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
% hold off

%Mean Displacement, Mean Stress
% D1=sqrt((dxn(out_cell)).^2+(dyn(out_cell)).^2);
% D2=sqrt((Dxn(out_cell)-dxn(out_cell)).^2+(Dyn(out_cell)-dyn(out_cell)).^2)./(D1+1e-15);
% everythin=[xn yn dxn dyn Dxn Dyn sqrt((Dxn-dxn).^2+(Dyn-dyn).^2) sqrt(dxn.^2+dyn.^2)];

D1=sqrt((sdata.dxn).^2+(sdata.dyn).^2);
D2=sqrt((Dxn).^2+(Dyn).^2);
Avgdisp=mean(D1);
Avgdispsol=mean(D2);

%StrainEnergyDensity
SE = sum(Area.*(sdata.dxn.*sxz + sdata.dyn.*syz))/2;
%Traction Moment
mtrs=[sum(xnn.*sxz) (sum(xnn.*syz)+sum(ynn.*sxz))/2;(sum(xnn.*syz)+sum(ynn.*sxz))/2 sum(ynn.*syz)]*Area;
[D, W]=eig(mtrs);
NetMoment=trace(mtrs);

%plot displacement result
A = figure();
imshow(sdata.cimg,[]);
hold on,
quiver(xn,yn,sdata.dxn,sdata.dyn,'c');
plot(sdata.cellTrace(:,1),sdata.cellTrace(:,2),'r','LineWidth',2);
if isfield(sdata,'numCells')    
    for i=1:length(sdata.indCellArea)
        plot(sdata.indCellTrace{i}(:,1),sdata.indCellTrace{i}(:,2),'LineWidth',1.5) 
    end
end
hold off
saveas(A,[samp,'disp'],'png');

%plot force result
B = figure();
imshow(sdata.cellimg,[]);
hold on,
% quiver(xn,yn,sxz.*Area,syz.*Area,'c');
% quiver(xn,yn,dxn,dyn,'c');
% quiver(xn,yn,Fxn,Fyn,'y');
quiver(xn,yn,Fxn,Fyn,'y')
plot(sdata.cellTrace(:,1),sdata.cellTrace(:,2),'r','LineWidth',2);
if isfield(sdata,'numCells')    
    for i=1:length(sdata.indCellArea)
        plot(sdata.indCellTrace{i}(:,1),sdata.indCellTrace{i}(:,2),'LineWidth',1.5) 
    end
end
hold off
saveas(B,[samp,'Force'],'png');

%plot stressmap result
mx=max(xn);
my=max(yn);
[xssm,yssm]=meshgrid(0:mx,0:my);
% zmsh=griddata(xn,yn,S1,xssm,yssm);
zmsh=griddata(xn,yn,S1,xssm,yssm);
C = figure();
imagesc(zmsh);colormap(jet);colorbar;
hold on, plot(sdata.cellTrace(:,1),sdata.cellTrace(:,2),'w','LineWidth',2);
% quiver(sdata.xgrid,sdata.ygrid,sdata.xdisp,sdata.ydisp,'c', 'Autoscale', 'off');
cbar=colorbar;
set(get(cbar,'ylabel'),'String','Stress [Pa]','fontsize', 16);
set(cbar, 'fontsize', 16);
if isfield(sdata,'numCells')    
    for i=1:length(sdata.indCellArea)
        plot(sdata.indCellTrace{i}(:,1),sdata.indCellTrace{i}(:,2),'LineWidth',1.5) 
    end
end
hold off
saveas(C,[samp,'map'],'png');

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

% fprintf(['Total Force [N]: ', num2str(totForce)]);
% fprintf(['\n Maximum Stress [Pa]: ',num2str(Maxstress)]);
% fprintf(['\n NetMoment [Nm]: ', num2str(NetMoment)]);
% fprintf(['\n StrainEnergy [J]: ', num2str(SE)]);
%S1_cell=S1(nlist(index_cell,1));
% Force Calculation

%Cell_force=Area*(S1_cell); totForce_cell=sum(Cell_force);

%save([samp,'_data.mat'],'xn','yn','S1','S1_cell','Force','totForce','Cell_force','totForce_cell');


out=1;
end
