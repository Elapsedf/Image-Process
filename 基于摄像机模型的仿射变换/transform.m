%% 求解外参矩阵
%先求出旋转矩阵与平移矩阵
T=[0;0;-2.9];
%T
% 旋转矩阵
% 先绕x轴转90°，再绕z轴转90°
% Rx=[1 0 0; 0 0 1; 0 -1 0];
% Rz=[0 1 0; -1 0 0; 0  0 1];
% R=Rx*Rz;
R=[0 0 1; 1 0 0; 0 1 0];
%R
% 外参矩阵
m0=zeros(1,3);
m1=ones(4);
M2=[R T; m0 1];
%M2
%% 读入图片及Zc和相机内参
I=[650.1821 0 315.8990; 0 650.5969 240.3104; 0 0 1.0000];
%I=[I,zeros(3,1)];
img=imread("image\1.jpg");
zc1=[37.5 64];
%% 彩转灰，判断位置
img_g=im2gray(img);
imshow(img_g)
%% 识别位置
% 中心的输出是一个两列的矩阵，其中包含图像中圆心的（x，y）坐标。
[circle, radis]=imfindcircles(img_g, [40 200], 'ObjectPolarity','dark','Sensitivity',0.97);
viscircles(circle, radis, 'Color','b');
%% 求解世界坐标
[u1,v1]=deal(circle(1,1),circle(1,2)); %赋值
[u2,v2]=deal(circle(2,1),circle(2,2));
% pos1=inv(R)*(inv(I)*zc(1)*[u1;v1;1]-T);
% pos2=inv(R)*(inv(I)*zc(2)*[u2;v2;1]-T);
pos1=R\(inv(I)*zc1(1)*[u1;v1;1]-T);
pos2=R\(inv(I)*zc1(2)*[u2;v2;1]-T);
%% 距离计算
dis1=norm(pos1);
dis2=norm(pos2);
dis=norm(pos1-pos2);
% fprintf("橘子1到原点的距离为%fcm", dis1);
% fprintf("橘子2到原点的距离为%fcm", dis2);
%% 读入所有图片zc以及调用函数

zc2=[39.5,84];
zc3=[67,84];
zc4=[27,35.5];
zc5=[21,27];
zc6=[26,37];
zc7=[38, 37, 46];
zc8=[33.5, 46, 37];
zc9=[33.5, 46, 29, 37];
dis1=cal_dis("image\1.jpg",zc1,[40,200],'dark',0.97);
dis2=cal_dis("image\2.jpg",zc2,[40,200],'dark',0.97);
dis3=cal_dis("image\3.jpg",zc3,[40,200],'dark',0.97);
dis4=cal_dis("image\4.jpg",zc4,[40,200],'bright',0.97);
dis5=cal_dis("image\5.jpg",zc5,[40,200],'bright',0.97);
dis6=cal_dis("image\6.jpg",zc6,[40,200],'bright',0.97);
dist1=norm(dis1(:,1)-dis1(:,2));
dist2=norm(dis2(:, 1)-dis2(:, 2));
dist3=norm(dis3(:,1)-dis3(:,2));
dist4=norm(dis4(:,1)-dis4(:,2));
dist5=norm(dis5(:,1)-dis5(:,2));
dist6=norm(dis6(:,1)-dis6(:,2));
% fprintf("两圆形物体的距离为%fcm\n", dist1);
% fprintf("两圆形物体的距离为%fcm\n", dist2);
% fprintf("两圆形物体的距离为%fcm\n", dist3);
% fprintf("两圆形物体的距离为%fcm\n", dist4);
% fprintf("两圆形物体的距离为%fcm\n", dist5);
% fprintf("两圆形物体的距离为%fcm\n", dist6);
% dis7=cal_dis("image\7.jpg",zc7,[40,200],0.97,3);
% dis8=cal_dis("image\8.jpg",zc8,[40,200],0.97,3);
% dis9=cal_dis("image\9.jpg",zc9,[40,200],0.97,4);
cal_norm(dis1,1)
cal_norm(dis2,2)
cal_norm(dis3,3)
cal_norm(dis4,4)
cal_norm(dis5,5)
cal_norm(dis6,6)
cal_norm(dis7,7)
cal_norm(dis8,8)
cal_norm(dis9,9)
%% 计算距离，输出结果函数
function []=cal_norm(dis,n) 
for i =1:size(dis,2)
    for j=i:size(dis,2)-1
        dist=norm(dis(:,i)-dis(:, j+1));
        fprintf("第%d张图",n);
        fprintf("从左往右数%d和%d物体的距离为%fcm\n", i,j+1,dist);
    end
end
end

%% 将上图像处理过程封装成函数
function dis=cal_dis(file_path,zc,range,light,sen)
img= imread(file_path);
img_g=im2gray(img);
imshow(img_g)
I=[650.1821 0 315.8990; 0 650.5969 240.3104; 0 0 1.0000];
T=[0;0;-2.9];
R=[0 0 1; 1 0 0; 0 1 0];
while 1
    [circle, radis]=imfindcircles(img_g, range, 'ObjectPolarity',light,'Sensitivity',sen);
    viscircles(circle, radis, 'Color','b');
    if size(zc,2)> size(circle,1)
        sen=sen*1.05;
    elseif size(zc,2) <size(circle,1)
        sen=sen*0.97;
    else
        break
    end
end

row=size(circle,1);
dis_up=[];
for i=1:row
%     [u,v]=ginput;
    [u,v]=deal(circle(i,1),circle(i,2));
    pos=R\(inv(I)*zc(i)*[u;v;1]-T);
    %idx=norm(pos);
    dis_up=[dis_up,pos];
end
dis=dis_up;
end


    