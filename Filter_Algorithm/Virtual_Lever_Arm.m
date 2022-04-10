function res186 = Virtual_Lever_Arm(imu,gnss,davp,imuerr,avp0)
%% -----------Introduction------------
%18ά�������˲� ����˱۹۲ⷽ��
%input: 
%-------imu : ����������N*7 ��λ��rad/s   m/s^2
%-------gnss: �����ź� N*8 �����ڶ����Ƕ�λ��������  ��λ�� m/s     rad rad m 
%-------davp : ��������Kalman P�� 18*1
%-------imuerr : ��������Kalman Q�� 
%-------avp0  �� ��ʼ��̬��Ϣ  9*1
%output
%-------res.avp: N*10 ������Ϣ����׼��λ���ȡ�m/s ��m 
%-------res.xkpk: 2*N  ����ֵ��Э������
%ref:[1].	Borko, A., I. Klein and G. Even-Tzur, GNSS/INS Fusion with Virtual Lever-Arm Measurements. Sensors, 2018. 18(7): p. 2228.
%%  data length and time
N = length(imu(:,end));
L_GNSS = length(gnss(:,end));
%% kalmman������ʼ��
kf = []; m  = 7; n =18;
kf.m = m;  kf.n = n;
kf.Pk = 10*diag([davp(1:3); davp(4:6); davp(7:9); imuerr.eb; imuerr.db;[5;5;5]])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb;zeros(kf.n-6,1)]).^2;
kf.Gammak = eye(kf.n);
kf.adaptive = 0; 
kf.pconstrain = 0;
kf.I = eye(kf.n);
%% others parameter setting
ki =1;
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
%% Algorithm develop
timebar(1,N,'SINS/GPS186����˱۹۲�');
for i= 1:L_INS
        wbib = imu(i,1:3)' ;
        fb = imu(i,4:6)' ;
        dt = imu(i,end) - imu(i-1,end);
        t(i) = imu(i,end);
        %% �ߵ�����
        [att,vel,pos,qua,Cnb] = avp_update(wbib,fb,Cnb,qua,pos,vel,dt);
        eth = EarthParameter(pos,vel);%���µ�ǰʱ�̵����ʰ뾶
        %-------------kalmanԤ��-------------------      
        kf.Phikk_1 = kf.I + KF_Phi(eth,Cnb,fb,kf.n)*dt;%��ɢ������̩��չ��
        kf.Xk = kf.Phikk_1*kf.Xk; xk = kf.Xk;
        kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
        kf.Qk = kf.Qt*dt;
        kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + kf.Gammak*kf.Qk*kf.Gammak';
        if (ki<=L_GNSS && gnss(ki,7)> 7)   %����DPOP�ж������Ƿ����
            gnss(ki,:) = [];
            L_GNSS =L_GNSS - 1;
        end 
		if ki<=L_GNSS && gps(ki,end)<=imu(i,end)
            kf.Xkk_1 = kf.Xk;
            kf.Pkk_1 = kf.Pk;
			lb_ = lb +0.01*rand(3,1);			
            Zk = [vel-gnss(ki,1:3)';
                  pos-gnss(ki,4:6)'��
				  lb_-lb];			
			Mpv = [0,                 1/eth.RMh, 0;
				   1/(eth.RNh*eth.cl),0,         0;
				   0,                 0,         1];
			kf.Hk = [zeros(3,3) eye(3)     zeros(3,3) zeros(3,6) -Cnb*askew(wbib-Cnb'*eth.wnie);                                               % 
					 zeros(3,3) zeros(3,3) eye(3)     zeros(3,6) -Mpv*Cnb;
					 zeros(3,3) zeros(3,3) zeros(3,3) zeros(3,6) eye(3)];
			kf.Rk = diag([davp(4:6);davp(7:9)��0.5]).^2;		 
            kf.rk = Zk - kf.Hk*kf.Xkk_1;%�в�
            kf.PXZkk_1 = kf.Pkk_1*kf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������
            kf.PZZkk_1 = kf.Hk*kf.PXZkk_1 + kf.Rk;%����һ��Ԥ����������
            kf.Kk = kf.PXZkk_1*invbc(kf.PZZkk_1);
            kf.Xk = kf.Xkk_1 + kf.Kk*kf.rk;
            kf.Pk = kf.Pkk_1 - kf.Kk*kf.PZZkk_1*kf.Kk';
            kf.Pk = (kf.Pk+kf.Pk')/2;
            [att,pos,vel,qua,Cnb,kf,xk]= feed_back_correct(kf,[att;vel;pos],qua);             
            ki = ki+1;        
    end
    xkpk(i,:) = [xk',diag(kf.Pk)'];     
	avp(i,:) = [att'/glv.deg,vel',pos(1:2)'/glv.deg,pos(3),t];
    timebar;
end
%% Return Results and Save Workspace
res186 = varpack(avp,xkpk); 
end