function [linInter] = linInter(m, n, o)
%LININTER creates a row vector of length o where values m to n are
%interpolated

row = [m,n];

linInter = imresize(row, [1 o], 'bilinear');

end
