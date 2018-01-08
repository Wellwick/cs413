function [convolute] = convolute(image)

gray = rgb2gray(image);
kern3 = ones(3,3)/9;
convolute = conv2(double(gray), double(kern3), 'same');
difference = convolute - double(gray);
figure; 
%subplot(1,2,1); 
imshow(image);
%subplot(1,2,2); 
figure; imshow(10 * uint8(difference));
end