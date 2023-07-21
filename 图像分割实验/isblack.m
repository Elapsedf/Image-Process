function flag=isblack(x,y)
cnt=0;
flag=0;
global im_close;
if im_close(x+1,y)==0
    cnt=cnt+1;
end

if im_close(x-1,y)==0
    cnt=cnt+1;
end
if im_close(x,y+1)==0
    cnt=cnt+1;
end
if im_close(x,y-1)==0
    cnt=cnt+1;
end
if cnt>=2
    flag=1;
end
