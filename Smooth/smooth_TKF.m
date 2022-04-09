function TKF_res = smooth_TKF(imu,gnss,davp,imuerr,avp0)
%% -----------Introduction------------
%15ά˫��ƽ���������˲�
%input: 
%-------imu : ����������N*7 ��λ��rad/s   m/s^2
%-------gnss: �����ź� N*8 �����ڶ����Ƕ�λ��������  ��λ�� m/s     rad rad m 
%-------davp : ��������Kalman P�� 15*1
%-------imuerr : ��������Kalman Q�� 
%-------avp0  �� ��ʼ��̬��Ϣ  9*1
%output
%-------res.avp: N*15 ������Ϣ����׼��λ���ȡ�m/s ��m 
%-------res.xkpk: 2*N  ����ֵ��Э������
%%  data length and time
N = length(imu(:,end));
L_GNSS = length(gnss(:,end));
%% kalmman������ʼ��
kf = []; m  = 6; n =15;
kf.m = m;  kf.n = n;
kf.Pk = 10*diag([davp(1:3); davp(4:6); davp(7:9); imuerr.eb; imuerr.db])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb;zeros(kf.n-6,1)]).^2;
kf.Gammak = eye(kf.n);
kf.I = eye(kf.n);
%% others parameter setting
ki =1;
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,kf.n+1);  %�����ںϣ�����ƫ����ͬʱ�洢
dx_mea_upd = zeros(N,kf.n);
cov_p_mea = zeros(N,kf.n); 
% xkpk = zeros(N ,2*kf.n);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
dx_mea_upd(1,:) = kf.Xk;
cov_p_mea(1,:) = diag(kf.Pk);
gb_est = kf.Xk(10:12);
ab_est = kf.Xk(13:15);
avp(1,:) = [att',vel',pos',gb_est',ab_est',t(1)];
%% Algorithm develop
timebar(1,N,'forward processing.');
for i= 2:N 
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
    %-------------kalman����------------------- 		
    if (ki<=L_GNSS && gnss(ki,7)> 7)   %����DPOP�ж������Ƿ����
        gnss(ki,:) = [];
        L_GNSS =L_GNSS - 1;
    end 
    if ki<=L_GNSS && gnss(ki,end)<=imu(i,end)  
        kf.Xkk_1 = kf.Xk;
        kf.Pkk_1 = kf.Pk;
        Zk = [vel-gnss(ki,1:3)';
              pos-gnss(ki,4:6)'];	
        kf.Hk =zeros(kf.m,kf.n);kf.Hk(1:6,4:9) = eye(6);
        kf.Rk = diag([davp(4:6);davp(7:9)]).^2;
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
    dx_mea_upd(i,:) = xk;
    cov_p_mea(i,:) = diag(kf.Pk);
    gb_est = kf.Xk(10:12);
    ab_est = kf.Xk(13:15);
    avp(i,:) = [att',vel',pos',gb_est',ab_est',t(i)];
    timebar;
end
%---------------------�����˲�------------------------
%% others parameter setting
vel = -vel;
ikf = kf;
idx = [4:6,10:12];
ikf.Pk = 10*ikf.Pk; %����P�����
%% Memory allocation
iavp = zeros(N,ikf.n+1);% 
idx_mea_upd = zeros(N,ikf.n);
icov_p_mea = zeros(N,ikf.n);
%% Initial data
ikf.Xk(idx) = -ikf.Xk(idx);ikf.Xk(1:9) = 1.5*ikf.Xk(1:9);
iavp(N,:) = avp(end,:);iavp(N,idx) = -iavp(N,idx);
idx_mea_upd(N,:) = ikf.Xk;
icov_p_mea(N,:) = diag(ikf.Pk);
ki = L_GNSS;
%% Algorithm develop
timebar(1,N,'backward processing.');
for i = N-1:-1:1
    wbib = -imu(i,1:3)' ;
    fb = imu(i,4:6)' ;
    dt = imu(i+1,end) - imu(i,end);
    t(i) = imu(i,end);
%---------------�����Խ���    
    ieth = reverseEarthParameter(pos,vel);
    wbnb = wbib - Cnb'*ieth.wnin;%bϵ��
    qua = qupdt(qua,wbnb*dt);%wbnb*dt���൱�ڵ�Ч��ת����rv
    Cnb = q2mat(qua);
    att = m2att(Cnb);

    fn = Cnb*fb;
    an = fn + ieth.gcc;
    vel = vel+ an*dt;

    Mpv = [0 1/ieth.RMh 0;1/ieth.clRNh 0 0;0 0 1];
    pos = pos + Mpv*vel*dt;
%     Cnb = Cnbk;   
    
    ieth = reverseEarthParameter(pos,vel);%���µ�ǰʱ�̵����ʰ뾶
    ikf.Phikk_1 = ikf.I + KF_Phi(ieth,Cnb,fb,15)*dt;%��ɢ������̩��չ��
    ikf.Xk = ikf.Phikk_1*ikf.Xk;xk = ikf.Xk;
    ikf.Gammak(1:3,1:3) = -Cnb; ikf.Gammak(4:6,4:6) = Cnb;
    ikf.Qk = ikf.Qt*dt;
    ikf.Pk = ikf.Phikk_1*ikf.Pk*ikf.Phikk_1' + ikf.Gammak*ikf.Qk*ikf.Gammak';
     if ( (ki<=L_GNSS)&& (imu(i,end)-gnss(ki,end)<=1e-6))   %��ֹmatlab���ݸ�ʽ��һ��
        Zk = [vel-(-gnss(ki,1:3))';
              pos-gnss(ki,4:6)'];	
        ikf.Xkk_1 = ikf.Xk;
        ikf.Pkk_1 = ikf.Pk;
        ikf.PXZkk_1 = ikf.Pkk_1*ikf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������	
        ikf.rk = Zk - ikf.Hk*ikf.Xkk_1;%�в�        
        ikf.PZZkk_1 = ikf.Hk*ikf.PXZkk_1 + ikf.Rk;%����һ��Ԥ����������
        ikf.Kk = ikf.PXZkk_1*invbc(ikf.PZZkk_1);
        ikf.Xk = ikf.Xkk_1 + ikf.Kk*ikf.rk;
        ikf.Pk = ikf.Pkk_1 - ikf.Kk*ikf.PZZkk_1*ikf.Kk';
        ikf.Pk = (ikf.Pk+ikf.Pk')/2;
        [att,pos,vel,qua,Cnb,ikf,xk]= feed_back_correct(ikf,[att;vel;pos],qua);
        ki = ki-1;
        if ki == 0
            ki=1;
        end
     end
    idx_mea_upd(i,:) = xk;
    icov_p_mea(i,:) = diag(ikf.Pk);
    gb_est = ikf.Xk(10:12);
    ab_est = ikf.Xk(13:15);    
    iavp(i,:) = [att',vel',pos',gb_est',ab_est',t(i)];
    timebar;
end
iavp(:,idx) = -iavp(:,idx);
ps = cov_p_mea + icov_p_mea;  % �Ͻ̲� P149  ��ʽ6.3.16  ע�⣺�ںϵ���avp�����������״̬���������
xs = icov_p_mea./(cov_p_mea + icov_p_mea).*avp(:,1:end-1)+...
cov_p_mea./(cov_p_mea + icov_p_mea).*iavp(:,1:end-1);

TKF_res = varpack(avp,iavp,xs,ps,cov_p_mea,dx_mea_upd,icov_p_mea,idx_mea_upd);
end