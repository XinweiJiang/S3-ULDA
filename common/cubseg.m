function labels = cubseg(indian_pines,cc)
%超像素分割的过程

[M,N,B]=size(indian_pines);
%fprintf('%d %d %d',M,N,B)
Y_scale=scaleForSVM(reshape(indian_pines,M*N,B));
p = 1;
[Y_pca] = pca(Y_scale, p);
%disp(Y_pca);
img = im2uint8(mat2gray(reshape(Y_pca', M, N, p)));
sigma=0.05;
K=cc;
grey_img = im2uint8(mat2gray(reshape(Y_pca', M, N, p)));
labels = mex_ers(double(img),K);
%disp(labels);
%disp(size(labels));
[height width] = size(grey_img);
[bmap] = seg2bmap(labels,width,height);
bmapOnImg = img;
idx = find(bmap>0);
timg = grey_img;
timg(idx) = 255;
bmapOnImg(:,:,2) = timg;
bmapOnImg(:,:,1) = grey_img;
bmapOnImg(:,:,3) = grey_img;

% figure;
% imshow(bmapOnImg,[]);
% imwrite(grey_img,'bmapOnImg.bmp')
% title('superpixel boundary map');
