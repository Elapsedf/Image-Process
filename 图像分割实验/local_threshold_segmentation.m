function binary_image = local_threshold_segmentation(image, window_size, contrast_threshold)
    % 获取图像尺寸
    [m, n] = size(image);
    
    % 初始化二值化图像
    binary_image = zeros(m, n);
    
    % 遍历图像的每个像素
    for i = 1:m
        for j = 1:n
            % 计算局部窗口的边界
            row_start = max(1, i - floor(window_size / 2));
            row_end = min(m, i + floor(window_size / 2));
            col_start = max(1, j - floor(window_size / 2));
            col_end = min(n, j + floor(window_size / 2));
            
            % 提取局部窗口的像素值
            window = image(row_start:row_end, col_start:col_end);
            
            % 计算局部窗口的平均值和对比度
            mean_value = mean(window(:));
            contrast = max(window(:)) - min(window(:));
            
            % 根据局部阈值进行二值化
            if contrast <= contrast_threshold
                binary_image(i, j) = 0;
            else
                binary_image(i, j) = (image(i, j) > mean_value);
            end
        end
    end
end
