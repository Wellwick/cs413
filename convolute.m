function [convolute] = convolute(image)

gray = rgb2gray(image);
kern3 = ones(3,3)/9;
convolute = conv2(double(gray), double(kern3), 'same');
difference = convolute - double(gray);
figure; 
%subplot(1,2,1); 
imshow(image);
%subplot(1,2,2); 
figure; 
hold on;
imshow(10 * uint8(difference));
title('Convolution of image');
hold off;

pause(0.3);

end