function K=Kmatrix_Gauss(X,sigma)

  if nargin<=1
    sigma=1;
  end

  [d,n]=size(X);
  X2=sum(X.^2,1);
  distance2=repmat(X2,n,1)+repmat(X2',1,n)-2*X'*X;
  K=exp(-distance2/(2*sigma^2));
