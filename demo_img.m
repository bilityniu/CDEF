% CDEF: Underwater Scene Enhancement via Adaptive Color Analysis and Multi-Space Fusion

clc, clear all
close all

addpath('./lib', './EF', './IDE');

% Configuration
input_dir = './Images/';          % Input directory
output_dir = './Results/';        % Output directory


% Create output directory if it doesn't exist
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Batch processing
image_formats = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
image_files = [];

% Get all image files
for i = 1:length(image_formats)
    files = dir(fullfile(input_dir, image_formats{i}));
    image_files = [image_files; files];
end

num_images = length(image_files);

if num_images == 0
    fprintf('No image files found in %s\n', input_dir);
    return;
end

fprintf('Found %d images to process...\n', num_images);

for i = 1:num_images
    input_path = fullfile(input_dir, image_files(i).name);
    [~, name, ext] = fileparts(image_files(i).name);
    output_path = fullfile(output_dir, [name '_CDEF' ext]);

    fprintf('Processing [%d/%d]: %s... ', i, num_images, image_files(i).name);

    try
        tic;
        process_image(input_path, output_path);
        elapsed_time = toc;
        fprintf('Done! (%.2f seconds)\n', elapsed_time);
    catch ME
        fprintf('Failed! Error: %s\n', ME.message);
    end
end

fprintf('CDEF processing completed!\n');


% Image processing function
function process_image(input_path, output_path)
    % Read image
    image = imread(input_path);
    
    % BIMEF enhancement
    high_light = BIMEF(image);
    
    % Color correction based on channel mean values
    MeanG = mean(mean(image(:,:,2)));
    MeanB = mean(mean(image(:,:,3)));
    
    if MeanG > MeanB
        Rgb = color_correct_3C(high_light, 0.5, 0.15);
    else
        Rgb = color_correct_3C(high_light, 1.0, 0.3);
    end
    
    %     % Alternative parameters for more robust results (may slightly decrease metrics)
    %     if MeanG > MeanB
    %         Rgb = color_correct_3C(high_light, 0.5, 0.25);
    %     else
    %         Rgb = color_correct_3C(high_light, 1.0, 0.5);
    %     end
    
    % Color balance processing
    fusion1 = colorBalance(Rgb, 'underwater');
    fusion2 = simple_color_balance(Rgb, 0.01);
    
    % Select base image based on channel means
    if MeanG > MeanB
        im_main = im2double(fusion1);
        im2 = fusion2;
    else
        im_main = im2double(fusion2);
        im2 = fusion1;
    end
    
    % Local detail sharpening enhancement
    kernel1 = cb_structure(15, 15, 1);
    kernel2 = cb_structure(5, 5, 1);
    fusion3 = MTHT(im_main, 10, kernel1, kernel2, 0.1);
    
    % Gobal detail dehazing enhancement
    fusion4 = IDE(im_main);
    
    % Combine all fusion results
    II(:,:,:,1) = im2double(fusion1);
    II(:,:,:,2) = im2double(fusion2);
    II(:,:,:,3) = im2double(fusion3);
    II(:,:,:,4) = im2double(fusion4);
    
    % Calculate mean values and sort
    [h,w,c,n] = size(II);
    meann = zeros(1, n);
    for ii = 1:n
        meann(ii) = mean(mean(mean(II(:,:,:,ii))));
    end
    [~, index] = sort(meann);
    
    % Convert to YCbCr color space
    dst = zeros(h, w, c, n);
    for jj = 1:n
        I = II(:,:,:,index(jj));
        dst(:,:,:,jj) = rgb2ycbcr(I);
    end
    
    % CDEF fusion
    R = cdef_fusion(dst, [2 1 1 2]);
    
    % Convert back to RGB and save
    FR = ycbcr2rgb(R);
    FR = im2uint8(FR);
    
    % Save result
    imwrite(FR, output_path);
end