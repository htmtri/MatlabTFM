function cimg=createoverlayimg(im1,im2)
    cimg(:,:,3)=zeros(size(im1));
    tempr=double(im1)/(mean(double(im1(:)))+5*std(double(im1(:))));
    tempg=double(im2)/(mean(double(im2(:)))+5*std(double(im2(:))));
    tempr(tempr>1)=1;
    tempg(tempg>1)=1;
    cimg(:,:,1)=tempr;
    cimg(:,:,2)=tempg;
end