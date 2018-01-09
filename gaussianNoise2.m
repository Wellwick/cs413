function [gaussianNoise2] = gaussianNoise2(image)

% Will repeat at 10 levels of gaussianNoise and output a table for how
% successful the segment method is at finding objects

%start at 0 noise level
sigNoiseR = [0];
unfiltered = [objectCount(image)];
filtered = [unfiltered];

for level = 1:10
    %need to compute the noise level
    newImage = imnoise(image,'gaussian',0,(0.01*level));
    sigNoiseR = [sigNoiseR snr(image, newImage)];
    
    unfiltered = [unfiltered objectCount(newImage)];
    filtered = [filtered objectCount(thresholdFilter(newImage,image))];
    
    %output to console necessary information
    disp(['Completed gaussian filter ' num2str(level)]);
end

T = table(sigNoiseR', unfiltered', filtered');
T.Properties.VariableNames = {'Gaussian_Noise_Level' 'Objects_found_without_filtering' 'Objects_found_with_filtering'}

%part of the function segment, only collecting the count for objects
function [objectCount] = objectCount(image)
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
    % figure; imshow(binary);
    % don't need to show the image

    se = strel('disk',7);
    cleanedImage = imopen(binary, se);

    cleanedImage = imfill(cleanedImage,'holes');
    cleanedImage = imclearborder(cleanedImage);

    [labels,numLabels] = bwlabel(cleanedImage);
    objectCount = numLabels;
end

function [thresholdFilter] = thresholdFilter(noisy,image);
    %takes the original image and the noisy one and repeats the filter
    %several times or until the snr reaches a low amount
    
    s2nr = snr(image,noisy);
    repetitionCounter = 0;
    %thresholding the signal to noise ratio, but catching scenario where
    %the snr is not decreasing enough through the repetitionCounter
    while s2nr > 0.02 & repetitionCounter < 7
        noisy = noiseFilter(noisy);
        s2nr = snr(image,noisy);
        repetitionCounter = repetitionCounter + 1;
    end
    disp([num2str(repetitionCounter) num2str(s2nr)]);
    thresholdFilter = noisy;
    
end

end