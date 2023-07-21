I=imread("fog\fog3.jpg");
%I=double(I);
I_dark=im2gray(I);
H=histeq(I_dark);
subplot(3,4,1); imshow(I_dark);
title("原图");


A=fspecial("average");
AI=imfilter(I_dark,A,'replicate');
subplot(3,4,2);imshow(AI);
title("均值滤波3*3");

% MI=medfilt3(I);
% subplot(2,3,5);imshow(MI);
% title("中值滤波");
A_5=fspecial("average",[5,5]);
AI_5=imfilter(I_dark,A_5,'replicate');
subplot(3,4,3);imshow(AI_5);
title("均值滤波5*5");
A_7=fspecial("average",[7,7]);
AI_7=imfilter(I_dark,A_7,'replicate');
subplot(3,4,4);imshow(AI_7);
title("均值滤波7*7");
subplot(3,4,5); imshow(I_dark);
title("原图");
G=fspecial("gaussian");
GI=imfilter(I_dark,G,'replicate');
subplot(3,4,6); imshow(GI);
title("高斯滤波3*3");
G_5=fspecial("gaussian",[5,5]);
GI_5=imfilter(I_dark,G_5,'replicate');
subplot(3,4,7); imshow(GI_5);
title("高斯滤波5*5");
G_7=fspecial("gaussian",[7,7]);
GI_7=imfilter(I_dark,G_7,'replicate');
subplot(3,4,8); imshow(GI_7);
title("高斯滤波7*7");
MI=medfilt3(I_dark);
subplot(3,4,9); imshow(I_dark);
title("原图");
subplot(3,4,10);imshow(MI);
title("中值滤波");
H=histeq(I_dark);
subplot(3,4,11); imshow(H);
title("直方图均衡化");

