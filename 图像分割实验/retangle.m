function [] = retangle(rows,cols)
%UNTITLED4 此处提供此函数的摘要
%   此处提供详细说明
global im_close;
%(0,0)开始
for i=2:rows-1
    for j=2:cols-1
        if im_close(i,j)==0
            if iswhite(i,j)
                im_close(i,j)=1;
                continue;
            end
        end
        if im_close(i,j)==1
            if isblack(i,j)
                im_close(i,j)=0;
                continue;
            end
        end
    end
end
%（m，0）开始

for i=rows-1:-1:2
    for j=2:cols-1
        if im_close(i,j)==0
            if iswhite(i,j)
                im_close(i,j)=1;
                continue;
            end
        end
        if im_close(i,j)==1
            if isblack(i,j)
                im_close(i,j)=0;
                continue;
            end
        end
    end
end

%(0,n)
for i=2:rows-1
    for j=cols-1:-1:2
        if im_close(i,j)==0
            if iswhite(i,j)
                im_close(i,j)=1;
                continue;
            end
        end
        if im_close(i,j)==1
            if isblack(i,j)
                im_close(i,j)=0;
                continue;
            end
        end
    end
end
% （m，n）
for i=rows-1:-1:2
    for j=cols-1:-1:2
        if im_close(i,j)==0
            if iswhite(i,j)
                im_close(i,j)=1;
                continue;
            end
        end
        if im_close(i,j)==1
            if isblack(i,j)
                im_close(i,j)=0;
                continue;
            end
        end
    end
end
end