function [seperateImage] = seperateImage(image)
% Method that breaks up an image using kSegment.m and places each object
% with orientation and displays them seperately.

[imSeperate pixdata] = kSegment(image);

% pixdata says which cluster each of these is in, however we will not need
% this since imSeperate has already seperated the images up

background = 1;

for i = 2 : size(imSeperate, 2)
   % Test the snr to make sure this isn't the one with a background 
   if snr(image,imSeperate{i}) < snr(image, imSeperate{background})
       background = i;
   end
end

% Now we have assumed a k value for background, let's display the remaining
% clusters as seperate elements

for i = 1 : size(imSeperate, 2)
    if i == background continue;
    end
    % Cleaning up this highlight to improve the counting of objects
    se = strel('disk',7);
    cleanedImage = imopen(rgb2gray(imSeperate{i}), se);
    cleanedImage = imfill(cleanedImage,'holes');
    cleanedImage = imclearborder(cleanedImage);
    % Perform count of objects
    [cLabel,cNum] = bwlabel(cleanedImage);
    
    % Each object is now labelled in cLabel
    % We can make sure the background is not drawn, which will normally be
    % labelled 1
    
    % Can now make use of regionprops to find orientation of each object
    stats = regionprops(cLabel, 'BoundingBox', 'Orientation');
    figure('Name', sprintf("Cluster number %i", i), 'NumberTitle', 'off');
    % work out square root value for stats size, this will be out subplot
    % val
    squareVal = round(sqrt(size(stats,1)));
    % make sure it hasn't rounded below
    while squareVal*squareVal < size(stats,1)
        squareVal = squareVal + 1;
    end
    
    for j = 2 : size(stats, 1)
        freshImage = imcrop(image, stats(j).BoundingBox);
        freshImage = imrotate(freshImage, -(stats(j).Orientation), 'loose', 'bilinear');
        subplot(squareVal,squareVal,j-1); imshow(freshImage);
        title(["Object " num2str(j)]);
    end
    
end


end