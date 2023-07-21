img=imread("ͼƬ/2.jpg");
%
img2=im2double(img);
%% ѡȡROI���������ɰ�ͼ��
img2=rgb2gray(img2);

[m,n]=size(img2);
imshow(img2);
[x,y]=ginput(4);
%�ɰ�ͼƬ����
mask = poly2mask(x,y,m,n);  %������Ĥ
mask2=im2double(mask);
Newimage=mask2.*img2;
%% ���ɰ�ͼƬ���б�Եʶ��

st=edge_recog(Newimage);


%% ����任ʶ��ֱ�߱�Ե
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

%% ��������֪ʶ��ֱ�߽���ɸѡ
% �˴�����ѡ��ֱ�ߵ�ģ����Ƕ�

%% ����任����
function lines=HoughStrightrecognize(BW)
[H,T,R]=hough(BW);
P=houghpeaks(H,5,'Threshold',ceil(0.3*max(H(:))));
lines=houghlines(BW,T,R,P,"FillGap",5,"MinLength",7);
end



%% ��Եʶ����
function st=edge_recog(image)
%��˹�˲�
W=fspecial("gaussian",[5,5],1);
img_new=imfilter(image,W,"replicate");
%ʹ��sobel���Ӽ����ݶ�
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
%�����ֵ����
output=NMS_algo(dstImg,gradx,grady);
%��ֵ����
jd=double(output);
st = zeros(rows,cols);%����һ��˫��ֵͼ��
TL = 0.1 * max(max(jd));%����ֵ
TH = 0.3* max(max(jd));%����ֵ
for i = 1  : rows
    for j = 1 : cols
        if (jd(i, j) < TL)
            st(i,j) = 0;
        elseif (jd(i, j) > TH)
            st(i,j) = 1 ;
        %��TL < Nms(i, j) < TH ʹ��8��ͨ����ȷ��
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
%% �Ǽ���ֵ����
function output = NMS_algo(grad,gradx,grady)
% �Ǽ���ֵ���ƺ���
grad = double(grad);
[h,w] = size(grad);
% ��ʼ�����
result = zeros(h,w);
% �����㷨ʵ��
% �����Բ�ֵ����ݶȷ����������ص���ݶ�ֵ
% Ȩ�س�ʼ��
weight = zeros(h,w);
% �����ص��ݶ�ֵ��ʼ��
grad1 = zeros(h,w);
grad2 = zeros(h,w);
grad3 = zeros(h,w);
grad4 = zeros(h,w);
gradTemp1 = zeros(h,w);
gradTemp2 = zeros(h,w);
for i = 2:(h-1)
    for j = 2:(w-1)
        % �ݶ�Ϊ0�ĵ�ֱ���ڽ������0
        if grad(i,j) == 0
            result(i,j) = 0;
        % �����ݶȲ�Ϊ0�ĵ�
        else
            % y�����ݶȴ���x�����ݶ�
            if abs(grady(i,j)) > abs(gradx(i,j))
                % ����Ȩ��
                weight(i,j) = abs(gradx(i,j))/abs(grady(i,j));
                % ���ĵ���������
                grad2(i,j) = grad(i-1,j);
                grad4(i,j) = grad(i+1,j);
                % gradx��gradyͬ��
                if gradx(i,j) * grady(i,j) > 0
                    % ��ֵ�õ�����������
                    grad1(i,j) = grad(i-1,j-1);
                    grad3(i,j) = grad(i+1,j+1);
                % gradx��grady���
                else
                    grad1(i,j) = grad(i-1,j+1);
                    grad3(i,j) = grad(i+1,j-1);
                end
            % y�����ݶ�С��x�����ݶ�
            else
                weight(i,j) = abs(grady(i,j))/abs(gradx(i,j));
                grad2(i,j) = grad(i,j-1);
                grad4(i,j) = grad(i,j+1);
                % gradx��gradyͬ��
                if gradx(i,j) * grady(i,j) > 0
                    grad1(i,j) = grad(i+1,j-1);
                    grad3(i,j) = grad(i-1,j+1);
                % gradx��grady���    
                else
                    grad1(i,j) = grad(i-1,j-1);
                    grad3(i,j) = grad(i+1,j+1);
                end
            end
        end
        % ��ֵ����������������ص��ݶ�ֵ
        gradTemp1(i,j) = weight(i,j) * grad1(i,j) + (1 - weight(i,j)) * grad2(i,j);
        gradTemp2(i,j) = weight(i,j) * grad3(i,j) + (1 - weight(i,j)) * grad4(i,j);
        % �Ƚ��������ص�����������ص���ݶ�ֵ
        if (grad(i,j) >= gradTemp1(i,j) && grad(i,j) >= gradTemp2(i,j))
            % ���ĵ�����������Ϊ����ֵ���ڽ���б������ݶ�ֵ
            result(i,j) = grad(i,j);
        else
            % ����Ļ����ڽ������0
            result(i,j) = 0;
        end     
    end
end
output = im2uint8(result);      %ע�⣡
end