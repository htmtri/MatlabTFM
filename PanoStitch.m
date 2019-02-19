function outp = PanoStitch(pc,bf,af)


%% Load images
% Display images to be stitched
% montage(imds.Files)

%% Detecting Features

% Use beads img as base for correlation
I = bf{1};
I2 = af{1};
% Read the first image from the image set.
% I = readimage(imds, 1);
% I2 = readimage(imds2, 1);


% Initialize features for I(1)
grayImage = imbinarize(bpass(I,1,10,0.05*mode(I(:))),'adaptive');
grayImage2 = imbinarize(bpass(I2,1,10,0.05*mode(I2(:))),'adaptive');

points = detectSURFFeatures(grayImage); %scale invariant
points2 = detectSURFFeatures(grayImage2);

% point2 = detectBRISKFeatures(grayImage);

% corner points
% point3 = detectFASTFeatures(grayImage);
% point4 = detectHarrisFeatures(grayImage); %edge/gradient shift 
% point5 = detectMinEigenFeatures(grayImage); %beads

% regions = detectMSERFeatures(grayImage);

figure
imshow(I,[])
hold on
plot(points.Location(:,1),points.Location(:,2),'*r')
% plot(point5.Location(:,1),point5.Location(:,2),'*y')

[features, points] = extractFeatures(grayImage, points);
[features2, points2] = extractFeatures(grayImage2, points2);

%% Compute Transformation
% Initialize all the transforms to the identity matrix. Note that the
% projective transform is used here because the building images are fairly
% close to the camera. Had the scene been captured from a further distance,
% an affine transform would suffice.
numImages = numel(pc);
tforms(numImages) = projective2d(eye(3));
tforms2(numImages) = projective2d(eye(3));

% Initialize variable to hold image sizes.
imageSize = zeros(numImages,2);

% Iterate over remaining image pairs
for n = 2:numImages

    % Store points and features for I(n-1).
    pointsPrevious = points;
    featuresPrevious = features;
    pointsPrevious2 = points2;
    featuresPrevious2 = features2;
    
    % Read I(n).
    I = bf{n};
    I2 = af{n};
%     I = readimage(imds, n);
%     I2 = readimage(imds2, n);
    
    % Convert image to grayscale.
%     grayImage = rgb2gray(I);
    grayImage = imbinarize(bpass(I,1,10,0.05*mode(I(:))),'adaptive');
    grayImage2 = imbinarize(bpass(I2,1,10,0.05*mode(I2(:))),'adaptive');
    
    % Save image size.
    imageSize(n,:) = size(grayImage);

    % Detect and extract features for I(n).
    points = detectSURFFeatures(grayImage);
    points2 = detectSURFFeatures(grayImage2);
%     points = detectHarrisFeatures(grayImage);
%     points = detectMinEigenFeatures(grayImage);

%     figure
%     imshow(grayImage,[])
%     hold on
%     plot(points.Location(:,1),points.Location(:,2),'*r')
    
    [features, points] = extractFeatures(grayImage, points);
    [features2, points2] = extractFeatures(grayImage2, points2);
    
    % Find correspondences between I(n) and I(n-1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    indexPairs2 = matchFeatures(features2, featuresPrevious2, 'Unique', true);
    
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    matchedPoints2 = points2(indexPairs2(:,1), :);
    matchedPointsPrev2 = pointsPrevious2(indexPairs2(:,2), :);
    
    % Estimate the transformation between I(n) and I(n-1).
    tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    tforms2(n) = estimateGeometricTransform(matchedPoints2, matchedPointsPrev2,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    
    % Compute T(n) * T(n-1) * ... * T(1)
    tforms(n).T = tforms(n).T * tforms(n-1).T;
    tforms2(n).T = tforms2(n).T * tforms2(n-1).T;
end

% Compute the output limits  for each transform
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
end

% compute the average X limits for each transforms and find the image that is in the center
avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);

% apply the center image's inverse transform to all the others

Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = tforms(i).T * Tinv.T;
end

centerImageIdx = idx(centerIdx);

for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
end

maxImageSize = max(imageSize);


%% Panorama Stitch
% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
pano_Pc = zeros([height width], 'like', I);
pano_bf = zeros([height width], 'like', I);
pano_af = zeros([height width], 'like', I);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:numImages

%     Pc = readimage(imds_pc,i);
%     Bf = readimage(imds_bf,i);
%     Af = readimage(imds_af,i);
    % Transform I into the panorama.
    warpedPc = imwarp(pc{i}, tforms(i), 'OutputView', panoramaView);
    warpedBf = imwarp(bf{i},tforms(i), 'OutputView', panoramaView);
    warpedAf = imwarp(af{i},tforms2(i), 'OutputView', panoramaView);
    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    pano_Pc = step(blender, pano_Pc, warpedPc, mask); 
    pano_bf = step(blender, pano_bf, warpedBf, mask);
    pano_af = step(blender, pano_af, warpedAf, mask);
end

figure
imshow(pano_Pc,[])

figure
imshow(pano_bf,[0 500])

figure
imshow(pano_af,[0 500])

assignin('base','panocell',pano_Pc)
assignin('base','panoload',pano_bf)
assignin('base','panonull',pano_af)

end

% transformPointsForward(tforms(2),coor)