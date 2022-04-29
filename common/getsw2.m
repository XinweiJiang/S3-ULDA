function [ Sw ] = getsw2( data1,data2,num_labels )
%GETS 论文复现之
%   得到Sw
   pixel_num=0;
   [NN,~]=size(data1.Y{1,1}');
   %2*3
   u=zeros(NN,1);
   for i=1:num_labels
       one_set=data1.Y{1,i};
       [onelabel_num,NN]=size(one_set);
       %3*2
       %NN是维度,onelabel_num是该标签的像素点个数
       onelabel=sum(one_set,1);
       onelabel=reshape(onelabel,NN,1);
       u=u+onelabel;
       pixel_num=pixel_num+onelabel_num;
   end
   %但是精度为什么是四位小数呢！晚点探索一下
   %disp(Sw);
   u=u/pixel_num;
   Sw=zeros(NN,NN);
   for i=1:num_labels
       one_set=data1.Y{1,i};
       [onelabel_num,NN]=size(one_set);
       %NN是维度,onelabel_num是该标签的像素点个数
       onelabel=sum(one_set,1);
       onelabel=reshape(onelabel,NN,1);
       Ui=onelabel/onelabel_num;
       for o=1:onelabel_num
           onerect=one_set(o,:)'-u;
           Sw=Sw+onerect*onerect';
       end
   end
   %disp(Sw);
   pixel_num=0;
   [NN,~]=size(data2.Y{1,1}');
   %2*3
   u=zeros(NN,1);
   for i=1:num_labels
       one_set=data2.Y{1,i};
       [onelabel_num,NN]=size(one_set);
       %3*2
       %NN是维度,onelabel_num是该标签的像素点个数
       onelabel=sum(one_set,1);
       onelabel=reshape(onelabel,NN,1);
       u=u+onelabel;
       pixel_num=pixel_num+onelabel_num;
   end
   %但是精度为什么是四位小数呢！晚点探索一下
   %disp(Sw);
   u=u/pixel_num;
   for i=1:num_labels
       one_set=data2.Y{1,i};
       [onelabel_num,NN]=size(one_set);
       %NN是维度,onelabel_num是该标签的像素点个数
       onelabel=sum(one_set,1);
       onelabel=reshape(onelabel,NN,1);
       Ui=onelabel/onelabel_num;
       for o=1:onelabel_num
           onerect=one_set(o,:)'-u;
           Sw=Sw+onerect*onerect';
       end
   end
end



