function res=mfunRef43(wib_b,fib_b,tm,imupara,kf,pos0,flag)
% �����е�ת��˳��ʱ��. �÷������ݱȽ�����,û��ʵ���ֶ�ת��ʱ�ĸ��š���.
%--------------------------------------------------------------------------
% ���������
%               imupara:�ṹ��{Asba, Asbg, Sa, Sg, abias, gbias, wb,ab}
%               Asba, Asbg: ����ϵ���Ӽơ����ݵı任����.     Sa,Sg: �Ӽơ����ݱ������
%               abias,gbias: �Ӽơ�������ƫ, 3*1, ��λ��m/s2, rad/s
%               ab,wb:  �Ӽơ����ݾ�̬���ݱ�׼��. �ɸ���������ߺͺ��� Arw_Vrw2std()��ȡ.
%  Cb0p: �̶�imu�Ŀ��,�����ڴ���ʯƽ̨��, ��ܳ�ʼʱ,�Ӽ�����������ϵ ��ƽ̨ϵ֮��任����(�����Ӽ�����֮��İ�װ��)
%  g0: ���� ������ֵ.      L0:����γ��       dt:�������
%  ����: imupara.Asba=eye(3,3);  imupara.Asbg=eye(3,3)+askew([0.5;0.5;0.6]*pi/180);
%        imupara.Sa=eye(3,3)*0.9992;  imupara.Sg=eye(3,3)*0.98; 
% imupara.abias=[1;1;1]*0.03; imupara.gbias=[1;1;1]*0.05;   imupara.ab=[1;1;1]*0.01; imupara.wb=[1;1;1]*0.05;
%  ���������
%    �ṹ��res=varpack(Xki,GyroBias,AccBias,posi,atti,Veni,stPki,gmInd);
%  
% Author : xutongxu
% Version : 1 
% Date :2021.6.27
% File: Zhou Q ,  Yu G ,  Li H , et al. A Novel MEMS Gyroscope In-Self Calibration Approach[J]. Sensors, 2020, 20(18).
%% ��ʼ������
% ����ǰ9s����Ϊ��ֹ
% eth=earth(pos0,zeros(3,1));
eth = EarthParameter(pos0,zeros(3,1));
dt=tm(2)-tm(1);   nt=round(1/dt);
fb0=mean(fib_b(:,1:nt*4),2);
wb0=mean(wib_b(:,1:nt*4),2);       % ��ֹ������ƫ

pitch0=asin(fb0(2)/eth.g);
roll0=atan2(-fb0(1), fb0(3));

att0=[pitch0; roll0; 0];  Cnb=a2mat(att0);  qnb=m2qua(Cnb);
N=length(tm);

% --------KF ������ʼ��---------
if(flag==2)
    % �ⲿ���� kf����
    kf.Xk=zeros(9,1);
else
    % �Զ�����
    kf.Pk=diag([3*imupara.ab(1)*ones(1,3)/eth.g, ones(1,3)*0.06, ones(1,3)*0.08]).^2;
    kf.Qk=diag(1.5*imupara.wb(1)*ones(1,3)).^2;
    kf.Rk=diag(1.5*imupara.wb(1)*eth.g*ones(1,3));
    kf.Xk=zeros(9,1);
end
Hk=zeros(3,9);   Hk(2,1)=eth.g;    Hk(1,2)=-eth.g;    G=zeros(9,3);
%% �����ڴ�
Xki=zeros(N,9);   
Pki=zeros(N,9);   Zki=zeros(3,N);   atti=zeros(3,N);
eIn=eye(9,9);     atti(:,1)=att0;
%% �������㷨
g0=eth.g;
gn=([0,0,-g0])'; 
fn= -gn;
% ����ǰ�����ݾ�ֹ,���Դӵ�2֡��ʼ����. ��������, ����Ϊҡ�����ݼ�, �������߼��ٶ�.

for i=2:N
     dt=tm(i)-tm(i-1);
     wbibk=0.5*(wib_b(:,i)+wib_b(:,i-1))-wb0;
     fib=fib_b(:,i);
     % 1. ��̬����
     qnb=qupdt(qnb,wbibk*dt);
     Cnbk=q2mat(qnb);        
   
     % 2. ��������
     fnj=(Cnbk)*fib;
     Zk=fnj-fn;
     Zki(:,i)=Zk;
     % 3. KF�˲�
     Ft=getFt(Cnb, wbibk);  G(1:3,1:3)=Cnb;  Gk=G*dt;
     Phik=eIn +Ft*dt;
     
     Xkk_1=Phik*kf.Xk;     
     Pkk_1=Phik*kf.Pk*(Phik') + Gk*kf.Qk*(Gk');
%      Pkk_1 =  0.5* (Pkk_1 + Pkk_1');       
     Kk=Pkk_1*(Hk')*((Hk*Pkk_1*(Hk') + kf.Rk)^(-1));
     % ����
     kf.Xk=Xkk_1 + Kk*(Zk - Hk*Xkk_1);
     kf.Pk=(eIn - Kk*Hk)*Pkk_1;
     
     % 4. ����
     % ��̬����������
%      ra=1;
%      qx=rv2q(ra*kf.Xk(1:3));    Cn_n1=q2mat(qx);
%      Cnbk=(Cn_n1)*Cnbk;         
%      kf.Xk(1:3)=kf.Xk(1:3)*(1-ra);
    
     Xki(i,:)=kf.Xk';
     Pki(i,:)=diag(kf.Pk)';
     
     Cnb=Cnbk;  qnb=m2qua(Cnb);   atti(:,i)=m2att(Cnb);
end
Xki(1,:)=Xki(2,:);
Pki(1,:)=Pki(2,:);
res=varpack(Xki,Pki,Zki,atti);

end

function Ft=getFt(Cnb,wib_b)
Ft=zeros(9,9);
Ft(1:3,4:6)=Cnb*diag(wib_b);
Ft(1:3,7:9)=-Cnb*askew(wib_b);

end
