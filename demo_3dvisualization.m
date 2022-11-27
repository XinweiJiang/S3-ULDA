% =========================================================================
% A simple demo 3d visualization
% If you  have any problem, do not hesitate to contact
% Pengyu Lu (email:hello-lpy@qq.com)    
%%% three datasets demo
% 2022-11-6  


clc;clear;close all
addpath('.\libsvm-3.21\matlab');
addpath(genpath(cd));
num_PC=0;  % THE OPTIMAL PCA DIMENSION.
num_Pixel=0; % THE OPTIMAL Number of Superpixel. Indian:75, PaviaU:30, Salinas:100
k=0;  % THE OPTIMAL Number of spatial neighbors.Indian:15, PaviaU:13, Salinas:15
trainpercentage=0;  % Training Number per Class
iterNum          =   10;  % The Iteration Number

database         =   'Indian';  

%% load the HSI dataset
if strcmp(database,'Indian')
    load Indian_pines_corrected;load Indian_pines_gt;load Indian_pines_randp 
    data3D = indian_pines_corrected;        label_gt = indian_pines_gt;
    num_Pixel        =   35;
    k                =   17;
    num_PC           =   10;
elseif strcmp(database,'PaviaU')    
    load PaviaU;load PaviaU_gt;load PaviaU_randp; 
    data3D = paviaU;        label_gt = paviaU_gt;
    num_Pixel        =   35;  
    k                =   13;
    num_PC           =   15;
elseif strcmp(database,'Houston') 
    load Houston;load Houston_gt;load Houston_randp.mat; 
    data3D = double(CASI);        label_gt = gnd_flag;
    num_Pixel        =   30;  
    k                =   15;
    num_PC           =   15;
end
data3D = data3D./max(data3D(:)); 
labels = fororiphoto(data3D,num_Pixel,label_gt);
dataDR=SuperULDA(data3D,num_PC,k,labels);
[m,n,d]=size(dataDR);
dataDRs=reshape(dataDR,m*n,d);
[P] = Eigenface_f(dataDRs',3);
dataDRs=dataDRs*P;
dataDRs=data_normalization(dataDRs);
de_x=[dataDRs];
y=[label_gt];
label_gt=reshape(label_gt,m*n,1);
B=[140 67 46;0 0 255;255 100 0;0 255 123;164 75 155;101 174 255;118 254 172; 60 91 112;255,255,0;255 255 125;255 0 255;100 0 255;0 172 254;0 255 0;171 175 80;101 193 60];
B=B./255;
for i=1:max(label_gt)
  x_1=[];
  y_1=[];
  z_1=[];
  idx=find(label_gt==i);
  x_1=de_x(idx,1);
  y_1=de_x(idx,2);
  z_1=de_x(idx,3);
  scatter3( x_1,y_1,z_1,3,B(i,:),'filled');
  hold on
end

