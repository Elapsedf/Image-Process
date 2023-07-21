% 载入图像
I_o = imread('test1.jpeg');
I=rgb2gray(I_o);
% 边缘检测
edges = edge(I); % 这里使用Canny边缘检测方法
edges = ~edges; % 反色，得到白底黑边图像

% 开闭运算
se = strel('rectangle', [10, 20]);
processed_image = imopen(edges, se); % 开运算
processed_image = imclose(processed_image, se); % 闭运算

% 删除过小的连通域
min_area = 200; % 设置最小连通域面积阈值
stats = regionprops(processed_image, 'Area');
areas = [stats.Area];
processed_image = ismember(labelmatrix(bwconncomp(processed_image)), find(areas >= min_area));
figure;
imshow(processed_image)
% 矩形化
[m, n] = size(processed_image);
updated_image = processed_image;

for i = 1:m
    for j = 1:n
        if updated_image(i, j) == 0
            if (i > 1 && j > 1 && updated_image(i-1, j) == 1 && updated_image(i, j-1) == 1) || ...
               (i > 1 && j < n && updated_image(i-1, j) == 1 && updated_image(i, j+1) == 1) || ...
               (i < m && j > 1 && updated_image(i+1, j) == 1 && updated_image(i, j-1) == 1) || ...
               (i < m && j < n && updated_image(i+1, j) == 1 && updated_image(i, j+1) == 1)
                updated_image(i, j) = 1;
            end
        else
            if (i > 1 && j > 1 && updated_image(i-1, j) == 0 && updated_image(i, j-1) == 0) || ...
               (i > 1 && j < n && updated_image(i-1, j) == 0 && updated_image(i, j+1) == 0) || ...
               (i < m && j > 1 && updated_image(i+1, j) == 0 && updated_image(i, j-1) == 0) || ...
               (i < m && j < n && updated_image(i+1, j) == 0 && updated_image(i, j+1) == 0)
                updated_image(i, j) = 0;
            end
        end
    end
end


for i = m:-1:1
    for j = n:-1:1
        if updated_image(i, j) == 0
            if (i > 1 && j > 1 && updated_image(i-1, j) == 1 && updated_image(i, j-1) == 1) || ...
               (i > 1 && j < n && updated_image(i-1, j) == 1 && updated_image(i, j+1) == 1) || ...
               (i < m && j > 1 && updated_image(i+1, j) == 1 && updated_image(i, j-1) == 1) || ...
               (i < m && j < n && updated_image(i+1, j) == 1 && updated_image(i, j+1) == 1)
                updated_image(i, j) = 1;
            end
        else
            if (i > 1 && j > 1 && updated_image(i-1, j) == 0 && updated_image(i, j-1) == 0) || ...
               (i > 1 && j < n && updated_image(i-1, j) == 0 && updated_image(i, j+1) == 0) || ...
               (i < m && j > 1 && updated_image(i+1, j) == 0 && updated_image(i, j-1) == 0) || ...
               (i < m && j < n && updated_image(i+1, j) == 0 && updated_image(i, j+1) == 0)
                updated_image(i, j) = 0;
            end
        end
    end
end
% for i = 1:m
%     for j = n:-1:1
%         if updated_image(i, j) == 0
%             if (i > 1 && j > 1 && updated_image(i-1, j) == 1 && updated_image(i, j-1) == 1) || ...
%                (i > 1 && j < n && updated_image(i-1, j) == 1 && updated_image(i, j+1) == 1) || ...
%                (i < m && j > 1 && updated_image(i+1, j) == 1 && updated_image(i, j-1) == 1) || ...
%                (i < m && j < n && updated_image(i+1, j) == 1 && updated_image(i, j+1) == 1)
%                 updated_image(i, j) = 1;
%             end
%         else
%             if (i > 1 && j > 1 && updated_image(i-1, j) == 0 && updated_image(i, j-1) == 0) || ...
%                (i > 1 && j < n && updated_image(i-1, j) == 0 && updated_image(i, j+1) == 0) || ...
%                (i < m && j > 1 && updated_image(i+1, j) == 0 && updated_image(i, j-1) == 0) || ...
%                (i < m && j < n && updated_image(i+1, j) == 0 && updated_image(i, j+1) == 0)
%                 updated_image(i, j) = 0;
%             end
%         end
%     end
% end
% for i = m:-1:1
%     for j = 1:n
%         if updated_image(i, j) == 0
%             if (i > 1 && j > 1 && updated_image(i-1, j) == 1 && updated_image(i, j-1) == 1) || ...
%                (i > 1 && j < n && updated_image(i-1, j) == 1 && updated_image(i, j+1) == 1) || ...
%                (i < m && j > 1 && updated_image(i+1, j) == 1 && updated_image(i, j-1) == 1) || ...
%                (i < m && j < n && updated_image(i+1, j) == 1 && updated_image(i, j+1) == 1)
%                 updated_image(i, j) = 1;
%             end
%         else
%             if (i > 1 && j > 1 && updated_image(i-1, j) == 0 && updated_image(i, j-1) == 0) || ...
%                (i > 1 && j < n && updated_image(i-1, j) == 0 && updated_image(i, j+1) == 0) || ...
%                (i < m && j > 1 && updated_image(i+1, j) == 0 && updated_image(i, j-1) == 0) || ...
%                (i < m && j < n && updated_image(i+1, j) == 0 && updated_image(i, j+1) == 0)
%                 updated_image(i, j) = 0;
%             end
%         end
%     end
% end
processed_image = updated_image;

figure;
imshow(processed_image)
% 选择区域
se_open = strel('rectangle', [5, 5]);
se_close = strel('rectangle', [10, 20]);
opened_image = imopen(processed_image, se_open);
closed_image = imclose(opened_image, se_close);

% 计算垂直投影函数
vertical_projection = sum(closed_image, 1);

% 参数设定
ratio_range = [2, 8];
count_range = [15, 45];
blue_threshold = 0.7;

% 选择车牌区域
[L, num] = bwlabel(processed_image, 4);
region_props = regionprops(L, 'Area', 'BoundingBox');
selected_regions = [];
for i = 1:num
    region_area = region_props(i).Area;
    region_box = region_props(i).BoundingBox;
    
    % 矩形长宽比
    ratio = region_box(3) / region_box(4);
    
    % 区域蓝色像素点所占比例
    hsv_image = rgb2hsv(I_o);
    blue_pixels = hsv_image(floor(region_box(2)):floor(region_box(2)+region_box(4)), floor(region_box(1)):floor(region_box(1)+region_box(3)), 1) > 0.5;
    blue_ratio = sum(blue_pixels(:)) / region_area;
    
    % 候选区域垂直投影函数与平均值交点个数
    projection_count = sum(vertical_projection(round(region_box(1)):round(region_box(1)+region_box(3))) > mean(vertical_projection)) - 1;
    
    % 进行筛选
    if ratio >= ratio_range(1) && ratio <= ratio_range(2) && blue_ratio >= blue_threshold && projection_count >= count_range(1) && projection_count <= count_range(2)
        selected_regions = [selected_regions, region_box];
    end
end

% 在原图像上绘制选择的车牌区域
figure;
imshow(I);
hold on;
for i = 1:size(selected_regions, 2)
    rectangle('Position', selected_regions(:,i), 'EdgeColor', 'g', 'LineWidth', 2);
end
hold off;
