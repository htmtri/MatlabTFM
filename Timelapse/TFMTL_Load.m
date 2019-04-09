function out=TFMTL_Load(samp)
%%2018 Minh modified
% display a message to remind user modify the output file from Ansys and
% uses notepad to edit

n = 0;
init = 1;
fin = 30;


for i = [init:fin]
    
    sdata=load([samp,'-T',num2str(i+n),'.mat']);
    AvgStress(i) = sdata.Avgstress;
    AvgRStress(i) = sdata.AvgRstress;
    MaxStress(i) = sdata.maxstress;
    MaxRStress(i) = sdata.MaxRstress;
    totalForce(i) = sdata.totalForce;
    totalRForce(i) = sdata.totRForce;
    StrainEnergy(i) = sdata.strainenergy;
    Area(i) = sdata.CellArea;
    Ctrd_lst{i} = sdata.Centroid;
%     AspectRatio(i) = sdata.Major/sdata.Minor;
%     Roundness(i) = 4*(sdata.CellArea/(pi()*(sdata.Major)^2));
%     Solidity(i) = sdata.Solidity;
    time(i) = (10*i)-10;
    
end

%% Displacement calculation
Disp = zeros(init,fin);
for j = [init+1:fin]
    Disp_x = Ctrd_lst{j}(2) - Ctrd_lst{j-1}(2);
    Disp_y = Ctrd_lst{j}(1) - Ctrd_lst{j-1}(1);
    Disp(j) = sqrt(Disp_x^2 + Disp_y^2);
end
out.AvgStress=AvgStress;
out.AvgRStress=AvgRStress;
out.MaxStress=MaxStress;
out.MaxRStress=MaxRStress;
out.totalForce=totalForce;
out.totalRForce=totalRForce;
out.StrainEnergy=StrainEnergy;
out.Area=Area;
% out.Roundness=Roundness;
% out.Solidity=Solidity;
% out.AspectRatio=AspectRatio;
out.Centroid=Ctrd_lst;
out.Displacement = Disp;
out.time = time;
save([samp,'.mat'],'-struct','out');
end

