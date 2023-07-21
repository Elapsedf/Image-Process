

%% 随机选取，设置模板
%先遍历文件夹，对每个文件进行采集
%目录
temdir = "D:\MATLAB\Examples\R2022a\matlab\图像处理\图像实验一\number_recognize\template";   %模板目录
traindir="D:\MATLAB\Examples\R2022a\matlab\图像处理\图像实验一\number_recognize\train_dataset";  %训练目录
%"D:\MATLAB\Examples\R2022a\matlab\图像处理\图像实验一\number_recognize\train_dataset"
sub_traindir=dir(traindir); %. .. 0-9

sub_Idir=dir("D:\MATLAB\Examples\R2022a\matlab\图像处理\图像实验一\number_recognize\IMAGE");
sub_temdir  = dir( temdir );    %子目录struct 0-9



for i=1:length(sub_traindir)
    if( isequal( sub_traindir( i ).name, '.' )||...
        isequal( sub_traindir( i ).name, '..'))             
        continue;
    end
    sub_traindirpath=fullfile(traindir,sub_traindir(i).name);
    %"D:\MATLAB\Examples\R2022a\matlab\图像处理\图像实验一\number_recognize\train_dataset\0"
    train_data=dir(sub_traindirpath); %具体打开某一个数字文件夹
    num_tem=300;    %模板数量
    randlist=randperm(1000);         %生成不重复的序列
    %错误原因：取1-1000的序列，实际应取3-1002，因为1是. 2是..
    %解决方法：直接在后面+2
    for j =1: num_tem
        index=randlist(j)+2;
        src=fullfile(sub_traindirpath,train_data(index).name);
        dst=fullfile(temdir,sub_temdir(i).name);
        movefile(src,dst);
    end
    %template=fullfile(traindir,)
end

%% 用模板图片得到训练数据
for i = 1 : length( sub_temdir )
    if( isequal( sub_temdir( i ).name, '.' )||...
        isequal( sub_temdir( i ).name, '..'))             
        continue;
    end
    sub_temdirpath = fullfile( temdir, sub_temdir( i ).name);   %子文件夹路径
    data = dir( sub_temdirpath );               % data目录
    img_model={};
    for j = 1 : length( data )
        if (isequal( data( j ).name, '.' )||...
        isequal( data( j ).name, '..'))
            continue;
        end
        datapath = fullfile( temdir, sub_temdir( i ).name, data( j ).name); 
        img =imread(datapath); 
        img2=imgprocess(img);    %对模板进行处理，img2表示返回二值图像
        img_model{j-2}=img2;     %从j=3开始，j=1，2为目录
    end
    image=cell2mat(img_model);  %将图片的数据格式从元胞变为基础数据格式
    imwrite(image,strcat("IMAGE\",num2str(i-3)),'png');  %遍历完所有数据

end

%% 开始测试



acc=0;
numfiles=0;
%遍历文件
for i = 1 : length( sub_traindir )  %i=0~9
    disp(i);
    if( isequal( sub_traindir( i ).name, '.' )||...
        isequal( sub_traindir( i ).name, '..'))               % 如果不是目录则跳过
        continue;
    end
    sub_numdir = fullfile( traindir, sub_traindir( i ).name);
    train_data = dir( sub_numdir );               % 子文件夹下遍历图片
    numfiles=numfiles+length(train_data)-2;       %总数叠加
    for j =1:length(train_data)     
        if (isequal( train_data( j ).name, '.' )||...
        isequal( train_data( j ).name, '..'))
            continue;
        end
        train_datapath=fullfile(traindir, sub_traindir(i).name,train_data(j).name); %对应图片路径
        img=imread(train_datapath);
        
        %% 图像处理
%         img=imresize(img,[28,28]);  %调整图像大小
%         img = filter2(fspecial('sobel'),img);     %此运算寻找边缘
%         img_g = mat2gray(img);        %灰度化
%         threshold = graythresh(img_g);	%使用 Otsu 方法计算全局图像阈值                                
%         img2 = imbinarize(img_g, threshold);    %将图片二值化
%         imshowpair(img2,img_g,'montage');
        img2=imgprocess(img);
        % 开始比对
        minloss=200;
        for k=1:length(sub_Idir)
            if( isequal( sub_traindir( k ).name, '.' )||...
                isequal( sub_traindir( k ).name, '..'))               % 如果不是目录则跳过
                continue;
            end
            template_path=fullfile("IMAGE/", sub_Idir(k).name);
            temimg=imread(template_path);
            loss=cal_loss(img2, temimg);    %计算两个矩阵的差
            %disp(loss);
            if loss<minloss
                minloss=loss;
                flag=k;
            end
        end
        if flag==i
            acc=acc+1;      %预测正确，加1
        end
    end
    %sub_numdir = fullfile( traindir, sub_traindir( i ).name);
    %disp(i); 
end
acc=acc/numfiles;

function [minloss]=cal_loss(img2, temimg)
%此函数用于计模板与待测图像的loss值
%输入两张图像的矩阵，返回loss
sm=size(temimg);
num=sm(2)/28;
m0=temimg(1:28,1:28);
minloss=sum(sum(abs(img2-m0)));
for i =1:num-1
    m_other=temimg(1:28,28*i+1:28*(i+1));
    loss =sum(sum(abs(img2-m_other)));
    if loss <minloss
        minloss=loss;
    end
end
end

function [img2]=imgprocess(img)
%图像处理函数，将图像进行一系列处理操作
img=imresize(img,[28,28]);  %调整图像大小
img = filter2(fspecial('sobel'),img);     %此运算寻找边缘
img_g = mat2gray(img);        %灰度化
threshold = graythresh(img_g);	%使用 Otsu 方法计算全局图像阈值                                
img2 = imbinarize(img_g, threshold);
end

