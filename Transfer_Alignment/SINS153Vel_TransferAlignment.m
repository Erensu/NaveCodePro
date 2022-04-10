function res = SINS153Vel_TransferAlignment(imu, mavp, imuerr, davp,avp0)
%% -----------Introduction------------
%�ٶ�ƥ��15ά���ݶ�׼�㷨 �������Ƹ˱�
%input: 
%-------imu : ����������N*7 ��λ��rad/s   m/s^2
%-------davp : ��������Kalman P�� 18*1
%-------imuerr : ��������Kalman Q�� 
%-------avp0  �� ��ʼ��̬��Ϣ  9*1
%-------mavp: ���ߵ���Ϣ  ��λ��N*10 ���� m/s ���� m
%output
%-------res.avp: N*10 ������Ϣ����׼��λ���ȡ�m/s ��m 
%-------res.xkpk: 2*N  ����ֵ��Э������
%%  data length and time
N = length(imu(:,end));
%% kalmman������ʼ��
kf = []; m  = 6; n =15;
kf.m = m;  kf.n = n;
kf.Pk = 1*diag([davp(1:3); davp(4:6);imuerr.eb; imuerr.db;[2;2;2]])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb;zeros(kf.n-6,1)]).^2;
kf.Gammak = eye(kf.n);
kf.I = eye(kf.n);
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,10);
xkpk = zeros(N,2*kf.n);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
avp(1,:) = [att',vel',pos',t(1)];
xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
factor = 1.0;
timebar(1, N, '��̬�ٶ�ƥ���㷨�����Թ��ư�װ���ǣ�.');             % ��һ��������ʾ��������ڶ���������ʾ�ܽ���
%% Function realize
for i = 2:N        
    wbib = imu(i,1:3)' ;
    fb = imu(i,4:6)' ;
    dt = imu(i,end) - imu(i-1,end);
    t(i) = imu(i,end);    
    % �������ߵ����ٶȺ�λ��
    posm = mavp(i,7:9)';
    vnm = mavp(i,4:6)';
%     [att,vel,pos,qua,Cnb] = avp_update(wbib,fb,Cnb,qua,posm,vnm,dt); 
    eth = EarthParameter(posm,vnm);
    vel = vel + (Cnb*fb + eth.gcc)*dt;
    qua = qupdt(qua,(wbib - Cnb'*eth.wnin)*dt);
    pos = posm;
    % Kalman�˲�
    % һ��Ԥ��
    Maa=zeros(3,3); 
    Maa(2)=-eth.wnin(3); 
    Maa(3)= eth.wnin(2); 
    Maa(4)= eth.wnin(3); 
    Maa(6)=-eth.wnin(1); 
    Maa(7)=-eth.wnin(2); 
    Maa(8)= eth.wnin(1); 
    Mva=zeros(3,3);
    fn = Cnb*fb;
    Mva(2)= fn(3); 
    Mva(3)=-fn(2); 
    Mva(4)=-fn(3); 
    Mva(6)= fn(1); 
    Mva(7)= fn(2); 
    Mva(8)=-fn(1); 
    Ft = [Maa zeros(3,3) -Cnb       zeros(3,3)  zeros(3,3);        % 
             Mva zeros(3,3) zeros(3,3) Cnb         zeros(3,3);         
             zeros(9,15);];
    Fk = Ft*dt;
    kf.Phikk_1 = kf.I  + Fk;
     kf.Xk = kf.Phikk_1*kf.Xk; 
    kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
    kf.Qk = kf.Qt*dt;
    kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + kf.Gammak*kf.Qk*kf.Gammak';        
    % ------------------�������-----------------
    Zk = vel-vnm; 
    kf.Xkk_1 = kf.Xk;
    kf.Pkk_1 = kf.Pk;
    web = wbib- Cnb'*eth.wnie;
    kf.Hk = [zeros(3,3) eye(3)     zeros(3,6)  Cnb*askew(web)];
    kf.Rk = diag([0.1; 0.1; 0.1])^2;       
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
    qua  = qdelphi(qua, factor* kf.Xk(1:3));
    kf.Xk(1:3) = (1-factor)*kf.Xk(1:3);  
    att = q2att(qua);
    Cnb = q2mat(qua);
    % �ٶ�
    vel = vel-factor*kf.Xk(4:6);  
    kf.Xk(4:6) = (1-factor)*kf.Xk(4:6);  
    % ��¼����
    avp(i,:) = [att',vel',pos',t(i)];
    xkpk(i,:) = [xk',diag(kf.Pk)'];
    timebar;                                                               % ������
end
%% Return Results and Save Workspace
res = varpack(avp,xkpk); 
end

%% End

