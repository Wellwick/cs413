function [imageMap] = imageMap(input_image_1, input_image_2, xw, yw, xi, yi)

addpath /modules/cs413
addpath /modules/cs413/camera

H = estimate_homography([xw yw], [xi yi]);
tform = projective2d(inv(H'));
textured = imwarp(input_image_2, tform, 'OutputView', imref2d(size(input_image_1)));

imageMap = input_image_1 + textured;
end