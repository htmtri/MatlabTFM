function outp = PanoDedrift(ipc,ibf,iaf)
imds_pc = ipc;
imds_bf = ibf;
imds_af = iaf;
numImages = numel(imds_pc.Files);
padsize = 100;

pc{1} = padarray(readimage(imds_pc,1),[padsize padsize], 'both'); 
pc{2} = padarray((readimage(imds_pc,2)),[padsize padsize], 'both');
bf{1} = padarray((readimage(imds_bf,1)),[padsize padsize], 'both');
bf{1} = bpass(bf{1},1,10,0.05*mode(bf{1}(:)));
bf{2} = padarray((readimage(imds_bf,2)),[padsize padsize], 'both');
bf{2} = bpass(bf{2},1,10,0.05*mode(bf{2}(:)));
af{1} = padarray((readimage(imds_af,1)),[padsize padsize], 'both');
af{1} = bpass(af{1},1,10,0.05*mode(af{1}(:)));
af{2} = padarray((readimage(imds_af,2)),[padsize padsize], 'both');
af{2} = bpass(af{2},1,10,0.05*mode(af{2}(:)));


for i = 1: numImages
    figure,imshow(pc{i},[])
    title('Please select a rectangle region enclosing the cell');
    disp('Please select a rectange region enclosing the cell');
    rect=round(getrect);
    rect(3)=(round(rect(3)/32)+1)*32-1;
    rect(4)=(round(rect(4)/32)+1)*32-1;
    loadimg{i}=imcrop(bf{i},rect);
    cellimg{i}=im2double(imcrop(pc{i},rect),'indexed');
    
    figure,imshow(pc{i},[])
    title('Please select a rectangle region far away from any cell');
    disp('Please select a rectange region far away from any cell');
    recs=round(getrect);
    recs(3)=(round(recs(3)/32)+1)*32-1;
    recs(4)=(round(recs(4)/32)+1)*32-1;
    [xd yd]=im_shift(bf{i},af{i},recs);
    %If enough to cut
    if rect(2)+yd+rect(4)<size(af{i},1)
        nulfimg{i}=imcrop(af{i},rect+[xd yd 0 0]);
        %cut image
        csimg{i}(:,:,1)=double(loadimg{i})/(mean(double(loadimg{i}(:)))+5*std(double(loadimg{i}(:))));
        csimg{i}(:,:,2)=double(nulfimg{i})/(mean(double(nulfimg{i}(:)))+5*std(double(nulfimg{i}(:))));
        csimg{i}(:,:,3)=zeros(size(nulfimg{i}));
        close all;
        figure;
        imshow(csimg{i},[])
    else
    out=0;
    disp('Not enough to cut')
    end
        
end
assignin('base','cellimg',cellimg)
assignin('base','loadimg',loadimg)
assignin('base','nulfimg',nulfimg)
% outp.cellimg = cellimg;
% outp.loadimg = loadimg;
% outp.nulfimg = nulfimg;
end