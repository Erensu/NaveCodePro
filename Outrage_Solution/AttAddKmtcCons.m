function res = AttAddKmtcCons(imu, mavp, imuerr, davp,avp0,index)
%% -----------Introduction------------
%��̬ƥ��+ �����˶�ѧ�ٶ�ƥ�� 20ά���ݶ�׼�㷨 �������Ӱ�װ�ǣ����尲װ�ǣ����ܹ��Ƹ˱�
%���Է���gnssȱʧ�����
%input: 
%-------imu : ����������N*7 ��λ��rad/s   m/s^2
%-------davp : ��������Kalman P�� 18*1
%-------imuerr : ��������Kalman Q�� 
%-------avp0  �� ��ʼ��̬��Ϣ  9*1
%-------mavp: ���ߵ���Ϣ  ��λ��N*10 ���� m/s ���� m
%-------index: gnssȱʧ����
%output
%-------res.avp: N*10 ������Ϣ����׼��λ���ȡ�m/s ��m 
%-------res.xkpk: 2*N  ����ֵ��Э������
%%  data length and time
N = length(imu(:,end));
%% kalmman������ʼ��
kf = []; m  = 5; n =20;
kf.m = m;  kf.n = n;
kf.Pk = 10*diag([davp(1:3); davp(4:6); davp(7:9);imuerr.eb; imuerr.db;[10;10;10]*pi/180;[10;10]*pi/180])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb;zeros(kf.n-6,1)]).^2;
kf.Gammak = eye(kf.n);
kf.I = eye(kf.n);
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,10);
xkpk = zeros(N,2*kf.n);
vm0 = zeros(3,N);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
avp(1,:) = [att',vel',pos',t(1)];
xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
%% others parameter setting
ftrsn = 1;% ���ݶ�׼��־λ
fpk = 0;
factor = 1.0;
mbatt = [0;0;0]*pi/180;
Cmb = a2mat(mbatt);
k=1;
%% Algorithm develop
timebar(1,N, '��̬ƥ�����˶�ѧԼ����Դ�ں��㷨.');
for i = 2:N    
    wbib = imu(i,1:3)' ;
    fb = imu(i,4:6)' ;
    dt = imu(i,end) - imu(i-1,end);
    t(i) = imu(i,end);  
    if k<length(index) && i>index(k)*200 && i<index(k+1)*200
        ftrsn = 0;
        fpk = 1;
        k=k+1;
    else
        ftrsn = 1;
        % �������ߵ����ٶȺ�λ��
%        pos = mavp(i,7:9)';
%         vel = mavp(i,4:6)';
        vnm = mavp(i,4:6)';
    end
    [att,vel,pos,qua,Cnb] = avp_update(wbib,fb,Cnb,qua,pos,vel,dt); 
    eth = EarthParameter(pos,vel); 
    Cbn = Cnb';
    vm = Cmb *Cbn*vel;vm0(:,i) = vm;
    %-------------kalmanԤ��-------------------      
    kf.Phikk_1 = kf.I + KF_Phi(eth,Cnb,fb,kf.n)*dt;%��ɢ������̩��չ��
    kf.Xk = kf.Phikk_1*kf.Xk; 
    kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
    kf.Qk = kf.Qt*dt;
    kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + kf.Gammak*kf.Qk*kf.Gammak';   
    % �������
    kf.Xkk_1 = kf.Xk;
    kf.Pkk_1 = kf.Pk;
    if ftrsn == 1        
        % �ڶ��ν��룬Ҫ�����޸�pk
        if fpk == 1
             kf.Pkk_1 = 10* kf.Pkk_1;
             fpk =0;
        end        
        % ������̬���
        mqnb = a2qua(mavp(i,1:3));
        sqbn = qconj(qua);
        Cnbm = q2mat(mqnb);
        Cbsn = q2mat(sqbn);
        z = Cnbm*Cbsn; 

        M2 = -Cmb*Cbn*askew(vel);M1 = Cmb*Cbn;M3 = askew(vm);     
        kf.Hk = [eye(3)  zeros(3,3) zeros(3,9) -Cnb     zeros(3,2);                                             % 
                 M2(1,:) M1(1,:)    zeros(1,12) 0       M3(1,3);
                 M2(3,:) M1(3,:)    zeros(1,12) M3(3,1) 0;
                 ];
        kf.Rk = diag([[100; 100; 100;].*pi/180/60;[0.5;0.5]])^2;                      % ��̬�ٶ�ƥ��  
        Zk = [0.5*(z(3,2)-z(2,3)); 
              0.5*(z(1,3)-z(3,1)); 
              0.5*(z(2,1)-z(1,2));                                             % ��̬
              vm(1);
              vm(3);];     
    else         
        M2 = -Cmb*Cbn*askew(vel);M1 = Cmb*Cbn;M3 = askew(vm); 
        kf.Hk = [M2(1,:)  M1(1,:) zeros(1,12) 0       M3(1,3);
                   M2(3,:)  M1(3,:) zeros(1,12) M3(3,1) 0;]; 
        kf.Rk = diag([0.8;0.8])^2;     
        Zk = [vm(1);vm(3)];                                              % �ٶ�����
    end
    kf.rk = Zk - kf.Hk*kf.Xkk_1;%�в�
    kf.PXZkk_1 = kf.Pkk_1*kf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������
    kf.PZZkk_1 = kf.Hk*kf.PXZkk_1 + kf.Rk;%����һ��Ԥ����������
    kf.Kk = kf.PXZkk_1*invbc(kf.PZZkk_1);
    kf.Xk = kf.Xkk_1 + kf.Kk*kf.rk;
    kf.Pk = kf.Pkk_1 - kf.Kk*kf.PZZkk_1*kf.Kk';
    kf.Pk = (kf.Pk+kf.Pk')/2;
    % ���� 
    xk = kf.Xk;
    % ��̬
    qua  = qdelphi(qua, factor*kf.Xk(1:3));
    kf.Xk(1:3) = (1-factor)*kf.Xk(1:3);  
    att = q2att(qua);
    Cnb = q2mat(qua);
    % �ٶ�
    vel = vel-factor*kf.Xk(4:6);  
    kf.Xk(4:6) = (1-factor)*kf.Xk(4:6);  
    %λ��
    if ftrsn == 1  
        pos = mavp(i,7:9)';
        kf.Xk(7:9)  = zeros(3,1);
    else
        pos =  pos - factor*kf.Xk(7:9);  
        kf.Xk(7:9) = (1-factor)*kf.Xk(7:9); 
    end
    % ��¼����
    avp(i,:) = [att',vel',pos',t(i)];
    xkpk(i,:) = [xk',diag(kf.Pk)'];
    timebar;   
end 
%% ���ؽ��
res = varpack(xkpk, avp, vm0); 
% save 'RES.mat'
end

%% ��������