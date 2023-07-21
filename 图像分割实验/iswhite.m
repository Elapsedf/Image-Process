function flag = iswhite(x,y)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明
cnt=0;
flag=0;
global im_close;
if im_close(x+1,y)==1
    cnt=cnt+1;
end

if im_close(x-1,y)==1
    cnt=cnt+1;
end
if im_close(x,y+1)==1
    cnt=cnt+1;
end
if im_close(x,y-1)==1
    cnt=cnt+1;
end
if cnt>=3
    flag=1;
end