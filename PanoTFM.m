close all; clearvars;
samp = 'test';
sdata = load([samp,'.mat']);

%%
PanoDedrift(sdata.pc,sdata.bf,sdata.af)
PanoStitch(cellimg,loadimg,nulfimg)
PanoPIV(panocell,panoload,panonull)

%% Save for ANSYS
sdata.cellimg = cellimg;
sdata.loadimg = loadimg;
sdata.nulfimg = nulfimg;
sdata.panocell = panocell;
sdata.panoload = panoload;
sdata.panonull = panonull;
sdata.xgrid = xgrid;
sdata.ygrid = ygrid;
sdata.xdisp = xdisp;
sdata.ydisp = ydisp;

save([samp,'.mat'],'-struct','sdata');