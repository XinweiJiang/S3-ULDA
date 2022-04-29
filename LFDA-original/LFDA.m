function [T,Z]=LFDA(X,Y,r,alpha,metric,kNN)
%
% Local Fisher Discriminant Analysis for Supervised Dimensionality Reduction
%
% Usage:
%       [T,Z]=LFDA(X,Y,r,metric)
%
% Input:
%    X:      d x n matrix of original samples
%            d --- dimensionality of original samples
%            n --- the number of samples 
%    Y:      n dimensional vector of class labels
%            (each element takes an integer between 1 and c, where c is the number of classes) 
%    r:      dimensionality of reduced space (default: d)
%    metric: type of metric in the embedding space (default: 'weighted')
%            'weighted'        --- weighted eigenvectors 
%            'orthonormalized' --- orthonormalized
%            'plain'           --- raw eigenvectors
%    kNN:    parameter used in local scaling method (default: 7)
%
% Output:
%    T: d x r transformation matrix (Z=T'*X)
%    Z: r x n matrix of dimensionality reduced samples 
%
% (c) Masashi Sugiyama, Department of Compter Science, Tokyo Institute of Technology, Japan.
%     sugi@cs.titech.ac.jp,     http://sugiyama-www.cs.titech.ac.jp/~sugi/software/LFDA/

if nargin<2
  error('Not enough input arguments.')
end
[d n]=size(X);

if nargin<3
  r=d;
end

if ~exist('metric', 'var')
    metric='weighted';
end

if ~exist('kNN', 'var')
  kNN=11;
end

if ~exist('alpha', 'var')
  alpha=1;
end

tSb=zeros(d,d);
tSw=zeros(d,d);

for c=1:max(Y)
  Xc=X(:,Y==c);
  Yc=Y(Y==c);
  nc=size(Xc,2);

  % Define classwise affinity matrix
  Xc2=sum(Xc.^2,1);
  distance2=repmat(Xc2,nc,1)+repmat(Xc2',1,nc)-2*Xc'*Xc;
  [sorted,index]=sort(distance2);
  if size(sorted, 1)<kNN+1
        kNNdist2=sorted(size(sorted, 1),:);
  else
        kNNdist2=sorted(kNN+1,:);
  end
  sigma=sqrt(kNNdist2);
  localscale=sigma'*sigma;
  flag=(localscale~=0);
  A=zeros(nc,nc);
  A(flag)=exp(-distance2(flag)./localscale(flag));
%   
%   %use CGDA
%   Ysum = tabulate(Yc);
%   Ysum = Ysum(:,2);
%   alpha = 100; beta = 1;
%   A = creatgraphW_wei(Xc,Ysum,alpha,beta,'CGDA', 0, 0, 0);
%   
%   distance2=A;
%   [sorted,index]=sort(distance2);
%   if size(sorted, 1)<kNN+1
%         kNNdist2=sorted(size(sorted, 1),:);
%   else
%         kNNdist2=sorted(kNN+1,:);
%   end
%   sigma=sqrt(kNNdist2);
%   localscale=sigma'*sigma;
%   flag=(localscale~=0);
%   A=zeros(nc,nc);
%   A(flag)=exp(-distance2(flag)./localscale(flag));

  Xc1=sum(Xc,2);
  G=Xc*(repmat(sum(A,2),[1 d]).*Xc')-Xc*A*Xc';
  tSb=tSb+G/n+Xc*Xc'*(1-nc/n)+Xc1*Xc1'/n;
%   tSb = beta*tSb+(1-beta)*cov(Xc');
  tSw=tSw+G/nc;
end

X1=sum(X,2);
tSb=tSb-X1*X1'/n-tSw;

% [Z,W,SB,SW] = FDA(X,Y,-1);

% tSb = alpha*tSb+(1-alpha)*SB;
% tSw = alpha*tSw+(1-alpha)*SW;

tSb=(tSb+tSb')/2;
tSw=(tSw+tSw')/2;

if r==d
  [eigvec,eigval_matrix]=eig(tSb,tSw);
else
  opts.disp = 0; 
%   opts.maxit=500;
  opts.v0=ones(d,1);
  [eigvec,eigval_matrix]=eigs(tSb,tSw,r,'lm',opts);
end
eigval=diag(eigval_matrix);
[sort_eigval,sort_eigval_index]=sort(eigval);
T0=eigvec(:,sort_eigval_index(end:-1:1));

switch metric %determine the metric in the embedding space
  case 'weighted'
   T=T0.*repmat(sqrt(sort_eigval(end:-1:1))',[d,1]);
  case 'orthonormalized'
   [T,dummy]=qr(T0,0);
  case 'plain'
   T=T0;
end

Z=T'*X;

