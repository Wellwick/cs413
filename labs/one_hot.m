function [one_hot] = one_hot(array)
%ONE_HOT turns a one dimensional array into one hot encodings

zeroEncoding = [1 0 0 0 0];
oneEncoding = [0 1 0 0 0];
twoEncoding = [0 0 1 0 0];
threeEncoding = [0 0 0 1 0];
fiveEncoding = [0 0 0 0 1];

%
%switch(array(1))
%    case 0
%        newArray = zeroEncoding;
%    case 1
%        newArray = oneEncoding;
%    case 2
%        newArray = twoEncoding;
%    case 3
%        newArray = threeEncoding;
%    case 5
%        newArray = fiveEncoding;
%end

s = size(array);
newArray = zeros(s(2),5);

for x = 1:s(2)
    switch(array(x))
        case 0
            newArray(x,:) = zeroEncoding;
        case 1
            newArray(x,:) = oneEncoding;
        case 2
            newArray(x,:) = twoEncoding;
        case 3
            newArray(x,:) = threeEncoding;
        case 5
            newArray(x,:) = fiveEncoding;
    end
end

one_hot = newArray;