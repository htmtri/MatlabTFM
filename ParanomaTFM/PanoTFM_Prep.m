function outp = PanoTFM_Prep()

imds_pc = imageDatastore({'pc-left.tif','pc-right.tif'});
imds_bf = imageDatastore({'bf-left.tif','bf-right.tif'});
imds_af = imageDatastore({'af-left.tif','af-right.tif'});

%Scale factor, please modify it accordingly
scaleb=input('Scale bar (um/pixel): ');
if isempty(scaleb)
scal1=0.161e-6 % 40x objective;
else
scal1=scaleb*1e-6
end

% User input Gel stiffness
egel=input('Gel Stiffness (Pa): '),
if isempty(egel)
gel.E=7500
else
gel.E=egel;
end

% User input ANSYS version
ver=input('ANSYS version: '),
if isempty(ver)
    version=130
else    
    version=ver;
end

disp('Saving files ...')
prefd=input('Please specify sample name: ','s');

outp.pc = imds_pc;
outp.bf = imds_bf;
outp.af = imds_af;
outp.scale = scal1;
outp.gel = gel;
outp.ver = version;

save([prefd,'.mat'],'-struct','outp');
end