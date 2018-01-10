function [rgb2normrgb] = rgb2normrgb(image)
%RGB2NORMRGB Normalises the RGB value of an image

red = image(:,:,1);
green = image(:,:,2);
blue = image(:,:,3);

sizeOfRed = size(red);
redNew = red;
greenNew = green;
blueNew = blue;

%for x = 1:sizeOfRed(1)
%    for y = 1:sizeOfRed(2)
%        redNew(x,y) = red(x,y) / (red(x,y)+green(x,y)+blue(x,y));
%        greenNew(x,y) = green(x,y) / (red(x,y)+green(x,y)+blue(x,y));
%        blueNew(x,y) = blue(x,y) / (red(x,y)+green(x,y)+blue(x,y));
%    end
%end

redNew = red ./ (red + green + blue);
greenNew = green ./ (red + green + blue);
blueNew = blue ./ (red + green + blue);

rgb2normrgb = cat(3, redNew, greenNew, blueNew);