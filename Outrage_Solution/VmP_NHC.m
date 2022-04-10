function res = VmP_NHC(imu,gnss,davp,imuerr,avp0)
% �����ٶȸ���+λ�ã�ʧ��ʱʹ��NHC
%%  data length and time
N = length(imu(:,end));
L_GNSS = length(gnss(:,end));
%% kalmman������ʼ��
kf = []; m  = 3; n =17;
kf.m = m;  kf.n = n;
kf.Pk = diag([davp(1:3); davp(4:6); davp(7:9); imuerr.eb; imuerr.db;[5;5]*pi/180])^2;
kf.Qt = diag([imuerr.web; imuerr.wdb; zeros(kf.n-6,1)]).^2;
kf.Gammak = eye(kf.n); 
kf.I = eye(kf.n);
%% constrait parameter setting
upTolow = 1;%�߾��ȵ��;����л��˲����Ĵ��� ��СP��
lowToup = 0;%�;��ȵ��߾����л��˲����Ĵ��� ����P��
ki =1;
mbatt = [0;0;0]*pi/180;
Cmb = a2mat(mbatt);

%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,10); 
xkpk = zeros(N ,2*kf.n);   
vm0 = zeros(3,N);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
avp(1,:) = [att',vel',pos',t(1)];
xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
%% Algorithm develop
timebar(1,N,'INS-NHC');
for i=  2:N
        if(i>2)
            wbib = (imu(i,1:3)'+imu(i-1,1:3)')/2 ;
            dt = imu(i,end) - imu(i-1,end);
        else
            wbib = imu(i,1:3)';
            dt = imu(i,end);
        end
        fb = imu(i,4:6)' ;
        t(i) = imu(i,end);
        %% �ߵ�����
        [att,vel,pos,qua,Cnb,eth] = avp_update(wbib,fb,Cnb,qua,pos,vel,dt);
        Cbn = Cnb';
        vm = Cmb*Cbn*vel;vm0(:,i) = vm;
        M2 = -Cmb*Cbn*askew(vel);M1 = Cmb*Cbn;
        M3 = -askew(vm);         
        %-------------kalmanԤ��-------------------      
        kf.Phikk_1 = kf.I + KF_Phi(eth,Cnb,fb,kf.n)*dt;%��ɢ������̩��չ��
        kf.Xk = kf.Phikk_1*kf.Xk; xk = kf.Xk;       
        
        kf.Gammak(1:3,1:3) = -Cnb; kf.Gammak(4:6,4:6) = Cnb;
        kf.Qk = kf.Qt*dt;
        kf.Pk = kf.Phikk_1*kf.Pk*kf.Phikk_1' + kf.Gammak*kf.Qk*kf.Gammak';
        
        %-----------------------GNSS�����׶�------------------------%
        if ki<=L_GNSS && gnss(ki,end)<=imu(i,end)   
            if(lowToup == 1)%�ڶ��ν���
               upTolow = 1;
               lowToup = 0;
               kf.Pk  = 1* kf.Pk;
            end  
            kf.Xkk_1 = kf.Xk;
            kf.Pkk_1 = kf.Pk;
            Zk = [vm(1);
                     vm(3);
                     pos-gnss(ki,4:6)'];	
            kf.Hk = [M2(1,:) M1(1,:) zeros(1,9) 0       M3(1,3);
                          M2(3,:) M1(3,:) zeros(1,9) M3(3,1) 0;
                          zeros(3,3) zeros(3,3) eye(3) zeros(3,8)];
            kf.Rk = diag([0.2;0.2;davp(7:9)]).^2;
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

        %---------------------NHC�����׶�----------------------------------------------%
        if  ki>1 &&  ki < length(gnss) && gnss(ki,end)-gnss(ki-1,end) >1    %gnssʱ��ǰ����
            if(upTolow == 1) 
                lowToup = 1;
                upTolow = 0;
                kf.Pk  = 1*kf.Pk;
            end     
            kf.Xkk_1 = kf.Xk;
            kf.Pkk_1 = kf.Pk;
            Zk = [vm(1);
                     vm(3);
                    ]; 
            kf.Hk = [M2(1,:)    M1(1,:) zeros(1,9) 0       M3(1,3);
                          M2(3,:)    M1(3,:) zeros(1,9) M3(3,1) 0;
                         ];	
            kf.Rk = diag([0.5;0.5]).^2;
            kf.rk = Zk - kf.Hk*kf.Xkk_1;%�в�
            kf.PXZkk_1 = kf.Pkk_1*kf.Hk';%״̬һ��Ԥ��������һ��Ԥ���Э�������        
            kf.PZZkk_1 = kf.Hk*kf.PXZkk_1 + kf.Rk;%����һ��Ԥ����������         
            kf.Kk = kf.PXZkk_1*invbc(kf.PZZkk_1);
            kf.Xk = kf.Xkk_1 + kf.Kk*kf.rk;
            kf.Pk = kf.Pkk_1 - kf.Kk*kf.PZZkk_1*kf.Kk';
            kf.Pk = (kf.Pk+kf.Pk')/2; 
            [att,pos,vel,qua,Cnb,kf,xk]= feed_back_correct(kf,[att;vel;pos],qua);  
        end
        xkpk(i,:) = [xk',diag(kf.Pk)'];  
        avp(i,:) = [att',vel',pos',t(i)];
       timebar;
end
res = varpack(avp,xkpk); 
end
