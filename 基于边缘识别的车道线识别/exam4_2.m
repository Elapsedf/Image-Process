img=imread("图片/2.jpg");
%
img2=im2double(img);
%% 选取ROI区域生成蒙版图像
img2=rgb2gray(img2);

[m,n]=size(img2);
imshow(img2);
[x,y]=ginput(4);
%蒙版图片生成
mask = poly2mask(x,y,m,n);  %生成掩膜
mask2=im2double(mask);
Newimage=mask2.*img2;
%% 对蒙版图片进行边缘识别

st=edge_recog(Newimage);


%% 霍夫变换识别直线边缘
lines=HoughStrightrecognize(st);
len=length(lines);

min_x = 0;
max_x = 52.5;
min_y = 0;
max_y = 20;
% imagesc([min_x max_x], [min_y max_y], flipdim(img2,1));
imshow(img2);
hold on
for i=1:len
    xy=[lines(i).point1; lines(i).point2];
    angle=atan2(xy(1,2)-xy(2,2),xy(1,1)-xy(2,1))*180/pi;
    disp(angle);
    if angle>175 || angle <-175
        continue
    end
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    hold on
end

%% 根据先验知识对直线进行筛选
% 此处我们选择直线的模场与角度

%% 霍夫变换函数
function lines=HoughStrightrecognize(BW)
[H,T,R]=hough(BW);
P=houghpeaks(H,5,'Threshold',ceil(0.3*max(H(:))));
lines=houghlines(BW,T,R,P,"FillGap",5,"MinLength",7);
end



%% 边缘识别函数
function st=edge_recog(image)
%高斯滤波
W=fspecial("gaussian",[5,5],1);
img_new=imfilter(image,W,"replicate");
%使用sobel算子计算梯度
[rows,cols] = size(img_new);
mask_X = [-1 -2 -1;...
           0  0  0;...
           1  2  1];
mask_Y = [-1 0 1;...
          -2 0 2;...
          -1 0 1;];
dstImg=img_new;
gradx=zeros(rows,cols);
grady=zeros(rows,cols);
for i = 1:rows-2
    for j = 1:cols-2
        tempx = mask_X.*img_new(i:i+2,j:j+2);
        tempy = mask_Y.*img_new(i:i+2,j:j+2);
        temp_X = sum(tempx(:));
        temp_Y = sum(tempy(:));
        %dstImg(i+1,j+1) = abs(temp_X)+abs(temp_Y);
        dstImg(i+1,j+1)=sqrt((temp_X^2)+(temp_Y^2));
        gradx(i,j)=temp_X;
        grady(i,j)=temp_Y;
    end
end
%非最大值抑制
output=NMS_algo(dstImg,gradx,grady);
%阈值处理
jd=double(output);
st = zeros(rows,cols);%定义一个双阈值图像
TL = 0.1 * max(max(jd));%低阈值
TH = 0.3* max(max(jd));%高阈值
for i = 1  : rows
    for j = 1 : cols
        if (jd(i, j) < TL)
            st(i,j) = 0;
        elseif (jd(i, j) > TH)
            st(i,j) = 1 ;
        %对TL < Nms(i, j) < TH 使用8连通区域确定
        elseif (jd(i, j)<TH&&jd(i, j)>TL)
            su =[jd(i-1,j-1), jd(i-1,j), jd(i-1,j+1);
                       jd(i,j-1),    jd(i,j),   jd(i,j+1);
                       jd(i+1,j-1), jd(i+1,j), jd(i+1,j+1)];
            Max = max(su);
            if Max>=TH
                st(i,j) = 1 ;
            end

        end
    end
end
end
%% 非极大值抑制
function output = NMS_algo(grad,gradx,grady)
% 非极大值抑制函数
grad = double(grad);
[h,w] = size(grad);
% 初始化结果
result = zeros(h,w);
% 抑制算法实现
% 用线性插值算出梯度方向上亚像素点的梯度值
% 权重初始化
weight = zeros(h,w);
% 各像素点梯度值初始化
grad1 = zeros(h,w);
grad2 = zeros(h,w);
grad3 = zeros(h,w);
grad4 = zeros(h,w);
gradTemp1 = zeros(h,w);
gradTemp2 = zeros(h,w);
for i = 2:(h-1)
    for j = 2:(w-1)
        % 梯度为0的点直接在结果中置0
        if grad(i,j) == 0
            result(i,j) = 0;
        % 对于梯度不为0的点
        else
            % y方向梯度大于x方向梯度
            if abs(grady(i,j)) > abs(gradx(i,j))
                % 计算权重
                weight(i,j) = abs(gradx(i,j))/abs(grady(i,j));
                % 中心点上下两点
                grad2(i,j) = grad(i-1,j);
                grad4(i,j) = grad(i+1,j);
                % gradx和grady同号
                if gradx(i,j) * grady(i,j) > 0
                    % 插值用到的另外两点
                    grad1(i,j) = grad(i-1,j-1);
                    grad3(i,j) = grad(i+1,j+1);
                % gradx和grady异号
                else
                    grad1(i,j) = grad(i-1,j+1);
                    grad3(i,j) = grad(i+1,j-1);
                end
            % y方向梯度小于x方向梯度
            else
                weight(i,j) = abs(grady(i,j))/abs(gradx(i,j));
                grad2(i,j) = grad(i,j-1);
                grad4(i,j) = grad(i,j+1);
                % gradx和grady同号
                if gradx(i,j) * grady(i,j) > 0
                    grad1(i,j) = grad(i+1,j-1);
                    grad3(i,j) = grad(i-1,j+1);
                % gradx和grady异号    
                else
                    grad1(i,j) = grad(i-1,j-1);
                    grad3(i,j) = grad(i+1,j+1);
                end
            end
        end
        % 插值计算计算两个亚像素点梯度值
        gradTemp1(i,j) = weight(i,j) * grad1(i,j) + (1 - weight(i,j)) * grad2(i,j);
        gradTemp2(i,j) = weight(i,j) * grad3(i,j) + (1 - weight(i,j)) * grad4(i,j);
        % 比较中心像素点和两个亚像素点的梯度值
        if (grad(i,j) >= gradTemp1(i,j) && grad(i,j) >= gradTemp2(i,j))
            % 中心点在其邻域内为极大值，在结果中保留其梯度值
            result(i,j) = grad(i,j);
        else
            % 否则的话，在结果中置0
            result(i,j) = 0;
        end     
    end
end
output = im2uint8(result);      %注意！
end