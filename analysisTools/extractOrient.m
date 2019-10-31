close all; clearvars;
cwd = pwd;
selpath = uigetdir;
cd(selpath)
mat = dir('*.mat');

[orderParam, Plength] = ... 
 deal(zeros(1,numel(mat)));

for k=1:length(mat)
   m = matfile(mat(k).name);
   orderParam(k)=m.ordergrid;
   Plength(k)=1./m.c;
end

sdata.orderParam = orderParam;
sdata.Plength = Plength;

[dat, fieldname] = struct2matFE(sdata);

saveName = split(selpath,"\");

cd(cwd)

writeStringArray([saveName{end},'StressOrient.csv'],fieldname')
dlmwrite([saveName{end},'StressOrient.csv'],dat,'-append')