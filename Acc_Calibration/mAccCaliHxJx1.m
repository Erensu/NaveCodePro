function [Jx,Hx,cfun]=mAccCaliHxJx1(fsbib,X,g0,flag)
% 2��ģ��������ģ�ͣ�Jx,Hx
% ע�⣺���ٶȼ������Ǿ����ֱ궨����ת��������ݣ��б��������bias���
%      ��ʱ��ֵ���������Χͨ��Ϊ [-0.95, 1.05],ʣ����ƫ����̫��,����δ��������ƫ��
% �������궨ģ�ͣ�fb=Ka*(V - bias)   %����̬���ݽ���ƽ�������������� ģ�ͣ�
% ����ԭ�ͣ�[Jx,Hx,cfun]=mAccCaliHxJx1(fsbib,X,g0,flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���������fsbib: �������������ʸ����ά��[3,M]
%          g0:   ����ֵ��������gΪ��λ��������� 1
%          flag��ģ��ѡ��  flag=1 {fb=Ka*V-bias};   flag=2, { fb= Ka*(V-bias) }
% ���������
%         
%             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : xutongxu
% Version : 1
% Date : 2020.4.6
% File : [5]Frosio, I., F. Pedersini and N.A. Borghese, Autocalibration of MEMS Accelerometers. 
% IEEE Transactions on Instrumentation and Measurement, 2009. 58(6): p. 2034-2041.
Jx=zeros(9,1);
Hx=zeros(9,9);
cfun=0;
if(flag==1)
    [Jx,Hx,cfun]=accMod1HxJx(fsbib,X,g0);
else
    if(flag==2)
    [Jx,Hx,cfun]=accMod2HxJx(fsbib,X,g0);
    end
end

end
% mode1: fb=Ka*fsbib - bias;
function [Jx,Hx,cfun]=accMod1HxJx(fsbib,X,g0)
N=length(fsbib(1,:));

% ģ��1 ��fb=Ka*V-bias
bias=[X(7);X(8);X(9)];
Ka=[X(1), 0,    0
    X(2), X(3), 0
    X(4), X(5), X(6)];
fb=Ka*fsbib;  fb(1,:)=fb(1,:)-bias(1); fb(2,:)=fb(2,:)-bias(2); fb(3,:)=fb(3,:)-bias(3);
hx=(fb(1,:).^2 + fb(2,:).^2 + fb(3,:).^2)-g0*g0;
cfun=sum(hx.^2)/N;   % ���ۺ���

dfx=zeros(1,9); dfy=dfx;    dfz=dfx;
dfx(7)=-1;      
dfy(8)=-1;    
dfz(9)=-1;

dhxi=zeros(9,N);
for j=1:N  
    v=fsbib(:,j);
    dfx(1)=v(1);  
    dfy(2)=v(1); dfy(3)=v(2); 
    dfz(4)=v(1); dfz(5)=v(2);  dfz(6)=v(3);
    for i=1:9 
        dhxi(i,j)=2*[dfx(i),dfy(i),dfz(i)]*fb(:,j);
    end
end
%------------����Jx-----------%
Jx=zeros(9,1);
for j=1:N  
    for i=1:9 
        Jx(i)=2*hx(j)*dhxi(i,j) + Jx(i);
    end
end
Jx=Jx/N;
%-----------����Hessian ����, 9*9----%
Hx=zeros(9,9); % �Գƾ���
for i=1:9
    for j=i:9
        for k=1:N
            Hx(i,j)=dhxi(i,k)*dhxi(j,k) +Hx(i,j);
        end
        Hx(i,j)=Hx(i,j)*2/N;
    end
end
for i=1:8
    for j=i+1:9
        Hx(j,i)=Hx(i,j);
    end
end

end

% mode2: fb=Ka*(fsbib - bias);
function [Jx,Hx,cfun]=accMod2HxJx(fsbib,X,g0)
N=length(fsbib(1,:));

% ģ��2 ��fb=Ka*(V-bias)
bias=[X(7);X(8);X(9)];
Ka=[X(1), 0,    0
    X(2), X(3), 0
    X(4), X(5), X(6)];
fb=Ka*[fsbib(1,:)-bias(1); fsbib(2,:)-bias(2); fsbib(3,:)-bias(3)];
hx=(fb(1,:).^2 + fb(2,:).^2 + fb(3,:).^2)-g0*g0;
cfun=sum(hx.^2)/N;   % ���ۺ���

dfx=zeros(1,9); dfy=dfx;    dfz=dfx;
dfx(7)=-X(1);
dfy(7)=-Ka(2,1);  dfy(8)=-Ka(2,2); 
dfz(7)=-Ka(3,1); dfz(8)=-Ka(3,2); dfz(9)=-Ka(3,3);
dhxi=zeros(9,N);
for j=1:N  
    v=fsbib(:,j);
    dfx(1)=v(1)-bias(1);   
    dfy(2)=v(1)-bias(1);  dfy(3)=v(2)-bias(2); 
    dfz(4)=v(1)-bias(1);  dfz(5)=v(2)-bias(2); dfz(6)=v(3)-bias(3);
    for i=1:9 
        dhxi(i,j)=2*[dfx(i),dfy(i),dfz(i)]*fb(:,j);
    end
end
%------------����Jx-----------%
Jx=zeros(9,1);
for j=1:N  
    for i=1:9 
        Jx(i)=2*hx(j)*dhxi(i,j) + Jx(i);
    end
end
Jx=Jx/N;
%-----------����Hessian ����, 9*9----%
Hx=zeros(9,9);   % �Գƾ���
dHx2=zeros(9,9);
dHx2(1,7)=-1;  dHx2(7,1)=-1; 

dHx2(2,7)=-1;  dHx2(3,8)=-1;  dHx2(7,2)=-1;  dHx2(8,3)=-1;

dHx2(4,7)=-1; dHx2(5,8)=-1; dHx2(6,9)=-1; 
dHx2(7,4)=-1; dHx2(8,5)=-1; dHx2(9,6)=-1;
for k=1:N
    for i=1:9
        for j=i:9
            Hx(i,j)=dhxi(i,k)*dhxi(j,k) + hx(k)*dHx2(i,j) +Hx(i,j);
        end 
    end
end

Hx(i,j)=Hx(i,j)*2/N;
for i=1:8
    for j=i+1:9
        Hx(j,i)=Hx(i,j);
    end
end

end