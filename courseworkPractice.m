addpath /modules/cs413

% read in images
lego = imread('lego-bricks-1.JPG');
lego2 = imread('lego-bricks-2.JPG');
lego3 = imread('lego-bricks-3.JPG');

% shows the images
figure;
subplot(1,3,1); imshow(lego); title('Lego 1');
subplot(1,3,2); imshow(lego2); title('Lego 2');
subplot(1,3,3); imshow(lego3); title('Lego 3');

% experiment with image convolution
legoGray = rgb2gray(lego);
kern3 = ones(3,3)/9;
legoConv = conv2(double(legoGray), double(kern3), 'same');
lego_diff = legoConv - double(legoGray);
figure; 
subplot(1,2,1); imshow(lego); title('Original Lego image');
subplot(1,2,2); imshow(10 * uint8(lego_diff)); title('Convoluted image highlighting edges');

% test with zero crossings did not produce very useful edge detection
log = fspecial('log', [15 15], 1.0);
lego_log = conv2(double(legoGray), log, 'same');
figure; colormap(gray); imagesc(lego_log); title('Log filtered image');

lego_zeros = edge(double(legoGray), 'zerocross', 0.025, log);
figure; colormap gray; imagesc(lego_zeros); title('Zero crossing lego image');

%Gradient detection highlights some important info
[Gmag, Gdir] = imgradient(rgb2gray(lego), 'prewitt');
figure; imshowpair(Gmag,Gdir, 'montage');
title('Gradient magnitude and direction');

% Sobel Edge Filters
sobel_h = [1 2 1; 0 0 0; -1 -2 -1];
sobel_v = sobel_h';
lego_h = conv2(double(legoGray), double(sobel_h), 'same');
lego_v = conv2(double(legoGray), double(sobel_v), 'same');
figure; colormap gray;
h1 = subplot(1,2,1); imagesc(lego_h); title('Sobel H Output');
h2 = subplot(1,2,2); imagesc(lego_v); title('Sobel V Output');
axis([h1 h2], 'square');

% Orientation mapping
omap = atan2(lego_v, lego_h);
mag = hypot(lego_v, lego_h);
figure; colormap default;
imagesc(omap); title('Sobel Magnitude');
figure; colormap gray;
imagesc(mag); title('Sobel Angle');

% Making use of the complex2colour functions
mag = mag/max(mag(:));
i = sqrt(-1); % Just so we all know what it means
z = mag .* exp(i * omap);
figure; imshow(complex2colour(z));

% So edge detection is a functional option, although it may be possible to
% use image thresholding
figure; imshow(legoGray<80); title('Grayscale Lego image threshold at 80');

% Could further this by thresholding for specific channels
red = lego(:,:,1);
green = lego(:,:,2);
blue = lego(:,:,3);
figure;
subplot(1,3,1); imshow(red<60); title('Red thresholded');
subplot(1,3,2); imshow(green<60); title('Green thresholded');
subplot(1,3,3); imshow(blue<60); title('Blue thresholded');

