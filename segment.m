function [segment] = segment(image, distThresh)

%adjust the image through contrast
imageR = image(:,:,1);
imageG = image(:,:,2);
imageB = image(:,:,3);
image = cat(3,imadjust(imageR),imadjust(imageG),imadjust(imageB));

image = im2double(image);

[rows columns colourRange] = size(image);

R = squeeze(image(:,:,1));
G = squeeze(image(:,:,2));
B = squeeze(image(:,:,3));

%binaryR = dither(R);
%binaryG = dither(G);
%binaryB = dither(B);

binaryR = im2bw(R, graythresh(R));
binaryG = im2bw(G, graythresh(G));
binaryB = im2bw(B, graythresh(B));

binary = imcomplement(binaryR&binaryG&binaryB);
figure; imshow(binary);
title('imcomplement of binary image');

se = strel('disk',7);
cleanedImage = imopen(binary, se);

cleanedImage = imfill(cleanedImage,'holes');
cleanedImage = imclearborder(cleanedImage);

[labels,numLabels] = bwlabel(cleanedImage);
disp(['Number of objects detected: ' num2str(numLabels)]);

rLabel = zeros(rows, columns);
gLabel = zeros(rows, columns);
bLabel = zeros(rows, columns);

for i=1:numLabels
    rLabel(labels==i) = median(R(labels==i));
    gLabel(labels==i) = median(G(labels==i));
    bLabel(labels==i) = median(B(labels==i));
end
labelledImage = cat(3,rLabel,gLabel,bLabel);


figure;

% let the selection for different colour segments repeat as many times as
% needed
selectColour(0,0);

function stopRunning(source, event)
    close all;
end

function selectColour(source, event)
    imshow(image); title('Click to select a colour of object');
    [x y] = ginput(1);
    if (x < 0 | x > columns | y < 0 | y > rows)
        return;
    end
    selcolor = labelledImage(floor(y),floor(x),:);
    C = makecform('srgb2lab');
    % using LAB is useful since luminance values can be ignored
    imLAB = applycform(labelledImage,C);
    imSelLAB = applycform(selcolor,C);
    imMask = zeros(rows,columns);
    imA = imLAB(:,:,2);
    imB = imLAB(:,:,3);
    imSelA = imSelLAB(1,2);
    imSelB = imSelLAB(1,3);
    imDist = hypot(imA-imSelA,imB-imSelB);
    imMask(imDist<distThresh) = 1;
    [cLabel,cNum] = bwlabel(imMask);
    imSeg = repmat(selcolor,[rows,columns,1]).*repmat(imMask,[1,1,3]);
    imshow((image .* .5) + (imSeg .* .5));
    title(['Selected colour objects: ' num2str(cNum)]);
    stop = uicontrol('String', 'Exit', 'Position', [20 20 50 20], 'Callback', @stopRunning);
    select = uicontrol('String', 'Select New Colour', 'Position', [100 20 150 20], 'Callback', @selectColour);
end
end