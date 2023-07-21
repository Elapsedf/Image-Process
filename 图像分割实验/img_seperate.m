%% 预处理边缘检测+开闭运算
img=imread("test1.jpeg");
img_2=rgb2gray(img);
im_edge=edge(img_2);
im_edge=~im_edge;       %取反！
imshow(im_edge);
se=strel("rectangle",[10,20]);
im_open=imopen(im_edge,se);
figure;
imshow(im_open);
im_close=imclose(im_open,se);
figure;
imshow(im_close);
global im_close;
%% 矩形化
[rows,cols]=size(im_close);

% for i=2:rows-1
%     for j=2:cols-1
%         if im_close(i,j)==0
%             if iswhite(i,j)
%                 im_close(i,j)=1;
%                 continue;
%             end
%         end
%         if im_close(i,j)==1
%             if isblack(i,j)
%                 im_close(i,j)=0;
%                 continue;
%             end
%         end
%     end
% end
retangle(rows,cols);
figure;
imshow(im_close);
%% 选择区域
%颜色判断：首先将rgb图像转化为hsv颜色模型，
% 然后统计每个候选车牌的蓝色像素点数量（先验知识：在整个车牌中，蓝色背景像素占整个车牌的70%），
% 当蓝色像素点数量大于设定阈值时，该候选区域判断为车牌区域（颜色特征判断不能确定唯一的车牌区域，
% 比如马路上行驶的车辆（有车牌）、蓝色电瓶车、护栏上的蓝色贴纸）；

%长宽比判断：车牌的标准尺寸为440mmx140mm， 
% 标准长高比约为3.1，通过把候选车牌区域标记成一个方形，计算方形的长和宽，
% 通过设定一定的长宽比阈值，再次筛选候选车牌区域
% 颜色判断
% 获取所有矩形区域
[L, num] = bwlabel(~im_close,8);
stats = regionprops(L, 'Area','BoundingBox');
% 参数设定
ratio_range = [2, 8];
count_range = [15, 45];
blue_threshold = 0.7;

% 颜色判断和长宽比判断
selected_regions = [];
for i = 1:numel(stats)
    region_area = stats(i).Area;
    if region_area>20000
        continue
    end
    box = stats(i).BoundingBox;
    aspect_ratio = box(3) / box(4);
    hsv_img = rgb2hsv(img);
    % 颜色判断
    if box(2)==0.5 
        box(2)=1;
    end
    if box(1)==0.5 
        box(1)=1;
    end
    hsv_roi = hsv_img(floor(box(2)):floor(box(2)+box(4)), floor(box(1)):floor(box(1)+box(3)),:);
    roi_blue_pixels = hsv_roi(:, :, 1) > 0.5 & hsv_roi(:, :, 1) < 0.667;
    blue_roi_ratio = sum(roi_blue_pixels(:)) / numel(roi_blue_pixels);
    
    % 长宽比判断和其他条件判断
    if aspect_ratio > 0.3 && aspect_ratio < 3.5 && blue_roi_ratio > 0.7
        selected_regions = [selected_regions; box];
    end
end

% 在原图上标记选定的车牌区域
figure;
imshow(img);
hold on;
for i = 1:size(selected_regions, 1)
    rectangle('Position', selected_regions(i, :), 'EdgeColor', 'r', 'LineWidth', 2);
end
hold off;

%% 图像分割
%基于全局的阈值分割
% 提取候选框内的图像区域
region_image = imcrop(img_2, selected_regions);

% 计算图像区域的全局阈值
threshold = graythresh(region_image);

% 对图像区域进行二值化分割
binary_image_1 = imbinarize(region_image, threshold);

% 显示分割结果
figure;
subplot(1, 2, 1);
imshow(region_image);
title('原始图像区域');
subplot(1, 2, 2);
imshow(binary_image_1);
title('基于全局的阈值分割结果');
% 基于局部的阈值分割（bernsen）

% 设置局部阈值分割参数
window_size = 15; % 窗口大小
contrast_threshold = 15; % 对比度阈值

% 对图像区域进行基于局部的阈值分割
binary_image_2 = local_threshold_segmentation(region_image, window_size, contrast_threshold);

% 显示分割结果
figure;
subplot(1, 2, 1);
imshow(region_image);
title('原始图像区域');
subplot(1, 2, 2);
imshow(binary_image_2);
title('基于局部的阈值分割结果');

%% 字符分离
%由于此处图像分割时会有少数白边进入图像中，所以此处如果利用栅栏法进行字符分割效果
figure;
B = logical(sum(binary_image_1,1));
plot(B);
% 假设您已经完成字符分割并将每个字符保存为单独的图像文件

% % 导入Tesseract OCR MATLAB接口库
% addpath('D:\OCR\tesseract.exe');
% 
% % 创建Tesseract OCR对象
% ocrEngine = OCREngine;
% 
% % 设置Tesseract OCR语言
% ocrEngine.SetLanguage('eng'); % 设置识别英文字符
% 
% % 对每个字符图像进行OCR识别
% num_characters = num_chars_in_test_image; % 根据实际情况设置字符数
% recognized_characters = cell(num_characters, 1);
% 
% for i = 1:num_characters
%     % 读取字符图像
%     character_img = imread(sprintf('character_%d.jpg', i));
%     
%     % 对字符图像进行OCR识别
%     recognized_text = ocrEngine.Recognize(character_img);
%     
%     % 将识别结果添加到识别字符列表中
%     recognized_characters{i} = recognized_text;
% end
% 
% % 显示识别结果
% disp('OCR识别结果：');
% disp(recognized_characters);
