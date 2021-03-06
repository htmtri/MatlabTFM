function outp=TFM_solve2(samp)
%% Calculate traction stress map by calling ANSYS
% This should be used in combination with TFM_Prep, TFM_disp.  Results from TFM_Prep and TFM_disp should be combined into 
% .mat file, which is the input file for this function.
%load sample condition, preprocessed images, and bead displacement field
%Qi Wen 2015.03



load([samp,'.mat']);


%define meshsize for ansys
isize=double(max([xgrid(2)- xgrid(1) ygrid(2)- ygrid(1)]));
meshsize=isize*scale;

sdata=load([samp,'.mat']);
version=sdata.version;

%write ansys modeling file to generate the nodes
modelfile=writeAnsysModel(samp,gel,meshsize)

%Run Ansys to generatte mesh and export the mesh number and x-y cordinates
cmds=['"C:\Program Files\ANSYS Inc\v',num2str(version),'\ansys\bin\winx64\ANSYS',num2str(version),'.exe" -b -i ', ...
    modelfile,' -o ',samp,'ModelLog.txt'];
% cmds=['"C:\Program Files\ANSYS Inc\v130\ansys\bin\winx64\ANSYS130.exe" -b -i ', ...
%     modelfile,' -o ',samp,'ModelLog.txt'];
[stat results]=system(cmds);

% If ansys run with error, Terminate program and you need to find if there
% is anything wrong.
if stat
    outp=0;
    return;
end


% reading nlist and cell data - finding positions and displacements
m=readnode(['NLIST_',samp,'.txt'],2,10,50,7);
nlist=m.nodes;
xn=nlist(:,2); yn=nlist(:,3); 
dxn=interp2(xgrid'*scale,ygrid'*scale,xdisp'*scale,xn,yn);
dyn=interp2(xgrid'*scale,ygrid'*scale,ydisp'*scale,xn,yn);
ids=find(isnan(dxn));
dxn(ids)=0;
ids=find(isnan(dyn));
dyn(ids)=0;

%find the nodal displacement 1 standard deviations larger than noise level
dispmags=sqrt(dxn.^2+dyn.^2);
realids=find(dispmags>(mean(outcelldisp)+0.25*dispnoise)*scale);

%find nodes inside cell
xcell=(cellTrace(:,1))*scale;
ycell=(cellTrace(:,2))*scale;
Incell=inpolygon(xn, yn,xcell, ycell);
index_cell=find(Incell==1);
num_innode=size(index_cell,1);
%number of nodes will be asigned with displacements for ansys
num_node=length(realids);
xpos=xn(index_cell); ypos=yn(index_cell);
xdisp=dxn(index_cell);ydisp=dyn(index_cell);
sdata.inCell=index_cell;
sdata.xnode=xn;
sdata.ynode=yn;
sdata.dxn=dxn;
sdata.dyn=dyn;
sdata.meshsize=meshsize;
sdata.dispids=realids
save([samp,'.mat'],'-struct','sdata');

% Making displacement table for AYSYS (all nodes on the top layer are
% assigned displacements)
B=[[1:length(realids)]' (nlist(realids,1)) xn(realids) yn(realids) dxn(realids) dyn(realids)];
B(2:length(realids)+1,:)=B(1:length(realids),:);
B(1,:)=[0:5];
format shortG;
dlmwrite([samp,'load.txt'],B,'\t');

%  Making displacement table for AYSYS (only nodes within cell are
% assigned displacements)
% B=[[1:size(index_cell,1)]' (nlist(index_cell,1)) xpos ypos xdisp ydisp];
% B(2:size(xpos,1)+1,:)=B(1:size(xpos,1),:);
% B(1,:)=[0:5];
% format shortG;
% dlmwrite([samp,'load.txt'],B,'\t');
% 
% index_outcell=find(Incell==0);
% xout=xn(index_outcell); yout=yn(index_outcell);
% dxout=dxn(index_outcell); dyout=dyn(index_outcell);
% C=[(1:size(index_outcell,1))' (nlist(index_outcell,1)) xout yout dxout dyout];
% C(2:size(xout,1)+1,:)=C(1:size(xout,1),:);
% C(1,:)=[0:5];
% format shortG;
% dlmwrite([samp,'nulf.txt'],C,'\t'); 

% Making ansys input text file for ansy - to apply the load on top
solvfiln=WriteAnsysSolver(samp,gel,meshsize,num_node);

ansysbatch=writeAnsysCommand(samp,'C',version,24); %2nd param is the version number, 3rd param is the number of cores

% OLD CODE
% Run Ansys to solve for traction force. You may need to modify the command
% depending on the path of your ansys installation
% disp('Ansys solving for stress ...');
% scmd=['"C:\Program Files\ANSYS Inc\v162\ansys\bin\winx64\ANSYS162.exe" -b -i ' ...
%     solvfiln,' -o ',samp,'solverLog.txt'];

%"C:\Program Files\ANSYS Inc\v162\ansys\bin\winx64\ANSYS162.exe" -b -i PBS_CopyASolve.txt -o testsolverLog.txt;
% [stat results]=system(scmd);
%!"C:\Program Files\ANSYS Inc\v130\ansys\bin\winx64\ANSYS130.exe" -b -i AnsysSolv.txt -o solvero.txt
if stat
    outp=0;
    return;
else
    outp=sdata;
end

