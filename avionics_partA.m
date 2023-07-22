clear all;
clc;

pkg load communications;


f =  [1,1,0,0,0,0,1,1,1]; %p(x) 
printf("p(x)\n = ");
polyout(f,'x');

index=254; %g(x) 
g(1)=1;
g(2:1:index+1)=(0);
printf("g(x)\n = ");
polyout(g,'x');
%%%%% PRAXEIS %%%%%%%%%%
k = gf(f,8);
n = gf(g,8);
[t,p] = deconv(n,k);
printf("%d",flip([[p]]));
%%%%%%%%%%%%%%%%%%%%%%%%