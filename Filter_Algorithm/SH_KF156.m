function kf_res = SH_KF156(imu,gnss,davp,imuerr,avp0)
%% -----------Introduction------------
%Sage-Husa����Ӧ�������˲�
%��Ҫע������⣺1.ͬ��ʱ����봦��ã�������imugpsavpr���ݲ��� 2.F1���������������
%����Ӧ�����뷽������
%input: 
%-------imu : ����������N*7 ��λ��rad/s   m/s^2
%-------gnss: �����ź� N*7 ������λ��������  ��λ�� m/s     rad rad m 
%-------davp : ��������Kalman P�� 15*1
%-------imuerr : ��������Kalman Q�� 
%-------avp0  �� ��ʼ��̬��Ϣ  9*1
%output
%-------res.avp: N*10 ������Ϣ����׼��λ���ȡ�m/s ��m 
%-------res.xkpk: 2*N  ����ֵ��Э������
%%  data length and time
N = length(imu(:,end));
L_GNSS = length(gnss(:,end));
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
%% kalmman������ʼ��
kf = []; m  = 6; n =15;
kf.m = m;  kf.n = n;
kf.Pk = 1*diag([davp(1:3); davp(4:6); davp(7:9); imuerr.eb; imuerr.db])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb;zeros(kf.n-6,1)]).^2;
kf.Rk = diag([davp(4:6);davp(7:9)]).^2;
kf.Gammak = eye(kf.n); kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
kf.I = eye(kf.n);
%% others parameter setting
kf.b = 0.92;kf.beta = 1;
kf.Rmin = diag(diag(kf.Rk)/200);
kf.Rmax = 200*kf.Rk;
ki =1;
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);

t(1) = imu(1,end);
avp = zeros(N,10); avp(1,:) = [att',vel',pos',t(1)];
xkpk = zeros(N ,2*kf.n);   xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
%% Algorithm develop
timebar(1,N,'15ά��������Ӧ+��������');
for i= 2:N 
        wbib = (imu(i,1:3)'+imu(i-1,1:3)')/2 ;
        fb = imu(i,4:6)' ;
        dt = imu(i,end) - imu(i-1,end);
        t(i) = imu(i,end);
        %% �ߵ�����
        [att,vel,pos,qua,Cnb,eth] = avp_update(wbib,fb,Cnb,qua,pos,vel,dt);
        %-------------kalmanԤ��-------------------      
        kf.Phikk_1 = kf.I + KF_Phi(eth,Cnb,fb,kf.n)*dt;%��ɢ������̩��չ��
        kf.Xk = kf.Phikk_1*kf.Xk; xk = kf.Xk;
        kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
        kf.Qk = kf.Qt*dt;
        kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + kf.Gammak*kf.Qk*kf.Gammak'; 
        if ki<=L_GNSS && gnss(ki,end)<=imu(i,end)  
            kf.Xkk_1 = kf.Xk;
            kf.Pkk_1 = kf.Pk;
            Zk = [vel-gnss(ki,1:3)';
                     pos-gnss(ki,4:6)'];
            kf.Hk =zeros(kf.m,kf.n);kf.Hk(1:6,4:9) = eye(6);
            kf.rk = Zk - kf.Hk*kf.Xkk_1;%�в�
            kf.PXZkk_1 = kf.Pkk_1*kf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������
			kf.Py0 =  kf.Hk*kf.PXZkk_1;
            for k=1:kf.m
                ry = kf.rk(k)^2 -  kf.Py0(k,k); %�������
                if ry<kf.Rmin(k,k)
                    kf.Rk(k,k)  = (1-kf.beta)*kf.Rk(k,k) +kf.beta*kf.Rmin(k,k); 
                elseif ry>kf.Rmax(k,k)
                    kf.Rk(k,k) =  kf.Rmax(k,k);
                else
                    kf.Rk(k,k) = (1-kf.beta)*kf.Rk(k,k) + kf.beta*ry;
                end
            end
            kf.beta = kf.beta/(kf.beta+kf.b);	
                
            kf.PZZkk_1 = kf.Hk*kf.PXZkk_1 + kf.Rk;%����һ��Ԥ����������
            kf.Kk = kf.PXZkk_1*invbc(kf.PZZkk_1);
            kf.Xk = kf.Xkk_1 + kf.Kk*kf.rk;
            kf.Pk = kf.Pkk_1 - kf.Kk*kf.PZZkk_1*kf.Kk';
            kf.Pk = (kf.Pk+kf.Pk')/2;
 			
            [att,pos,vel,qua,Cnb,kf,xk]= feed_back_correct(kf,[att;vel;pos],qua); 
            zk(ki,:) = [Zk',sqrt(diag(kf.Rk))',ki];
            ki = ki+1;
        end
        avp(i,:) = [att',vel',pos',t(i)];
        xkpk(i,:) = [xk',diag(kf.Pk)'];
        timebar;
end
kf_res = varpack(avp,xkpk,zk);
end