function [xdrift ydrift]=im_shift_cell(cim,im1,im2,varargin)
%% Correct the drift up to one pixel level between the two images
% NOTE:  You will be prompted to select a rectangle region using mouse
%        input. Try to select the rectangle region away from the cell.
nargin


% Display overlap im1,im2 beads images
imf1=double(im1);
imf2=double(im2);
% cimg(:,:,1)=imf1/max(imf1(:));
% cimg(:,:,2)=imf2/max(imf2(:));
% cimg(:,:,3)=zeros(size(imf1));

if nargin<4
imshow(cim,[]);

disp('Please select a loaded free rectangle region on the image for drift correct');

rect=round(getrect);
rect=round(rect);
%fixed pixel for QImaging Camera images
rect(3)=(round(rect(3)/32)+1)*32-1; 
rect(4)=(round(rect(4)/32)+1)*32-1;
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