%% 选取图片变换
img=imread("affine\affine2_1.jpg");
I = imread('cameraman.tif');
M=[0 1 0; -1 0 0; 0 0 1];       %旋转变换
T=maketform('affine', M);
%imtransform
img_t=imtransform(img,T);   
% imwarp
tform = affine2d([1 0 0; .5 1 0; 0 0 1]);   %剪切变换
J = imwarp(I,tform);
%imshow
figure;
% subplot(2,2,1);
% imshow(img);
% subplot(2,2,2);
% imshow(img_t);
% subplot(2,2,3);
% imshow(I);
% subplot(2,2,4);
% imshow(J)
%% 将任务图矫正
% 示例：只需将任务图往右倾斜即可
xita=-40*pi/180;    %旋转角度
tform2 = affine2d([cos(xita) sin(xita) 0; (-sin(xita)) cos(xita) 0; 0 0 1]);
tform3 = affine2d([2 0 0; 4 2 0; 0 0 1]);
img_s=imwarp(img,tform3);
imshow(img_s);
%% 任务图，先将其旋转一定角度，再将其向右倾斜
img2=imread("affine\affine2_2.jpg");
S=[2*cos(xita) sin(xita) 0; 3*(-sin(xita)) 2*cos(xita) 0; 0 0 1];
% 相乘得仿射变换
T2=maketform('affine', S);
img2_s=imtransform(img2,T2);
% img2_s=imwarp(img2, tform2);
imshow(img2_s);

image1 = imread('affine/affine3_1.jpg');
image2 = imread('affine/affine3_2.jpg');

% 将图像转换为二值图像
bw = im2bw(image1);

% 使用 regionprops 函数找到黑色矩形区域
stats = regionprops(bw, 'BoundingBox', 'Area');

% 遍历每个找到的区域，筛选面积较大的黑色矩形
maxArea=10;
index=0;
for i = 1:numel(stats)
    if stats(i).Area > maxArea
        maxArea=stats(i).Area;
        index=i;
        % 找到一个面积较大且大小符合要求的黑色矩形，进行处理
        % stats(i).BoundingBox 是该区域的边界框信息，可以用来获取矩形的位置和大小
        % 具体的处理逻辑根据需求进行编写
        %disp('Found a black rectangle.');
        
    end
end
stats(index).BoundingBox
% 计算仿射变换矩阵
tform = fitgeotrans([1 1; size(image1, 2)-200 40; 1 size(image1, 1); 2657 1866], ...
                    [1 1; size(image2, 2) 1; 50 size(image2, 1)-50; size(image2, 2) size(image2, 1)], 'affine');

% 对image1进行仿射变换
image1_transformed = imwarp(image1, tform, 'OutputView', imref2d(size(image2)));

% 将两张图像进行融合
blended_image = imfuse(image1_transformed, image2, 'blend');

% 显示结果
imshow(blended_image);
