function [kmeans_segment] = kmeans_segment(image)

[kmeans_segment pixel_labels] = kSegment(image);

% Because each pixel space has between 1-5, have to imshow with [] so that
% image doesn't appear as blank indicating a large DisplayRange [low high]
figure; imshow(pixel_labels, []); title('image labeled by cluster index');

[rows columns depth] = size(image);

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
       selectColour(source, event);
       return;
    end
    highlight = kmeans_segment{pixel_labels(floor(y), floor(x))};
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