function [thresholdColours] = thresholdColours(image)

red = image(:,:,1);
green = image(:,:,2);
blue = image(:,:,3);

red_logic = red>60;
green_logic = green>60;
blue_logic = blue>60;

%let's show them
%figure;
%subplot(1,3,1); imshow(red_logic); title('Red thresholded');
%subplot(1,3,2); imshow(green_logic); title('Green thresholded');
%subplot(1,3,3); imshow(blue_logic); title('Blue thresholded');

thresholdColours = cat(3,red_logic*255,green_logic*255,blue_logic*255);

end