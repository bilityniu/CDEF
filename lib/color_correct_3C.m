function output = color_correct_3C(image, k, landa)


if ~exist('k', 'var')
    k = 1.0;
end

if ~exist('landa', 'var')
    landa = 0.3;
end

[m, n, ~] = size(image);

im_gray = im2double(rgb2gray(image));

im_gray(im_gray>0.85) = 0; 
im_gray(im_gray<=0.85) = 1; 


lab = rgb2lab(image);


I_L = lab(:,:,1);
I_a = lab(:,:,2);
I_b = lab(:,:,3);


gausFilter = fspecial('gaussian', [20,20],1);
gaus_a= imfilter(I_a, gausFilter, 'replicate');
gaus_b= imfilter(I_b, gausFilter, 'replicate');
mask = imfilter(im_gray, gausFilter, 'replicate');

Ic_a = I_a - k * mask .*  gaus_a;
Ic_b = I_b - landa * mask .* gaus_b;


lab(:,:,1) = (I_L);

lab(:,:,2) = Ic_a;
lab(:,:,3) = Ic_b;

output = lab2rgb(lab);
output = im2uint8(output);
end

