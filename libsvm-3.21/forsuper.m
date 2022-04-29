% =========================================================================
% A simple demo for S^3-PCA based Unsupervised Feature Extraction of
% Hyperspectral Imagery
% If you  have any problem, do not hesitate to contact
% Zhang Xin (xinz2801@gmail.com)
% Version 1,2020-09-03


clc;clear;close all
addpath('.\libsvm-3.21\matlab');
addpath(genpath(cd));

num_PC           =   50;  % THE OPTIMAL PCA DIMENSION.
% num_Pixel        =   100; % THE OPTIMAL Number of Superpixel. Indian:75, PaviaU:30, Salinas:100
% k                =   15;  % THE OPTIMAL Number of spatial neighbors.Indian:15, PaviaU:13, Salinas:15
trainpercentage  =   12;  % Training Number per Class
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
dims1=75;
dims2=75;
dims3=100;

%% super-pixels segmentation
labels1 = cubseg(data3D,dims1);
% [dataDR1]=tosuper(data3D,num_PC,k,labels1,50);
[dataDR] = S3_PCA(data3D,num_PC,k,labels1);
% labels2 = cubseg(data3D,dims2 );
% % [dataDR2]=tosuper(data3D,10,k,labels2,75);
% [dataDR2] = S3_PCA(data3D,num_PC,k,labels2);
% labels3 = cubseg(data3D,dims3);
% % [dataDR3]=tosuper(data3D,num_PC,k,labels3,100);
% [dataDR3] = S3_PCA(data3D,num_PC,k,labels3);
% dataDRs=[dataDR2,dataDR1,dataDR3];
% dataDR=reshape(dataDRs,145*145,num_PC*3+6);


%% SupePCA based DR
    %接下来是test
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
    %     disp(iter);
    end
    fprintf('\n=============================================================\n');
    fprintf(['The average OA (10 iterations) of S3-PCA for ',database,' is %0.4f\n'],mean(accy_best));
    fprintf('=============================================================\n');
