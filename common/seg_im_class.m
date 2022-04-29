function Results = seg_im_class(Y,Ln)
    [M,N,B]=size(Y);
    Y_reshape=reshape(Y,M*N,B);
    Gt=reshape(Ln,[1,M*N]);
    Class=unique(Gt);
    %disp(size(Class));也就是0~74，返回的是和labels中一样的值，但是没有重复元素。产生的结果向量按升序排序。
    Num=size(Class,2);
    %disp(Num);
    Y=cell(1,Num);
    %disp(Y); 构造一个cell  一行75列
    index=cell(1,Num);
    
    for i=1:Num
        Results.index{1,i}=find(Gt==Class(i));
        nowlabels=Results.index{1,i};
        Results.nowlabel{1,i}=Gt(nowlabels(1));
        %disp(Results.index{1,i});
        %找到0~74超像素块所在的[m] [n]
        [m,n] = find(Ln==Class(i));
        %disp([m,n]);
        Results.cor{1,i} = [m,n];
        Results.Y{1,i} =Y_reshape(find(Gt==Class(i)),:);
        %disp(Results.Y{1,i});
    end
    
end
