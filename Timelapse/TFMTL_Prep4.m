function outp=TFMTL_Prep4(samp)
% tic

NulImg=uigetfile('*.TIFF','Pick after trypsin image');
b_org=imread(NulImg);
% b_org=imread('af - Position 1_T0_C0.tiff');
b = bpassTF(b_org,0,7,0.05*mode(b_org(:)));

FileTif=uigetfile('*.TIF', 'Pick before trysin Image Stack');
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');

TifLink = Tiff(FileTif, 'r');

for i=1:NumberImages
    TifLink.setDirectory(i);
    FinalImage(:,:,i)=TifLink.read();
end
TifLink.close();

% list = ['bf' num2str(m) ' - Position 1_T'];

parfor i = 1:NumberImages
    sd = load([samp,'-T',num2str(i),'.mat']);
    
%     sdata = matfile([samp,'-T',num2str(i),'.mat'],'Writable',true);
    
    rect=sd.cellrec;
    recs=sd.rectd;
    
    %     a_org=imread(FinalImage(:,:,i));
    a_org=FinalImage(:,:,i);
    a = bpass(a_org,0,7,0.05*mode(a_org(:)));
    
    loadimg=imcrop(a,rect);
    
    [xd yd]=im_shift(a,b,recs);
    %If enough to cut
    if rect(2)+yd+rect(4)<size(b,1)
        nulfimg=imcrop(b,rect+[xd yd 0 0]);
        cimg = createoverlayimg(loadimg,nulfimg);
    else
%         disp([samp,-T',num2str(i),'Not enough to cut'])
        cimg = 'Error cutting';
        writeerror([samp,-T',num2str(i)],'TFMTL_Prep4:Not enough to cut')
    end
    
    sd.cimg=cimg;
    sd.loadimg=loadimg;
    sd.nulfimg=nulfimg;
    sd.drift=[xd, yd];
    parsavestruct([samp,'-T',num2str(i),'.mat'],sd)
end
% toc
end

