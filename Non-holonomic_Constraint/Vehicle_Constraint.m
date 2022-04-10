function kf_res = Vehicle_Constraint(imu,davp,imuerr,avp0)
%% -----------Introduction------------
%6*17ά����Լ��Kalman�˲�  �������µ�Լ�� ��GNSS
%�۲����������ٶȣ��߶ȣ��������������ٶȣ�������̬�� �����̬��
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
kf = []; m  = 6; n =17;
kf.m = m;  kf.n = n;
kf.Pk = 10*diag([davp(1:3); davp(4:6); davp(7:9); imuerr.eb; imuerr.db;[5;5]*pi/180])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb;zeros(kf.n-6,1)]).^2;
kf.Gammak = eye(kf.n);
kf.I = eye(kf.n);
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,10);
xkpk = zeros(N ,2*kf.n);
Vu =  zeros(N,1);
h = zeros(N,1);
pitch  = zeros(N,1);
roll = zeros(N,1);
vm0 = zeros(3,N);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
avp(1,:) = [att',vel',pos',t(1)];
xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
%% others parameter setting
Vu(1) = vel(3);h(1) = pos(3);pitch(1) = att(1);roll(1) = att(2);
mbatt = [0;0;0];
Cmb = a2mat(mbatt.*glv.deg);
%% Algorithm develop
timebar(1,N,'��̬�ٶ�λ��Լ��Kalman');
for i= 2:N 
    wbib = imu(i,1:3)' ;%����������ƫ������ȷʱ���ᵼ��imu���ݲ���ȷ�����ֲ���״
    fb = imu(i,4:6)' ;
    %% �ߵ�����
    [att,vel,pos,qua,Cnb] = avp_update(wbib,fb,Cnb,qua,pos,vel,dt);
    eth = EarthParameter(pos,vel);%���µ�ǰʱ�̵����ʰ뾶
    Vu(i) = vel(3);h(i) = pos(3);pitch(i) = att(1);roll(i) = att(2);
    %-------------kalmanԤ��-------------------      
    kf.Phikk_1 = kf.I + KF_Phi(eth,Cnb,fb,kf.n)*dt;%��ɢ������̩��չ��
    kf.Xk = kf.Phikk_1*kf.Xk; xk = kf.Xk;
    kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
    kf.Qk = kf.Qt*dt;
    kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + kf.Gammak*kf.Qk*kf.Gammak';
    %-------------kalman����------------------- 
    Cbn = Cnb';
    vm = Cmb*Cbn*vel;vm0(:,i) = vm;
    M2 = -Cmb*Cbn*askew(vel);M1 = Cmb*Cbn; M3 = Cmb*askew(Cbn*vel);        
    Zk = [Vu(i)-Vu(i-1);
          h(i)-h(i-1);
          vm(1);
          vm(3);
          pitch(i)-pitch(i-1);
          roll(i)-roll(i-1);
          ];
    kf.Hk = [
             zeros(1,5) 1       zeros(1,11) 
             zeros(1,8) 1       zeros(1,8) 
             M2(1,:)    M1(1,:) zeros(1,9) 0       M3(1,3);
             M2(3,:)    M1(3,:) zeros(1,9) M3(3,1) 0;
             1          0       zeros(1,15);
             0          1       zeros(1,15);
            ];
    kf.Rk = 10*diag([0.05;0.1;0.05;0.05;0.2;0.1])^2;%             
    kf.rk = Zk - kf.Hk*kf.Xkk_1;%�в�
    kf.PXZkk_1 = kf.Pkk_1*kf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������
    kf.PZZkk_1 = kf.Hk*kf.PXZkk_1 + kf.Rk;%����һ��Ԥ����������
    kf.Kk = kf.PXZkk_1*invbc(kf.PZZkk_1);
    kf.Xk = kf.Xkk_1 + kf.Kk*kf.rk;
    kf.Pk = kf.Pkk_1 - kf.Kk*kf.PZZkk_1*kf.Kk';
    kf.Pk = (kf.Pk+kf.Pk')/2; 
    %-------------����У��------------------- 
    [att,pos,vel,qua,Cnb,kf,xk]= feed_back_correct(kf,[att;vel;pos],qua);

    avp(i,:) = [att',vel',pos',t(i)];
    xkpk(i,:) = [xk',diag(kf.Pk)'];
    timebar;
end
kf_res = varpack(avp,xkpk);
end