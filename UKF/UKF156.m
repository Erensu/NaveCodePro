function res = UKF156(imu,gnss,davp,imuerr,avp0)
%% -----------Introduction------------
%15άUKF�˲� ,�������������Լ��Ը�˹����������û�н���UT�任��
%input: 
%-------imu : ����������N*7 ��λ��rad/s   m/s^2
%-------gnss: �����ź� N*8 �����ڶ����Ƕ�λ��������  ��λ�� m/s     rad rad m 
%-------davp : ��������Kalman P�� 15*1
%-------imuerr : ��������Kalman Q�� 
%-------avp0  �� ��ʼ��̬��Ϣ  9*1
%output
%-------res.avp: N*10 ������Ϣ����׼��λ���ȡ�m/s ��m 
%-------res.xkpk: 2*N  ����ֵ��Э������
%%  data length and time
N = length(imu(:,end));
L_GNSS = length(gnss(:,end));
%% kalmman������ʼ��
kf = []; m  = 6; n =15;
kf.m = m;  kf.n = n;
kf.Pk = 10*diag([davp(1:3); davp(4:6); davp(7:9); imuerr.eb; imuerr.db])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb]).^2;
kf.Rk = diag([davp(4:6);davp(7:9)]).^2;
kf.Gammak = eye(kf.n,kf.m);
kf.I = eye(kf.n);
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,10);
xkpk = zeros(N ,2*kf.n);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
avp(1,:) = [att',vel',pos',t(1)];
xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
%% others parameter setting
[gamma,Wm,Wc] = UKFParameter(kf.n);
k=1;
%% Algorithm develop
ki = timebar(1,N, 'UKF INS/GPS�ٶ�λ�����.');
for i = 2:N
        wbib = imu(i,1:3)' ;
        fb = imu(i,4:6)' ;
        dt = imu(i,end) - imu(i-1,end);
        t(i) = imu(i,end);
        %% �ߵ�����
        [att,vel,pos,qua,Cnb] = avp_update(wbib,fb,Cnb,qua,pos,vel,dt);
        if k<=L_GNSS && gnss(k,end)<=imu(i,end)
            Z = [vel;pos]-gnss(k,1:6)';H = [zeros(6,3) eye(6),zeros(6,6)];
            kf = ukf_filter(kf,[att;vel;pos;],imu(i,1:6),gamma,Wm,Wc,dt,1,Z,H);
            xk = kf.Xk;  
            %���з���
            vel = vel - kf.Xk(4:6);
            pos = pos- kf.Xk(7:9);
            qua = qdelafa(qua, kf.Xk(1:3));Cnb = q2mat(qua);att = m2att(Cnb);
            kf.Xk(1:9)= 0;        
            k = k+1;
        else
            kf = ukf_filter(kf,[att;vel;pos;],imu(i,1:6),gamma,Wm,Wc,dt,0);
            xk = kf.Xk; 
        end
        avp(i,:) = [att',vel',pos',t(i)];
        xkpk(i,:) = [xk',diag(kf.Pk)'];
        timebar;
end 		
%% Save Workspace
res =  varpack(avp,xkpk); 
end