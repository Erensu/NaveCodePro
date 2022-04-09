function  RTS_res = smooth_RTS(imu,gnss,davp,imuerr,avp0)
%% -----------Introduction------------
%15άRTSƽ���������˲� ��������ȡ1s
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
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,10);
avp_smooth = zeros(N,10);
dx = zeros(kf.n, N);%������µ�״̬
dx_timeupd = zeros(kf.n, N);%ʱ����µ�״̬
dx_smooth = zeros(kf.n, N);%ƽ����״̬
cov = zeros(kf.n, N);
cov_smooth = zeros(kf.n,N);
P = zeros(kf.n,kf.n,N);
P_timeupd = zeros(kf.n,kf.n,N);
P_smooth = zeros(kf.n,kf.n,N);
F = zeros(kf.n,kf.n,N);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua(:,1) = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
dx(:,1) = kf.Xk;
dx_timeupd(:,1) =  kf.Xk;

P_timeupd(:,:,1) = kf.Pk;
P(:,:,1)= kf.Pk;
avp(1,:) = [att',vel',pos',t(1)];
avp_smooth(1,:) = avp(1,:);
cov_smooth(:,1) = diag(kf.Pk);
%% others parameter setting
seg_start = 2;
seg_end = N ;
ki = 1;seg=[];c=0;flag = 0;
%% Algorithm develop
timebar(1,N,'1s��������RTS Smoothing.');
while(1)
%---------------ǰ���˲�-------------------------
    for i = seg_start:seg_end 
        wbib = imu(i,1:3)' ;
        fb = imu(i,4:6)' ;
        dt = imu(i,end) - imu(i-1,end);
        t(i) = imu(i,end);
        %% �ߵ�����
        [att,vel,pos,qua(:,i),Cnb] = avp_update(wbib,fb,Cnb,qua(:,i-1),pos,vel,dt);
        eth = EarthParameter(pos,vel);%���µ�ǰʱ�̵����ʰ뾶
        %-------------kalmanԤ��-------------------      
        kf.Phikk_1 = kf.I + KF_Phi(eth,Cnb,fb,kf.n)*dt;%��ɢ������̩��չ��
        kf.Xk = kf.Phikk_1*kf.Xk; xk = kf.Xk;
        kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
        kf.Qk = kf.Qt*dt;
        kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + kf.Gammak*kf.Qk*kf.Gammak';
        dx_timeupd(:,i) = xk;%�洢ʱ����µ�״̬��
        P_timeupd(:,:,i) = kf.Pk;%�洢ʱ����µ�״̬Э������
        F(:,:,i) = kf.Phikk_1;
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
            [att,pos,vel,qua(:,i),Cnb,kf,xk]= feed_back_correct(kf,[att;vel;pos],qua(:,i));
            ki = ki+1;
            c=c+2;
            if c == 1
                flag =1;
                c=0;
            end            
        end
        avp(i,:) = [att',vel',pos',t(i)];
        dx(:,i) =xk;%����������ֵʱ��dx_timeupd��ͬ            
        P(:,:,i) = kf.Pk;
        cov(:, i) = diag(kf.Pk);
        if flag
            seg_end = i;
            flag = 0;
            break;
        end
    timebar;  
    end
%--------------------�����˲�-----------------------
%reference :[1].	Liu, H., S. Nassar and N. El-Sheimy, Two-Filter Smoothing for Accurate INS/GPS Land-Vehicle Navigation in Urban Centers. IEEE Transactions on Vehicular Technology, 2010. 59(9): p. 4256-4267.
    %��ʼ������,��������Ľ��
    dx_smooth(:,seg_end)= dx(:,seg_end);
    P_smooth(:,:,seg_end)=P(:,:,seg_end);
    cov_smooth(:,seg_end) = diag(P_smooth(:,:,seg_end));
    for i = seg_end-1:-1:seg_start 
        %ִ��RTS�㷨
        Ks_k = P(:,:,i)*F(:,:,i)'*invbc(P_timeupd(:,:,i+1));       
        dx_smooth(:,i) = dx(:, i) + Ks_k*(dx_smooth(:,i+1)-dx_timeupd(:,i+1));
        P_smooth(:,:,i) = P(:,:,i) + Ks_k*( P_smooth(:,:,i+1)-P_timeupd(:,:,i+1))*Ks_k';
        P_smooth(:,:,i) = (P_smooth(:,:,i)+P_smooth(:,:,i)')/2;
        cov_smooth(:,i) = diag(P_smooth(:, :, i));
    end
    %---------------��������------��̬��Ҫƽ����
    for i = seg_start:seg_end 
        avp_smooth(i,4:9) = avp(i,4:9) -1*dx_smooth(4:9,i)'; 
        qua(:,i) = qdelphi(qua(:,i), dx_smooth(1:3,i));
        Cnb = q2mat(qua(:,i));
        avp_smooth(i,1:3) =  m2att(Cnb);
    end
    vel = avp_smooth(seg_end,4:6)';
    pos = avp_smooth(seg_end,7:9)';
    dx(1:9,seg_end) = zeros(1,9);kf.Xk(1:9)=0;
    %�жϷֶ�
    seg = [seg seg_end];   
    if seg_end~=N
        seg_start = seg_end + 1;
        seg_end = N;
    else
        break;
    end
end

RTS_res = varpack( avp_smooth,cov_smooth, seg, P, P_smooth, dx, dx_smooth);
end