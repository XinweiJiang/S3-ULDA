clear all;

n1a=100;
n1b=100;
n2=100;
X1a=[randn(2,n1a).*repmat([1;2],[1 n1a])+repmat([-6;0],[1 n1a])];
X1b=[randn(2,n1b).*repmat([1;2],[1 n1b])+repmat([ 6;0],[1 n1b])];
X2= [randn(2,n2 ).*repmat([1;2],[1 n2 ])+repmat([ 0;0],[1 n2 ])];
X=[X1a X1b X2];
Y=[ones(n1a+n1b,1);2*ones(n2,1)];

K=Kmatrix_Gauss(X,1);
[T,Z]=KLFDA(K,Y,1);

figure(1)
clf
hold on

h=plot(X(1,Y==1),X(2,Y==1),'bo');
h=plot(X(1,Y==2),X(2,Y==2),'rx');
axis equal
axis([-10 10 -10 10])
title('Original data')

figure(2)
clf
subplot(2,1,1)
hold on
hist(Z(Y==1),linspace(min(Z),max(Z),30));
h=get(gca,'Children');
set(h,'FaceColor','b')
axis([min(Z) max(Z) 0 inf])

subplot(2,1,2)
hold on
hist(Z(Y==2),linspace(min(Z),max(Z),30));
h=get(gca,'Children');
set(h,'FaceColor','r')
axis([min(Z) max(Z) 0 inf])

title('Projected data')
