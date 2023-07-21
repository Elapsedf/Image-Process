img=imread("demo3.jpg");
img_g=rgb2gray(img);
img_g=im2double(img_g);
%% 添加运动模糊
psf1=fspecial("motion",50,34);
psf2=fspecial("motion",50,80);
%img_g=ginput(4); 
Blur1=imfilter(img_g,psf1,'circular','conv');
Blur2=imfilter(img_g,psf2,'circular','conv');
%% 添加高斯噪声
image_no01=imnoise(img_g,'gaussian',0, 0.01);
image_no02=imnoise(img_g,'gaussian',0, 0.01);
image_no1=imnoise(Blur1, 'gaussian',0, 0.001);
image_no2=imnoise(Blur2, 'gaussian',0, 0.001);
%% imshow
figure;
subplot(2,3,1);
imshow(img_g);
title("原图")
subplot(2,3,2);
imshow(Blur1);
title("添加len=50，theta=70的模糊");
subplot(2,3,3);
imshow(Blur2);
title("添加len=14,theta=62运动模糊");
subplot(2,3,4);
imshow(image_no1);
title('添加均值为0，方差为0.001的高斯噪声(theta=0)')
subplot(2,3,5);
imshow(image_no2);
title('添加均值为0，方差为0.001的高斯噪声(theta=90)')
result1=wiener(psf1,image_no01,img_g,Blur1);
result2=wiener(psf2,image_no02,img_g,Blur2);
figure;
subplot(2,2,1);
imshow(image_no1)
title('添加均值为0，方差为0.001的高斯噪声(theta=34)')

subplot(2,2,2);
imshow(result1)
title("theta=34的还原图像（有噪声）")
% 
% result3=wiener(psf1,img_g,img_g,Blur1);
% result4=wiener(psf2,img_g,img_g,Blur2);
% subplot(2,3,3);
% imshow(im2uint8(result3))
% title("theta=0的还原图像（无噪声）")
% 
subplot(2,2,3);
imshow(image_no2);
title('添加均值为0，方差为0.001的高斯噪声(theta=80)')
subplot(2,2,4);
imshow(result2)
title("theta=80的还原图像（有噪声）")



%% 添加维纳滤波器
function result=wiener(psf2,image_no,img_g,Blur2)
[h,w]=size(image_no);
H=fft2(psf2,h,w);
N=fft2(image_no-img_g);
F=fft2(img_g);
NSR=(abs(N).^2)./(abs(F).^2);
F_hat=(1./H).*((abs(H).^2)./((abs(H).^2)+NSR+eps));
G=fft2(Blur2);
F_final=F_hat.*G;
F_t=ifft2(F_final);
result=F_t;
%result=deconvwnr(Blur2,psf2,0.001);
end