function [PC] = SuperULDA(data,num_PC,k,labels)
[MS,NS,B]=size(data);
Results_segment= seg_im_class(data,labels);
Results_segments= seg_im_class(data,labels);
Num=size(Results_segment .Y,2);
for i=1:Num
    Results_segments.Y{1,i} = findConstruct(Results_segments.Y{1,i},Results_segments.cor{1,i},k);
    A(Results_segment.index{1,i},:)=Results_segment.Y{1,i};
    As(Results_segments.index{1,i},:)=Results_segments.Y{1,i};
end 
%local feature extraction
[X1]=local_LFDA(Results_segments,labels,num_PC);
X1=data_normalization(X1);
%global feature extraction
Sw=getsw2(Results_segments,Results_segment,Num);
Sb=getsb2(Results_segments,Results_segment,Num);
targetfunc=Sw\Sb;
[V,~]=Find_K_Max_Eigen(targetfunc,num_PC);
X2=As*V;
X2=data_normalization(X2);
% 
XS=[X1,X2];
PC = reshape(XS,MS,NS,num_PC*2);