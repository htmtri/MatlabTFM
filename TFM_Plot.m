function out=TFM_plot(samp)
%%Move the following section to plot program??
% display a message to remind user modify the output file from Ansys and
% uses notepad to edit
load([samp,'.mat']);
sdata=load([samp,'.mat']);
disp('Remove those lines not for nodal displacements at the end of ANSYS solution file PRNSOL**.txt')
system(['NOTEPAD.exe PRNSOL_',samp,'.txt'])

%read positions of nodes in layer 1
m=readnode(['NLIST_',samp,'.txt'],2,10,50,7);
nlist=m.nodes;
xn=nlist(:,2); yn=nlist(:,3); 

% Stress on On Layer 1 due to the load on top surface
ress1=readnode(['PRNSOL_',samp,'.txt'],2,17,37,7);
list_1=ress1.nodes;syz=-list_1(:,6);sxz=-list_1(:,7);
S1=sqrt((syz).^2+(sxz).^2);
figure,quiver(xn,yn,sxz,syz)
Area=meshsize*meshsize;
Force=Area*S1;
totForce=sum(Force);
%Traction Moment
mtrs=[sum(xn.*sxz) (sum(xn.*syz)+sum(yn.*sxz))/2;(sum(xn.*syz)+sum(yn.*sxz))/2 sum(yn.*syz)]*Area;
[D, W]=eig(mtrs);
%plot results
mx=max(xn)/scale;
my=max(yn)/scale;
[xssm,yssm]=meshgrid([0:mx],[0:my]);
zmsh=griddata(xn/scale,yn/scale,S1,xssm,yssm);
figure, imshow(zmsh,[]);colormap(jet);colorbar;
hold on, plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
cbar=colorbar;
set(get(cbar,'ylabel'),'String','Stress [Pa]');
% Results report
sdata.xstress=sxz;
sdata.ystress=syz;
sdata.maxstress=max(S1);
sdata.stress=S1;
sdata.totalForce=totForce;
sdata.TFmoment.matrix=mtrs;
sdata.TFmoment.Trace=trace(mtrs);
sdata.TFmoment.eigenvec=D;
sdata.TFmoment.eigenval=W;
sdata.stressmap=zmsh;
save([samp,'.mat'],'-struct','sdata');



%S1_cell=S1(nlist(index_cell,1));
% Force Calculation

 %Cell_force=Area*(S1_cell); totForce_cell=sum(Cell_force);
 
 %save([samp,'_data.mat'],'xn','yn','S1','S1_cell','Force','totForce','Cell_force','totForce_cell');


out=1;
