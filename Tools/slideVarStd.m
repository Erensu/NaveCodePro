function [vas,stdvas,mmvas]=slideVarStd(data,n)
% �����������ݵķ����׼���ֵ
% [vas,stdvas]=slideVarStd(data,n)
% ����1-n, 2-n+1, 3-n+2
% data: 1*N, �� N*1
%
% ���أ�vas: ��� stdvas: ��׼��
N=length(data);
M=N-n+1;
vas=zeros(1,M);
mmvas=vas;

S2x=sum(data(1:n).^2);
Sx=sum(data(1:n));% ���
x0=Sx/n;          % ��ֵ

mmvas(1)=x0;
vas(1)=(S2x -n*x0^2)/n;

k=1;
for i=n+1:N
    S2x=S2x - data(k)^2 + data(i)^2;
    Sx=Sx - data(k) + data(i);
    x0=Sx/n;
        
    vas(k+1)=(S2x -n*x0^2)/n;
    if(vas(k+1)<0)
        fprintf('error!\n');
    end
    mmvas(k+1)=x0;
    
    k=k+1;
end

stdvas=vas.^(0.5);
end