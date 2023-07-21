%% 获取暗通道
I=imread('fog\fog3.jpg');  %读取图片

I=double(I);  %将读入图像I的uint8数据转换为double类型的数据
I=I./255;  %将像素值转换到0~1之间
dark=darkfunction(I);
subplot(1,3,1);imshow(I);
subplot(1,3,2);imshow(dark);  %展示雾图和对应的暗通道

%% 估计A
 % 获取最亮的点
[data_max,index]=max(I(:));
[row,col] = ind2sub(size(I),index);

%取暗通道最亮的地方所对应的有雾图的点
[data_max_d,index_d]=max(dark(:));
[row_d,col_d] = ind2sub(size(dark),index_d);

A=data_max;
w=0.5;  %除雾系数
%% 得到图像
J=remove_fog(I,w,A);
subplot(1,3,3);imshow(J);  %展示去雾图像

%% 除雾函数
function [J]=remove_fog(I,w,A)

%估计t
Rmin=I(:,:,1)./A;
Gmin=I(:,:,2)./A;
Bmin=I(:, :,3)./A;
[m,n]=size(Rmin);
t=zeros(m,n);
for i=1:m   %i从1开始一直循环到m
    for j=1:n
        t(i,j)=min(Rmin(i,j),Gmin(i,j));
        t(i,j)=min(t(i,j),Bmin(i,j));
    end
end

t=1-w.*t;   %注意.*
t0=0.1;
t(t<=t0)=t0;
J(:,:,1)=uint8(((I(:,:,1)-A)./t+A).*255);   %./ 矩阵对应元素相除
J(:,:,2)=uint8(((I(:,:,2)-A)./t+A).*255);
J(:,:,3)=uint8(((I(:,:,3)-A)./t+A).*255); 


end
%% 获取暗通道函数
function [dark] =darkfunction(I)
R=I(:,:,1);  %将I的第一层赋值给R，下面的G、B分别为I的第二、三层
G=I(:,:,2);  %三个参数分别代表行、列和层
B=I(:,:,3);
[m,n]=size(R); %size求取矩阵大小，返回其行列值，即m、n
a=zeros(m,n);  %zeros返回 m x n 大小的零矩阵
for i=1:m   %i从1开始一直循环到m
    for j=1:n
        a(i,j)=min(R(i,j),G(i,j));
        a(i,j)=min(a(i,j),B(i,j));
    end
end
%整个for循环就是求取所有像素的RGB三通道（层）中的最小值，最后得到
%一副和原始图像同样大小的灰度图，即单通道图像
d=ones(15,15); %ones产生15x15的全1矩阵
fun=@(block_struct)min(min(block_struct.data))*d; %最小值滤波
%@(block_struct)为装饰器函数，block_struct.data表示传入的数据（图片或者矩阵）
dark=blockproc(a,[15,15],fun); %blockproc为分块矩阵处理函数
dark=dark(1:m,1:n); 
end

