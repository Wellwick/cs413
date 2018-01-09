function[kSegment pixel_labels] = kSegment(image)
% Segments into k clusters and returns values

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

% The seperate coloured objects can then be seen through 
segmented_images = cell(1,5);
rgb_label = repmat(pixel_labels, [1 1 3]);

for k = 1:nColours
    colour = image;
    colour(rgb_label ~= k) = 0;
    segmented_images{k} = colour;
end

kSegment = segmented_images;

end
