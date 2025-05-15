function  output = simple_color_balance(image,a)

if ~exist('a', 'var')
    a = 0.01;
end

num = 255;

r = image(:, :, 1);
g = image(:, :, 2);
b = image(:, :, 3);

Ravg = mean(mean(r));
Gavg = mean(mean(g));
Bavg = mean(mean(b));

avgRGB = [Ravg, Gavg, Bavg];
grayValue = (Ravg + Gavg + Bavg)/3;
scaleValue = grayValue./avgRGB;
satLevel =  a * scaleValue;

if satLevel>1
    satLevel = 1;
end

if satLevel <0
    satLevel = 0;
end

[m,n,p] = size(image);
imgRGB_orig = zeros(p, m*n);

for i = 1 : p
   imgRGB_orig(i, : ) = reshape(double(image(:, :, i)), [1, m * n]);
end

imRGB = zeros(size(imgRGB_orig));

%直方图对比度调整
for ch = 1 : p
    q = [satLevel(ch), 1 - satLevel(ch)];
    tiles = quantile(imgRGB_orig(ch, :), q);

    temp = imgRGB_orig(ch, :);
    temp(find(temp < tiles(1))) = tiles(1);
    temp(find(temp > tiles(2))) = tiles(2);
    imRGB(ch, :) = temp;
    channel_var=std2(imgRGB_orig(ch, :));
    
    alpha = 0;
    pmin = min(imRGB(ch, :)) - alpha * channel_var;
    pmax = max(imRGB(ch, :)) + alpha * channel_var;
    imRGB(ch, :)  =  (imRGB(ch, :) - pmin) * num /(pmax - pmin);
end

if ndims(image)==3
    outval=zeros(size(image));
    for i=1:p
        outval(:,:,i)=reshape(imRGB(i,:),[m,n]);
    end
else
    outval=reshape(imRGB,[m,n]);
end

output = uint8(outval);

end
