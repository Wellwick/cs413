function [blendImages] = blendImages(image1, image2, alpha)
%BLENDIMAGES blends together tow images based on the alpha factor
%   Alpha value must be between 0-1

image1 = image1 .* alpha;
image2 = image2 .* (1-alpha);

blendImages = image1 + image2;
