function [xdrift ydrift]=im_shift(im1,im2,varargin)
%% Correct the drift up to one pixel level between the two images
% NOTE:  You will be prompted to select a rectangle region using mouse
%        input. Try to select the rectangle region away from the cell.
nargin
imf1=double(im1);
imf2=double(im2);
cim(:,:,1)=imf1/max(imf1(:));
cim(:,:,2)=imf2/max(imf2(:));
cim(:,:,3)=zeros(size(imf1));

if nargin<3
imshow(cim,[])

disp('Please select a rectangle region on the image');

rect=getrect;
rect=round(rect);
else
rect=varargin{1}    
end
subimg=imcrop(im1,rect);

cc=normxcorr2(subimg,im1);
[max_cc,imax]=max(abs(cc(:)));
[ypeak,xpeak]=ind2sub(size(cc),imax(1));
xpos=xpeak-rect(3);
ypos=ypeak-rect(4);

ccb=normxcorr2(subimg,im2);
[max_ccb,imaxb]=max(abs(ccb(:)));
[ypeakb,xpeakb]=ind2sub(size(ccb),imaxb(1));
xposb=xpeakb-rect(3);
yposb=ypeakb-rect(4);

xdrift=xposb-xpos;
ydrift=yposb-ypos;