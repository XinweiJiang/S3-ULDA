% =========================================================================
% A simple demo for S3-ULDA based Unsupervised Feature Extraction of
% Hyperspectral Imagery
% If you  have any problem, do not hesitate to contact
% Pengyu Lu (email:hello-lpy@qq.com)    
% 2022-3


clc;clear;close all
addpath('.\libsvm-3.21\matlab');
addpath(genpath(cd));
t1=clock;
num_PC           =   15;  % THE OPTIMAL PCA DIMENSION.
num_Pixel        =   -1; % THE OPTIMAL Number of Superpixel. Indian:75, PaviaU:30, Salinas:100
k                =   -1;  % THE OPTIMAL Number of spatial neighbors.Indian:15, PaviaU:13, Salinas:15
trainpercentage  =   0.1;  % Training Number per Class
iterNum          =   10;  % The Iteration Number

database         =   'Indian';  

%% load the HSI dataset
if strcmp(database,'Indian')
    load Indian_pines_corrected;load Indian_pines_gt;load Indian_pines_randp 
    data3D = indian_pines_corrected;        label_gt = indian_pines_gt;
    num_Pixel        =   55;
    k                =   15;
elseif strcmp(database,'PaviaU')    
    load PaviaU;load PaviaU_gt;load PaviaU_randp; 
    data3D = paviaU;        label_gt = paviaU_gt;
    num_Pixel        =   30;  
    k                =   9;
end
data3D = data3D./max(data3D(:)); 
labels = cubseg(data3D,num_Pixel);
dataDR=SuperULDA(data3D,num_PC,k,labels);
trainsets=[5,10,20,30,40,50,60];
for trainpercentage=trainsets
         for iter = 1:iterNum
%         for iter = 1
            randpp=randp{iter};     
            % randomly divide the dataset to training and test samples
            [DataTest DataTrain CTest CTrain map trainindex predictindex] = samplesdivide(dataDR,label_gt,trainpercentage,randpp);   
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
%                 model = fitcsvm( DataTrain,trainlabel', cmd);
                
                
                [predict_label, AC, prob_values] = svmpredict(testlabel', DataTest, model, '-b 1');        
%                 predict_label=predict(model,DataTrain );
                
                [confusions, accuracy1, CR, FR] = confusion_matrix(predict_label', CTest);
%                 [oa(trial0),aa(trial0),kappa(trial0),ua(trial0),confu]=forconfusion( CTest,predict_label');
                oa=trace(confusions)/sum(confusions(:)); %overall accuracy
                ua=diag(confusions)./sum(confusions,2);  %class accuracy
                ua(isnan(ua))=0;
                number=size(ua,1);
                aa=sum(ua)/number;
                Po=oa;
                Pe=(sum(confusions)*sum(confusions,2))/(sum(confusions(:))^2);
                K=(Po-Pe)/(1-Pe);%kappa coefficient
%                 
                accy(trial0) = accuracy1;   
                oacy(trial0)=oa;
                AAcy(trial0) = aa;
                kappacy(trial0) = K;
                uacy(trial0,:)=ua;
            end
            accy_best(iter) = max(accy);
            oacy_best(iter) = max(oacy);
            AAcy_best(iter) = max(AAcy);
            kappacy_best(iter) =max(kappacy);
        end
        disp(accy_best);
        fprintf('\n=============================================================\n');
        fprintf(['The average OA (10 iterations) of S3-PCA for ',database,' is %0.4f\n'],mean(accy_best));
        fprintf(['The average OA (10 iterations) of S3-PCA for ',database,' is %0.4f\n'],mean(oacy_best));
        fprintf(['The average AA (10 iterations) of S3-PCA for ',database,' is %0.4f\n'],mean(AAcy_best));
        fprintf(['The average kappa (10 iterations) of S3-PCA for ',database,' is %0.4f\n'],mean(kappacy_best));
        fprintf('=============================================================\n');
end



