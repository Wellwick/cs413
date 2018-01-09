function [kmeans_segment] = kmeans_segment(image)

cform = makecform('srgb2lab');
lab_image = applycform(image,cform); % convert to LAB space
ab = double(lab_image(:,:,2:3)); % don't need luminance
rows = size(ab,1);
columns = size(ab,2);
ab = reshape(ab,rows*columns,2); % associate a Colour for each pixel
nColours = 5; % selected number of seperate numbers set to 5
% Perform K-means clustering using Euclidean distance
% Repeats 3 times to avoid a local minima
[cluster_idx, cluster_center] = kmeans(ab,nColours, 'distance', 'sqEuclidean', 'Replicates', 3);
pixel_labels = reshape(cluster_idx,rows,columns);
% Because each pixel space has between 1-5, have to imshow with [] so that
% image doesn't appear as blank indicating a large DisplayRange [low high]
figure; imshow(pixel_labels, []); title('image labeled by cluster index');

% The seperate coloured objects can then be seen through 
segmented_images = cell(1,5);
rgb_label = repmat(pixel_labels, [1 1 3]);

for k = 1:nColours
    colour = image;
    colour(rgb_label ~= k) = 0;
    segmented_images{k} = colour;
end

kmeans_segment = segmented_images;

figure;

% let the selection for different colour segments repeat as many times as
% needed
selectColour(0,0);

function stopRunning(source, event)
    close all;
end

function selectColour(source, event)
    imshow(image); title('Select a colour to highlight');
    [x y] = ginput(1);
    if (x < 0 | x > columns | y < 0 | y > rows)
       return;
    end
    highlight = segmented_images{pixel_labels(floor(y), floor(x))};
    % Cleaning up this highlight to improve the counting of objects
    se = strel('disk',7);
    cleanedImage = imopen(rgb2gray(highlight), se);
    cleanedImage = imfill(cleanedImage,'holes');
    cleanedImage = imclearborder(cleanedImage);
    % Perform count of objects
    [cLabel,cNum] = bwlabel(cleanedImage);
    
    imshow((image .* .2) + (highlight .* .8));
    title(['Selected colour objects: ' num2str(cNum)]);

    % Put buttons in to do the next step
    stop = uicontrol('String', 'Exit', 'Position', [20 20 50 20], 'Callback', @stopRunning);
    select = uicontrol('String', 'Select New Colour', 'Position', [100 20 150 20], 'Callback', @selectColour);
end
end