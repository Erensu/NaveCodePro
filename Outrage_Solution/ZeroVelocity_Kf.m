function res = ZeroVelocity_Kf(imu,gnss,davp,imuerr,avp0)
%% introduction
%------------- ���Kalman�˲� ---------------------
% ����У��+���򱣳�+ λ�����+����Լ����� 
% ���尲װ��ʵʱ���ƣ���װ��ģ�ͺͳ�ֵģ��
% GNSSȱʧʱʹ�ó���Լ��
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
%% Initialize Kalman filter matrices
kf = []; m  = 5; n = 17;
kf.m = m;  kf.n = n;
kf.Pk = diag([davp(1:3); davp(4:6); davp(7:9); imuerr.eb; imuerr.db;[10;10]*pi/180])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb; zeros(kf.n-6,1)]).^2;
kf.Gammak = eye(kf.n); kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
kf.I = eye(kf.n);
%% constrait parameter setting
window_width = 1;  %���ڿ�� 2s
zupt_flag = false;   % ���ٱ�־
zput_th = 0.6;       % ������ֵ 0.5m/s 
mbatt = [0;0;0]*pi/180;
Cmb = a2mat(mbatt);
upTolow = 1;%�߾��ȵ��;����л��˲����Ĵ��� ��СP��
lowToup = 0;%�;��ȵ��߾����л��˲����Ĵ��� ����P��
ki =1;
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,1);
avp = zeros(N,10);
xkpk = zeros(N ,2*kf.n);
vm0 =  zeros(3,N);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
avp(1,:) = [att',vel',pos',t(1)];
xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
%% Algorithm develop
timebar(1,N,'SINS/GPS156 Simulation');
for i = 2:N
	wbib = imu(i,1:3)' ;
	fb = imu(i,4:6)' ;
	dt = imu(i,end) - imu(i-1,end);
	t(i) = imu(i,end);
    %-------------�ߵ�����-------------------
    [att,vel,pos,qua,Cnb] = avp_update(wbib,fb,Cnb,qua,pos,vel,dt);
	avp(i,:) = [att',vel',pos',t(i)];
	%-------------���ټ�� ��ת���⡢----------
    idz = floor( window_width/dt);
	if(i> idz)
		vel_mean = mean(avp(i - idz:i,4:6));
		if(abs(vel_mean) <= zput_th)
			zupt_flag = true;
            pos =  avp(i -1,7:9)';
            att =  avp(i-1,1:3)';
		else
			zupt_flag = false;
        end           
	end
	
	%-------------kalmanԤ��-------------------
    eth = EarthParameter(pos,vel);
	kf.Phikk_1 = kf.I + KF_Phi(eth,Cnb,fb,kf.n)*dt;%��ɢ������̩��չ��
	kf.Xk = kf.Phikk_1*kf.Xk; xk = kf.Xk;
	kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
	kf.Qk = kf.Qt*dt;
    kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + kf.Gammak*kf.Qk*kf.Gammak';  
	%-------------Kalman����--------------------
    if (ki<=L_GNSS && gnss(ki,7)> 7)   %����DPOP�ж������Ƿ����
        gnss(ki,:) = [];
        L_GNSS =L_GNSS - 1;
    end        
    if (ki<=L_GNSS && gnss(ki,end)<=imu(i,end))   % gps���������޵�֡ 
        if(lowToup == 1)
           upTolow = 1;
           lowToup = 0;
           kf.Pk  = 100* kf.Pk;
        end       
        if (zupt_flag  == true)
            Zk = pos;
            kf.Hk =zeros(3,kf.n);kf.Hk(1:3,7:9) = eye(3);
            kf.Rk = diag([1;1;1]).^2;
        else
            Cbn = Cnb';
            vm = Cmb *Cbn*vel;vm0(:,i) = vm;
            M2 = -Cmb*Cbn*askew(vel);M1 = Cmb*Cbn;M3 = askew(vm);  
            Zk = [pos-gnss(ki,4:6)';
                  vm(1);
                  vm(3)];              
            kf.Hk =zeros(5,kf.n);kf.Hk(1:3,7:9) = eye(3);
            kf.Hk(4,1:3) = M2(1,:); kf.Hk(5,1:3) = M2(3,:); 
            kf.Hk(4,4:6) = M1(1,:); kf.Hk(5,4:6) = M1(3,:);
            kf.Hk(4,17) = M3(1,3);kf.Hk(5,16) = M3(3,1);                
            kf.Rk = diag([davp(7:9);0.5;0.5]).^2;
        end
        kf.Xkk_1 = kf.Xk;
        kf.Pkk_1 = kf.Pk;
        kf.PXZkk_1 = kf.Pkk_1*kf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������		
        kf.rk = Zk - kf.Hk*kf.Xkk_1;%�в�
		kf.PZZkk_1 = kf.Hk*kf.PXZkk_1 + kf.Rk;%����һ��Ԥ����������
		kf.Kk = kf.PXZkk_1*invbc(kf.PZZkk_1);
		kf.Xk = kf.Xkk_1 + kf.Kk*kf.rk;
		kf.Pk = kf.Pkk_1 - kf.Kk*kf.PZZkk_1*kf.Kk';
		kf.Pk = (kf.Pk+kf.Pk')/2;
        %-------------����У��--------------------
		[att,pos,vel,qua,Cnb,kf,xk]= feed_back_correct(kf,[att;vel;pos],qua);
        ki = ki+1;
    end
    if (ki >1 &&  ki < L_GNSS && gnss(ki,end)-gnss(ki-1,end) >1.5)  %  ��ʾ�����ѵ�֡
        if(upTolow == 1)
            lowToup = 1;
            upTolow = 0;
            kf.Pk  = 1*kf.Pk;
        end
        if (zupt_flag  == true)
            Zk = pos;
            kf.Hk =zeros(3,kf.n);kf.Hk(1:3,7:9) = eye(3);
            kf.Rk = diag([1;1;1]).^2;
        else
            Cbn = Cnb';
            vm = Cmb *Cbn*vel;vm0(:,i) = vm;
            M2 = -Cmb*Cbn*askew(vel);M1 = Cmb*Cbn;M3 = askew(vm);
            Zk = [vm(1);
                  vm(3);
                 ]; 
            kf.Hk = [M2(1,:)    M1(1,:) zeros(1,9) 0       M3(1,3);
                     M2(3,:)    M1(3,:) zeros(1,9) M3(3,1) 0      ;
                    ];	
            kf.Rk = diag([0.8;0.8]).^2;
        end
        kf.Xkk_1 = kf.Xk;
        kf.Pkk_1 = kf.Pk;
        kf.PXZkk_1 = kf.Pkk_1*kf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������		
        kf.rk = Zk - kf.Hk*kf.Xkk_1;%�в�
		kf.PZZkk_1 = kf.Hk*kf.PXZkk_1 + kf.Rk;%����һ��Ԥ����������
		kf.Kk = kf.PXZkk_1*invbc(kf.PZZkk_1);
		kf.Xk = kf.Xkk_1 + kf.Kk*kf.rk;
		kf.Pk = kf.Pkk_1 - kf.Kk*kf.PZZkk_1*kf.Kk';
		kf.Pk = (kf.Pk+kf.Pk')/2;
        %-------------����У��--------------------
		[att,pos,vel,qua,Cnb,kf,xk]= feed_back_correct(kf,[att;vel;pos],qua);
    end    
    avp(i,:) = [att',vel',pos',t(i)];
    xkpk(i,:) = [xk',diag(kf.Pk)'];
    timebar;	
end
	res = varpack(avp,xkpk);	
end