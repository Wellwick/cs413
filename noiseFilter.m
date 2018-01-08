function [noiseFilter] = noiseFilter(image)
% Method to filter out noise before segmenting

r = medfilt2(image(:,:,1));
g = medfilt2(image( :,:,2));
b = medfilt2(image(:,:,3));

noiseFilter = cat(3, r, g, b);

end