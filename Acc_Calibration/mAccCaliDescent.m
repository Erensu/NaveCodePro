function res=mAccCaliDescent(fsbib,X,g0,flag,flag2)
% ���ڼ��ٶȼ�ʸ��ģ��ȵı궨���������ۺ���ֵ�½�������������
% ע�⣺���ٶȼ������Ǿ����ֱ궨����ת��������ݣ��޷����������б��������bias���
%      ��ʱ��ֵ���������Χͨ��Ϊ [-0.95, 1.05],ʣ����ƫ����̫��,����δ��������ƫ��
% �������궨ģ�ͣ�fb=Ka*(V - bias)   %����̬���ݽ���ƽ�������������� ģ�ͣ�
% ����ԭ�ͣ�res=mAccCaliDescent(fsbib,X,g0,flag,flag2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���������fsbib: �������������ʸ����ά��[3,M]
%          g0:   ����ֵ��������gΪ��λ��������� 1
%          X=[k11,k21,k22,k31,k32,k33,baisx,biasy,biasz]'
%          flag��ģ��ѡ��  flag=1 {fb=Ka*V-bias};   flag=2, { fb= Ka*(V-bias) }
%          flag2: ����ѡ��
%          flag2=1,{�ݶ��½�+linearSeach};  falg2=2,{�����Newton��};  flag=3,{Newton��+linearSeach}
%          flag2=4,{����㷨��Newton+�ݶ��½�+linearSeach}
%          flag2=5,{Gauss-Newton + linearSeach}
% ���������
%         
%             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : xutongxu
% Version : 1
% Date : 2020.4.8
% File : [5]Frosio, I., F. Pedersini and N.A. Borghese, Autocalibration of MEMS Accelerometers. 
% IEEE Transactions on Instrumentation and Measurement, 2009. 58(6): p. 2034-2041.
% 
switch flag2
    case 1
        [X,cfun,nums,nums2]=mDescentSteepest(fsbib,X,g0,flag);
        res=varpack(X,cfun,nums,nums2);
    case 2
        [X,cfun,nums]=mDescentClassicNewton(fsbib,X,g0,flag);
        res=varpack(X,cfun,nums);
    case 3
        [X,cfun,nums,nums2]=mDescentNewtonVa(fsbib,X,g0,flag);
        res=varpack(X,cfun,nums,nums2);
    case 4
        [X,cfun,nums,nums2]=mDescentHybridAlg(fsbib,X,g0,flag);
        res=varpack(X,cfun,nums,nums2);
    case 5
        [X,cfun,nums,nums2]=mDescentGaussNewton(fsbib,X,g0,flag);
        res=varpack(X,cfun,nums,nums2);
end
end

%% Gauss-Newton�����ʺϾ�̬����ƽ������б궨
function [X,cfun,nums,lk2]=mDescentGaussNewton(fsbib,X,g0,flag)
N=length(fsbib(1,:));

e0=1*10^(-5); aph0=1; lk2=0;
nums=0; nums2=0;
rn=0;   Jfx=zeros(9,N);
for i=1:500                                          % ����������
   % Step1: ������ۺ�����һ�׵���Jx�����׵���Hx
   [Jx,Hx,cfun]=mAccCaliHxJx1(fsbib,X,g0,flag);         % flag=1: fb=Ka*fsbib - bias;  flag=2: fb=Ka*(fsbib - bias);
   % Step2: ����Jfx
    bias=[X(7);X(8);X(9)];
    Ka=[X(1), 0,    0
        X(2), X(3), 0
        X(4), X(5), X(6)];
    if(flag==1)
        % ģ��1 ��fb=Ka*V-bias     
        fb=Ka*fsbib;  fb(1,:)=fb(1,:)-bias(1); fb(2,:)=fb(2,:)-bias(2); fb(3,:)=fb(3,:)-bias(3);
        hx=(fb(1,:).^2 + fb(2,:).^2 + fb(3,:).^2)-g0*g0;
        for j=1:N
            Jfx(1,j)=fsbib(1,j)*fb(1,j);  Jfx(2,j)=fsbib(1,j)*fb(2,j);  Jfx(3,j)=fsbib(2,j)*fb(2,j);
            Jfx(4,j)=fsbib(1,j)*fb(3,j);  Jfx(5,j)=fsbib(2,j)*fb(3,j);  Jfx(6,j)=fsbib(3,j)*fb(3,j);
            Jfx(7,j)=-fb(1,j); Jfx(8,j)=-fb(2,j); Jfx(9,j)=-fb(3,j);
        end
    end
    if(flag==2)
        % ģ��2 ��fb=Ka*(V-bias)
        fb=Ka*[fsbib(1,:)-bias(1); fsbib(2,:)-bias(2); fsbib(3,:)-bias(3)];
        hx=(fb(1,:).^2 + fb(2,:).^2 + fb(3,:).^2)-g0*g0;
        for j=1:N
            Jfx(1,j)=(fsbib(1,j)-bias(1))*fb(1,j);
            Jfx(2,j)=(fsbib(1,j)-bias(1))*fb(2,j);
            Jfx(3,j)=(fsbib(2,j)-bias(2))*fb(2,j);
            Jfx(4,j)=(fsbib(1,j)-bias(1))*fb(3,j); 
            Jfx(5,j)=(fsbib(2,j)-bias(2))*fb(3,j); 
            Jfx(6,j)=(fsbib(3,j)-bias(3))*fb(3,j);
            Jfx(7,j)=-[Ka(1,1),Ka(2,1),Ka(3,1)]*fb(:,j); 
            Jfx(8,j)=-[0,Ka(2,2),Ka(3,2)]*fb(:,j);  
            Jfx(9,j)=-Ka(3,3)*fb(3,j);
        end
    end
    Jfx=Jfx*2/N;
    M=Jfx*(Jfx');
    if(rank(M)==9)
       hGN=inv(M)*(-Jx);
    else
        hGN=pinv(M)*(-Jx)
    end
       [aph,f2,lk]=mfLineSearch(fsbib,X,g0,flag,hGN,aph0);
       X2=X + aph*hGN; lk2=lk2+lk;
       aph0=1*aph;
       nums2=nums2+1;

   % Step3: �жϵ�����ֹ����,�ο������� ��������Ϊ������ֹ����; ���ڱ��������Χ��0.9,1.1��, �þ������
   Xe=abs(X2-X);
   nums=i;
   if(max(Xe)<e0)  
       break;
   end
   X=X2;

end

if(rn>0)
fprintf('Hx �����������%d\n',rn);
end
% fprintf('lineSearch���ۺ������������%d\n',lk2);
end

%% ����㷨��Newtong's method + �ݶ��½���
function [X,cfun,nums,lk2]=mDescentHybridAlg(fsbib,X,g0,flag)
% X(k)=X(k-1) + aph*hsd
e0=1*10^(-5); aph0=1; lk2=0;
nums=0; nums2=0;
rn=0;
for i=1:500                                          % ����������
   % Step1: ������ۺ�����һ�׵���Jx�����׵���Hx
   [Jx,Hx,cfun]=mAccCaliHxJx1(fsbib,X,g0,flag);         % flag=1: fb=Ka*fsbib - bias;  flag=2: fb=Ka*(fsbib - bias);
   [r,p]=chol(Hx);  
   if(p==0) % Hx ����
       if(rank(Hx)==9)
            hN=-inv(Hx)*Jx;
       else
            hN=-pinv(Hx)*Jx;
            rn=rn+1;
        end
       f=maccCostFun(fsbib,X+hN,g0,flag);
       if(f<cfun) % �½�����
           X2=X + hN;
       else
          %line search, aph
          [aph,f2,lk]=mfLineSearch(fsbib,X,g0,flag,hN,aph0);
           X2=X + aph*hN; lk2=lk2+lk;
          aph0=1*aph;
       end
   else 
       hsd=-Jx;
       [aph,f2,lk]=mfLineSearch(fsbib,X,g0,flag,hsd,aph0);
       X2=X + aph*hsd; lk2=lk2+lk;
       aph0=1*aph;
   end
   % Step3: �жϵ�����ֹ����,�ο������� ��������Ϊ������ֹ����; ���ڱ��������Χ��0.9,1.1��, �þ������
   Xe=abs(X2-X);
   nums=i;
   if(max(Xe)<e0)  
       break;
   end
   X=X2;

end
if(nums2>0)
fprintf('Hx ������������%d\n',nums2);
end
if(rn>0)
fprintf('Hx �����������%d\n',rn);
end
% fprintf('lineSearch���ۺ������������%d\n',lk2);
end

%% ����ţ�ٷ�,aph=1
function [X,cfun,nums]=mDescentClassicNewton(fsbib,X,g0,flag)
%% Newtong's method ţ�ٷ�
% X(k)=X(k-1) + aph*hsd
e0=1*10^(-5); aph0=1;
nums=0; nums2=0;
rn=0;
for i=1:500                                          % ����������
   % Step1: ������ۺ�����һ�׵���Jx�����׵���Hx
   [Jx,Hx,cfun]=mAccCaliHxJx1(fsbib,X,g0,flag);         % flag=1: fb=Ka*fsbib - bias;  flag=2: fb=Ka*(fsbib - bias);
   [r,p]=chol(Hx);
   if(p==0) % Hx �������½�����
   else 
       nums2=nums2+1;
   end
   if(rank(Hx)==9)
       hN=-inv(Hx)*Jx;
   else
       hN=-pinv(Hx)*Jx;
       rn=rn+1;
   end
   % Step2: line search, aph
%    [aph,f2,lk]=mfLineSearch(fsbib,X,g0,flag,hsd,aph0);
   X2=X + aph0*hN;
   
   % Step3: �жϵ�����ֹ����,�ο������� ��������Ϊ������ֹ����; ���ڱ��������Χ��0.9,1.1��, �þ������
   Xe=abs(X2-X);
   nums=i;
   if(max(Xe)<e0)  
       break;
   end
   X=X2;
%    aph0=2*aph;
end
if(nums2>0)
fprintf('Hx ������������%d\n',nums2);
end
if(rn>0)
fprintf('Hx �����������%d\n',rn);
end
end

%% ţ�ٷ�,aph�仯����������
function [X,cfun,nums,lk2]=mDescentNewtonVa(fsbib,X,g0,flag)
%% Newtong's method ţ�ٷ�
% X(k)=X(k-1) + aph*hsd
e0=1*10^(-5); aph0=1; lk2=0;
nums=0; nums2=0;
rn=0;
for i=1:500                                          % ����������
   % Step1: ������ۺ�����һ�׵���Jx�����׵���Hx
   [Jx,Hx,cfun]=mAccCaliHxJx1(fsbib,X,g0,flag);         % flag=1: fb=Ka*fsbib - bias;  flag=2: fb=Ka*(fsbib - bias);
   [r,p]=chol(Hx);
   if(p==0) % Hx ����
   else 
       nums2=nums2+1;
   end
   if(rank(Hx)==9)
       hN=-inv(Hx)*Jx;
   else
       hN=-pinv(Hx)*Jx;
       rn=rn+1;
   end
   % Step2: line search, aph
   [aph,f2,lk]=mfLineSearch(fsbib,X,g0,flag,hN,aph0);
   X2=X + aph*hN;
   lk2=lk2+lk;
   % Step3: �жϵ�����ֹ����,�ο������� ��������Ϊ������ֹ����; ���ڱ��������Χ��0.9,1.1��, �þ������
   Xe=abs(X2-X);
   nums=i;
   if(max(Xe)<e0)  
       break;
   end
   X=X2;
   aph0=1*aph;
end
if(nums2>0)
fprintf('Hx ������������%d\n',nums2);
end
if(rn>0)
fprintf('Hx �����������%d\n',rn);
end
% fprintf('�������� %d, LineSeach���ۺ������������%d\n',nums,lk2);
end

%% �����½����������ݶ��½���
function [X,cfun,nums,nums2]=mDescentSteepest(fsbib,X,g0,flag)
% X(k)=X(k-1) + aph*hsd
e0=1*10^(-5); aph0=1;
nums=0; nums2=0;
for i=1:500                                          % ����������
   % Step1: ������ۺ�����һ�׵���Jx�����׵���Hx
   [Jx,Hx,cfun]=mAccCaliHxJx1(fsbib,X,g0,flag);         % flag=1: fb=Ka*fsbib - bias;  flag=2: fb=Ka*(fsbib - bias);
   hsd=-Jx;
   
   % Step2: line search, aph
   [aph,f2,lk]=mfLineSearch(fsbib,X,g0,flag,hsd,aph0);
   X2=X + aph*hsd;   nums2=nums2+lk;
   
   % Step3: �жϵ�����ֹ����,�ο������� ��������Ϊ������ֹ����; ���ڱ��������Χ��0.9,1.1��, �þ������
   Xe=abs(X2-X);
   nums=i;
   if(max(Xe)<e0)  
       break;
   end
   X=X2;
   aph0=1*aph;
end
% fprintf('final: ���ۺ������������%d\n',nums2);
end

%% ��������aph
function [aphf,f2,lk]=mfLineSearch(fsbib,X,g0,flag,hsd,aph0)
lk=1;
daph=aph0/2;
aph2=aph0/2 + daph;  aph1=aph0/2-daph;
       aph=aph1+daph;
       f1=maccCostFun(fsbib,X + aph1*hsd,g0,flag);
       f2=maccCostFun(fsbib,X + aph*hsd,g0,flag);
       f3=maccCostFun(fsbib,X + aph2*hsd,g0,flag);  
  while 1>0
      [v,ind]=min([f1,f2,f3]);
       if(ind==3)
            %ǿ��aph2<=1
            if(aph2>=1)
                daph=daph*0.9;
                aph=aph1+daph; aph2=aph+daph;
                f2=maccCostFun(fsbib,X + aph*hsd,g0,flag); 
                f3=maccCostFun(fsbib,X + aph2*hsd,g0,flag); 
            else
                aph1=aph2-daph;  aph=aph2;  aph2=aph2+daph;
                f1=f2;  f2=f3; 
                f3=maccCostFun(fsbib,X + aph2*hsd,g0,flag); 
            end  
            aphf=aph2;
 
       else
          if(ind==2)
              daph=daph*0.5; aphf=aph;
              aph1=aph-daph;  aph2=aph+daph;
              f1=maccCostFun(fsbib,X + aph1*hsd,g0,flag);
              f3=maccCostFun(fsbib,X + aph2*hsd,g0,flag);  
          else
              if(ind==1)
                  aphf=aph1;
                  aph2=aph;  aph=aph1; aph1=aph1-daph;
                  f3=f2;     f2=f1;
                  f1=maccCostFun(fsbib,X + aph1*hsd,g0,flag);
              end
          end
       end
       if(daph<1*10^(-6))
           break;
       end
       lk=lk+1;
  end
end

% ���ۺ���
function f=maccCostFun(fsbib,X,g0,flag)
    N=length(fsbib(1,:));
    bias=[X(7);X(8);X(9)];
    Ka=[X(1), 0,    0
        X(2), X(3), 0
        X(4), X(5), X(6)];
    if(flag==1)
        % ģ��1 ��fb=Ka*V-bias     
        fb=Ka*fsbib;  fb(1,:)=fb(1,:)-bias(1); fb(2,:)=fb(2,:)-bias(2); fb(3,:)=fb(3,:)-bias(3);
        hx=(fb(1,:).^2 + fb(2,:).^2 + fb(3,:).^2)-g0*g0;
        f=sum(hx.^2)/N;   % ���ۺ���
    end
    if(flag==2)
        % ģ��2 ��fb=Ka*(V-bias)
        fb=Ka*[fsbib(1,:)-bias(1); fsbib(2,:)-bias(2); fsbib(3,:)-bias(3)];
        hx=(fb(1,:).^2 + fb(2,:).^2 + fb(3,:).^2)-g0*g0;
        f=sum(hx.^2)/N;   % ���ۺ���
    end
end
