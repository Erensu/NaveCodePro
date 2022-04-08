function kf_res = kfCalibrated_Xu(imu,davp,imuerr,avp0)
%% -----------Introduction------------
%18ά�������˲���ϵͳ���궨
%input: 
%-------imu : ����������N*7 ��λ��rad/s   m/s^2
%-------davp : ��������Kalman P�� 18*1
%-------imuerr : ��������Kalman Q�� 
%-------avp0  �� ��ʼ��̬��Ϣ  9*1
%output
%-------res.avp: N*10 ������Ϣ����׼��λ���ȡ�m/s ��m 
%-------res.xkpk: 2*N  ����ֵ��Э������
%%  data length and time
N = length(imu(:,end));
%% kalmman������ʼ��
eth= EarthParameter(avp0(7:9),avp0(4:6));
kf = []; m  = 6; n =15;    
kf.m = m;  kf.n = n;
% kf.Pk=diag([ones(1,2)*0.1*pi/180, 0.001*pi/180, ones(1,3)*0.001, ...
%     0.005*[1,1]/eth.RMh, 0.005,ones(1,6)*0.003]).^2;  % ���ڷ���

kf.Pk=diag([ones(1,2)*0.2*pi/180, 0.001*pi/180, ones(1,3)*0.06, ...
    0.06*[1,1]/eth.RMh, 0.06,ones(1,6)*0.003]).^2;  % ����ʵ���ֶ�ҡ��

kf.Qt = diag([imuerr.web; imuerr.wdb; zeros(kf.n-6,1)]).^2;

kf.Rk=diag([ones(1,3)*0.03, 0.05/eth.RMh, 0.05/eth.RNh, 0.02]).^2;

kf.Gammak = eye(kf.n);
kf.adaptive = 0; 
kf.pconstrain = 0;
kf.I = eye(kf.n);
%% others parameter setting

%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);%kf.Xk(13:15) = [1;1;1];
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,10); 
xkpk = zeros(N ,2*kf.n);   
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);pos0 = pos;
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
avp(1,:) = [att',vel',pos',t(1)];
xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
%% Algorithm develop
timebar(1,N,'���������ϵͳ���궨');
for i= 2:N 
        wbib = imu(i,1:3)' ;
        fb = imu(i,4:6)' ;
        dt = imu(i,end) - imu(i-1,end);
        t(i) = imu(i,end);
        %% �ߵ�����
        [att,vel,pos,qua,Cnb,eth] = avp_update(wbib,fb,Cnb,qua,pos,vel,dt);
        %-------------kalmanԤ��-------------------  
        F = KF_Phi(eth,Cnb,fb,kf.n);
                      %% edited by xutongxu.(2021.8.6)
        F(10:15,10:15)=zeros(6,6);
        F(1:3,10:15)=Cnb*[wbib(2),wbib(3), zeros(1,4);...
                                           0,0,wbib(1), wbib(3),0,0;...
                                           0,0,0,0,wbib(1),wbib(2)];
                      %%
%         F(1:3,19:21)   = -Cnb;            
        kf.Phikk_1 = kf.I + F*dt;%��ɢ������̩��չ��
        kf.Xk = kf.Phikk_1*kf.Xk;           xk = kf.Xk;
        
       kf.Gammak(1:3,1:3) = -Cnb;   kf.Gammak(4:6,4:6) = Cnb;  
       kf.Gammak(7:15,7:15)=eye(9,9); % 2021.8.16
       Gk=kf.Gammak*dt;                                                             % 2021.8.16
       
        kf.Qk = kf.Qt;
        kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + Gk*kf.Qk*Gk';
        %-------------kalman����------------------- 		
        kf.Xkk_1 = kf.Xk;
        kf.Pkk_1 = kf.Pk;
        Zk = [vel; 
              pos-pos0];        zk(i,:) = Zk';	
        kf.Hk =zeros(kf.m,kf.n);kf.Hk(1:6,4:9) = eye(6);
%          kf.Rk = diag([davp(4:6)*1.5;davp(7:9)/5]).^2;
        kf.rk = Zk - kf.Hk*kf.Xkk_1;%�в�
        kf.PXZkk_1 = kf.Pkk_1*kf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������
        kf.PZZkk_1 = kf.Hk*kf.PXZkk_1 + kf.Rk;%����һ��Ԥ����������
        kf.Kk = kf.PXZkk_1*invbc(kf.PZZkk_1);
        kf.Xk = kf.Xkk_1 + kf.Kk*kf.rk;
        kf.Pk = kf.Pkk_1 - kf.Kk*kf.PZZkk_1*kf.Kk';
        kf.Pk = (kf.Pk+kf.Pk')/2;
        [att,pos,vel,qua,Cnb,kf,xk]= feed_back_correct(kf,[att;vel;pos],qua);             
        avp(i,:) = [att',vel',pos',t(i)];
        xkpk(i,:) = [xk',diag(kf.Pk)'];
        timebar;
end
kf_res = varpack(avp,xkpk,zk);
end