function output = MTHT(image, time, block1,block2, weight)
% weight：取值应该（0,0.25]范围内.
% 在一定范围内，取值越大，图像轮廓会越清晰，但是超过阈值后，权重继续增大会导致噪点过多.

if ~exist('time', 'var')
    time = 10;
end

if ~exist('block1', 'var')
    block1 =  cb_structure(15,15,1);
end
 
if ~exist('block2', 'var')
    block2 = cb_structure(5,5,1);
end

if ~exist('weight', 'var')
    weight = 0.1;
end

[m, n, d] = size(image);
THNM = zeros(m,n,d);
BHNM = zeros(m,n,d);
THNSM = zeros(m,n,d);
BHNSM = zeros(m,n,d);

for i = 1 : time
    
    THN = image - imclose((imopen(image, block1)),block2);
    BHN = imopen((imclose(image, block1)),block2) - image;
    
    THNM = THNM + THN;
    BHNM = BHNM + BHN;
    
    if i > 1
        THNS = THN - T;
        BHNS = BHN - B;
        
        THNSM = THNSM + THNS;
        BHNSM = BHNSM + BHNS;
        
        T = THN;
        B = BHN;
    else
        T = THN;
        B = BHN;
    end
end

if i == 1
    detail = THN - BHN;
else  
    detail = (THNM + THNSM) - (BHNM + BHNSM);
end
    detail = imguidedfilter(detail,image);
    output = image + weight * detail;
    
end