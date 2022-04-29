% =========================================================================
% A simple demo for S^3-PCA based Unsupervised Feature Extraction of
% Hyperspectral Imagery
% If you  have any problem, do not hesitate to contact
% Zhang Xin (xinz2801@gmail.com)
% Version 1,2020-09-03


clc;clear;close all
addpath('.\libsvm-3.21\matlab');
addpath(genpath(cd));

num_PC           =   30;  % THE OPTIMAL PCA DIMENSION.
% num_Pixel        =   100; % THE OPTIMAL Number of Superpixel. Indian:75, PaviaU:30, Salinas:100
% k                =   15;  % THE OPTIMAL Number of spatial neighbors.Indian:15, PaviaU:13, Salinas:15
trainpercentage  =   30;  % Training Number per Class
iterNum          =   10;  % The Iteration Number

database         =   'Indian';

%% load the HSI dataset
if strcmp(database,'Indian')
    load Indian_pines_corrected;load Indian_pines_gt;load Indian_pines_randp 
    data3D = indian_pines_corrected;        label_gt = indian_pines_gt;
    num_Pixel        =   75;
    k                =   15;
elseif strcmp(database,'Salinas')
    load Salinas_corrected;load Salinas_gt;load Salinas_randp
    data3D = salinas_corrected;        label_gt = salinas_gt;
    num_Pixel        =   100;
    k                =   15;
elseif strcmp(database,'PaviaU')    
    load PaviaU;load PaviaU_gt;load PaviaU_randp; 
    data3D = paviaU;        label_gt = paviaU_gt;
    num_Pixel        =   30;
    k                =   13;
end
data3D = data3D./max(data3D(:));

%% super-pixels segmentation
k_num=30;
labels = cubseg(data3D,num_Pixel);
fResults_segment= seg_im_class(data3D,labels);
[labelss]=getlabels(data3D,labels,num_Pixel,k_num);
Results_segment= seg_im_class(data3D,labelss);
for i=1:num_Pixel
    fResults_segment.Y{1,i} = findConstruct(fResults_segment.Y{1,i},fResults_segment.cor{1,i},k);
     %k临近像素点重建像素
    [P] = Eigenface_f(fResults_segment.Y{1,i}',num_PC);
    %得到特征值
    PC = (fResults_segment.Y{1,i})*P;
    %= [139,200]*[200,30]特征降维=【139】【30】
    %算是个局部特征提取和使用的过程
    X1(fResults_segment.index{1,i},:)=PC;
    A(fResults_segment.index{1,i},:)=fResults_segment.Y{1,i};
end
Sw=getsw(Results_segment.Y,k_num);
Sb=getsb(Results_segment.Y,k_num);
%lad
targetfunc=Sw\Sb;
[V,S]=Find_K_Max_Eigen(targetfunc,k_num);
X2=A*V;
[P] = Eigenface_f(A',num_PC); 
A_PC=A*P;
X = [X2,A_PC,X1];
% X = [X1,X2];
% %X = [X1];
[P] = Eigenface_f(X',num_PC);
X = X*P;
dataDR = reshape(X,145,145,30);
for iter = 1:iterNum
    randpp=randp{iter};     
    % randomly divide the dataset to training and test samples
    [DataTest DataTrain CTest CTrain map] = samplesdivide(dataDR,label_gt,trainpercentage,randpp);   

    % Get label from the class num
    trainlabel = getlabel(CTrain);
    testlabel  = getlabel(CTest);

    % set the para of RBF
    ga8 = [0.01 0.1 1 5 10];    ga9 = [15 20 30 40 50 100:100:500];
    GA = [ga8,ga9];

    accy = zeros(1,length(GA));

    tempaccuracy1 = 0;
    for trial0 = 1:length(GA);    
        gamma = GA(trial0);        
        cmd = ['-q -c 100000 -g ' num2str(gamma) ' -b 1'];
        model = svmtrain(trainlabel', DataTrain, cmd);
        [predict_label, AC, prob_values] = svmpredict(testlabel', DataTest, model, '-b 1');                    
        [confusion, accuracy1, CR, FR] = confusion_matrix(predict_label', CTest);
        accy(trial0) = accuracy1;
    end
    accy_best(iter) = max(accy);
    disp(iter);
end
fprintf('\n=============================================================\n');
fprintf(['The average OA (10 iterations) of S3-PCA for ',database,' is %0.4f\n'],mean(accy_best));
fprintf('=============================================================\n');


