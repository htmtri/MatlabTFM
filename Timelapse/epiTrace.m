function [cellTrace,L,s]=epiTrace(cellimg,fudgeFactor)

% fudgeFactor = .999 % change this field to change detection threshold

[~, threshold] = edge(cellimg, 'sobel');
BWs = edge(cellimg,'sobel', threshold * fudgeFactor);
%     figure, imshow(BWs), title('Binary Gradient Mask')
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);
figure, imshow(BWsdil), title('Dilated gradient mask')

BWdfill = imfill(BWsdil, 'holes');
%     figure, imshow(BWdfill), title('Filled')
BWnobord = imclearborder(BWdfill, 4);
%     figure, imshow(BWnobord), title('Clear Border')
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
figure, imshow(BWfinal), title('Eroding Smooth')

BWoutline = bwperim(BWfinal);
[B,L] = bwboundaries(BWfinal);
[max_size, max_index] = max(cellfun('size', B, 1));
cellpolygon = polyshape(B{max_index}(:,1),B{max_index}(:,2));
[cent_x,cent_y] = centroid(cellpolygon);
order = 3;
windowsWidth = 11;
sgfx = sgolayfilt(B{max_index}(:,1),order,windowsWidth);
sgfy = sgolayfilt(B{max_index}(:,2),order,windowsWidth);
figure, imshow(cellimg,[0 0.8*max(cellimg(:))])

hold on
plot(B{max_index}(:,2),B{max_index}(:,1),'c')
plot(cent_y,cent_x,'r*')
%     plot(bound_y,bound_x,'y')
plot(sgfy,sgfx,'y')
title('Savitzky-Golay Smooth')
hold off

assignin('base','L',L)
assignin('base','s',B)
assignin('base','cellTrace',[sgfx sgfy])

s = B;
cellTrace = [sgfy sgfx];

end