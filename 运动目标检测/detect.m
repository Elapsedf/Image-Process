%% 视频读取
clc;
clear;
v=VideoReader("../视频数据集/001.mp4");
s=read(v,1);
%imshow(s);
[m,n,c]=size(s);
r=zeros(m,n);
g=zeros(m,n);
b=zeros(m,n);
back=zeros(m,n,3);
%% 背景提取
for i=1:250
    s=read(v,i);
    r=r+double(s(:,:,1));
    g=g+double(s(:,:,2));
    b=b+double(s(:,:,3));
end
back(:,:,1)=r./250;
back(:,:,2)=g./250;
back(:,:,3)=b./250;
figure;
imshow(uint8(back));
[x,y]=ginput(5);
mask = poly2mask(x,y,m,n);  %生成掩膜
mask2=im2double(mask);
back=mask2.*back;
%% 二值化
back_g=rgb2gray(uint8(back));
figure;
imshow(back_g);
selected_regions=[];
W=fspecial("gaussian",[5,5],1);

for i=1:250
    s=read(v,i);
    s_g=rgb2gray(s);
    %s_2=double(s_g);
    diff=uint8(abs(double(s_g)-double(back_g)));%此处要转成double型相减，uint8减完会成0
    %thresh2=graythresh(diff);
    diff=imbinarize(diff,0.05);
    diff=imfilter(diff,W,"replicate");
    imshow(diff);
    %膨胀和腐蚀
    % 形态学处理
    se_open=strel("rectangle",[7,15]);
    se_close=strel("rectangle",[12,24]);
    %imshow(im_open);
    im_open=imopen(diff,se_open);
    im_close=imclose(im_open,se_close);
    %im_close=imclose(im_close,se_open);
    %imshow(im_close);
    
    [L,num]=bwlabel(im_close,8);
    stats=regionprops(L,"BoundingBox");
    %figure;
    %imshow(s);
    %hold on;
    for j = 1:numel(stats)
        box = stats(j).BoundingBox;
        aspect_ratio = box(3) / box(4);
        if aspect_ratio > 0.2
            selected_regions=[selected_regions;box];
        end
        for k = 1:size(selected_regions, 1)
            rectangle('Position', selected_regions(k, :), 'EdgeColor', 'r', 'LineWidth', 2);
        end
    end
    pause(1)
    selected_regions=[];
    %hold off;
end



    
    