% From here classification could be as simple as breaking up the possible
% combinations of colours (ie all red, green and blue present
red_logic = red<60;
green_logic = green<60;
blue_logic = blue<60;
figure; imshow(red_logic & green_logic & blue_logic);

% thresholdColours.m demonstrates the capabilities of this system as a
% basic classifier. It is not as effective at differentating colours as a
% general case segmenter, but could be further developed to allow selection
% of how much the colour space is threshold in red, green and blue.

% Useful to remove holes with imfill
imClean = imfill(red_logic, 'holes');
imClean = imclearborder(imClean);

% Make use of a Euclidean distance function to find distance between
% colours and match them together as a cluster

% Check out https://goo.gl/PGd9sH which I've been using as a basis for
% breaking up the colours into segments, this is completed in segment.m

% Attempts to seperate out the background have not been particularly
% succesful, even when splitting the image into RGB values
% Useful link: https://goo.gl/PGZohy

background = imopen(lego,strel('disk',25));
figure; surf(double(background(1:8:end,1:8:end))),zlim([0 255]);
ax = gca;
ax.YDir = 'reverse';
% The image with the background subtracted
figure; imshow(lego - background);

% Breaking down the red, green and blue values first does not massively
% improve things

red2 = imtophat(red,strel('disk',25));
green2 = imtophat(green,strel('disk',25));
blue2 = imtophat(blue,strel('disk', 25));

% Adjust for improved contrast
red2 = imadjust(red2);
green2 = imadjust(green2);
blue2 = imadjust(blue2);
figure; imshow(cat(3, red2, green2, blue2)); 
title('Background removed and image adjusted');

legoSelect = imtophat(rgb2gray(lego),strel('disk',15));
figure; imshow(imadjust(legoSelect));

% Developed with the K-Means Clustering Tutorial: https://goo.gl/DQnvzV
% Another useful way of doing colour segmentation is k means clustering
% which is quite effective despite the background.
% Improving the image through use of imadjust actually makes k means
% clustering less effective.

disp('Performing K-means clustering, this may take a little while.');

cform = makecform('srgb2lab');
lab_lego = applycform(lego,cform); % convert to LAB space
ab = double(lab_lego(:,:,2:3)); % don't need luminance
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
    colour = lego;
    colour(rgb_label ~= k) = 0;
    segmented_images{k} = colour;
end

figure; imshow(segmented_images{1}); title('Objects in first cluster');

% First attempt adding noise was not very successful
redN = awgn(double(red),20);
greenN = awgn(double(green),20);
blueN = awgn(double(blue),20);
figure; imshow(cat(3, redN, greenN, blueN));
title('Added White Gaussian Noise across all colours');

% Better method for adding gaussian noise
legoNoisy = imnoise(lego, 'gaussian');
figure; imshow(legoNoisy);
title('Gaussian Noise added to Lego image');

% The signal to noise ratio can be found by using snr
signalToNoiseRatio = snr(lego, legoNoisy);
disp(['Signal to Noise Ratio is ' num2str(signalToNoiseRatio)]);

% A weird side effect of adding Gaussian Noise to the image is that it
% enables objects to be found which weren't found in the original image
% (for the segment function).
% This can be seen for the lego2 image, since it initially did not find any
% objects with segment.m.
% The k-means segmentation is less effective with gaussian noise however.

% Can use medfilt2 to reduce the noise created by the gaussian display.
% This is completed by noiseFilter.m, however it only performs a single 
% iteration.
figure; imshowpair(legoNoisy,noiseFilter(legoNoisy),'montage');
title("Noisy image and image filtered to remove noise");

% Another attempt at segmentation was performed using activecontour,
% however this requires a long time for it's iterations, especially for
% large images like the ones this coursework is working with. For example
% an active contour performed on lego requires 5 seconds per iteration,
% resulting in 25 minutes being needed for 300 iterations.

% It might be possible to make use of the boundaries generated through the
% boundarymask function, however this has not been used for this project.
legoBoundary = boundarymask(superpixels(lego,500));
figure; imshowpair(lego,legoBoundary, 'montage');

% gaussianNoise.m displays information for objects found across the base
% and ten levels of gaussian noise for an image
gaussianNoise(lego);

% From this it is provable that filtering helps to reduce the amount of
% erronous elements, however the information is heavily distorted due to
% the lack of repeated filtering. That is why gaussianNoise2.m repeats the
% filtering several times, while the signal to noise ratio remains greater
% than 0.05.

% This is obviously a flawed method, since the snr is not always going to
% be available to the computer, but this method does return much better
% results.
gaussianNoise2(lego);

% Testing the images from the repeating function shows that it successfully
% finds the different colours as well

% RE part 3 of the task, kmeans_segment is used since it splits up the
% problem in a specific number of groups which can be displayed. Also, it
% is possible to discern which of the clusters is the background (for clear
% background images) by checking snr(image, kmeans_segment(image){k}) where k
% is a cluster number. Any snr value which is less than 1 will likely be
% the background image because it contains more of the original image than
% not. 

% lego3 image is an exception to this assumption but that is because of the
% complicated background. The closest cluster to 1 covers the majority of
% the background, however this is still contains some elements that are
% desired. The implementation could remove the cluster with the lowest snr
% value, with the assumption that it contains the most background and thus,
% the least useful information.

seperateImage(lego);

% Seperating out the images makes use of regionprops to determine bounding
% boxes and orientations for objects.

% While it would be possible to recrop these images after they have been
% reorientated, this has been left alone in order to demonstrate how they
% were originally orientated.
