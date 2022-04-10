function res = VmP_NHC_RTS(imu,gnss,davp,imuerr,avp0)
% �����ٶȸ���+λ�ã�ʧ��ʱʹ��NHC/RTS
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

seg_start = 1;
seg_end = N ;
k = 1;
RTS_flag = 0;
seg=[];
flag=0;
%% Memory allocation
kf.Kk = zeros(kf.n,kf.m);
kf.Xk = zeros(kf.n,1);
kf.Phikk_1 = zeros(kf.n,kf.n);
avp = zeros(N,10); 
xkpk = zeros(N ,2*kf.n);   
vm0 = zeros(3,N);
slideWindow = 20;
F = cell(slideWindow,1);
xf = cell(slideWindow,1);
Pf = cell(slideWindow,1);
xf1 = cell(slideWindow,1);
Pf1 = cell(slideWindow,1);
%% Initial data
att = avp0(1:3);vel = avp0(4:6);pos = avp0(7:9);
qua = a2qua(att);
Cnb = a2mat(att);
t(1) = imu(1,end);
avp(1,:) = [att',vel',pos',t(1)];
xkpk(1,:) = [kf.Xk',diag(kf.Pk)'];
F{1} = kf.Phikk_1;
xf{1} = kf.Xk;
xf1{1} = kf.Xk;
Pf{1} = kf.Pk;
Pf1{1} = kf.Pk;
%% Algorithm develop
timebar(1,N,'INS-NHC-RTS');
while(1)
for i=  seg_start:seg_end
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
            k=1;%����һʧ���׶εĻ����������Ҫ��
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
            RTS_flag = 1;   %ƽ������
            if(upTolow == 1) 
                lowToup = 1;
                upTolow = 0;
                kf.Pk  = 1*kf.Pk;
            end     
            F{k} =  kf.Phikk_1;xf{k} = xk;Pf{k} = kf.Pk;  
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
             xf1{k} = xk;Pf1{k} = kf.Pk; k = k+1;    
        end
        xkpk(i,:) = [xk',diag(kf.Pk)'];  
        avp(i,:) = [att',vel',pos',t(i)];
        
        if  RTS_flag == 1 && k==slideWindow+1
            seg_end = i;
            k = 1;
            flag =1;
            break;
        end
        timebar;
end
%---------------------ƽ������----------------------------%
    if flag ==1  %��ֹ����ĩ������״̬����ƽ��
        [Xs,Ps] = RTS(F,xf,Pf,xf1,Pf1);  %����ƽ��
        for i = seg_end -slideWindow+1:seg_end 
            vel = avp(i,4:6)' - 0.85*Xs{k}(4:6);
            pos = avp(i,7:9)' -0.85*Xs{k}(7:9); 
            qua = qdelphi(a2qua( avp(i,1:3)'),0.85*Xs{k}(1:3)');
            Cnb = q2mat(qua);
            att =  m2att(Cnb);
            avp(i,:) = [att',vel',pos',avp(i,end)];
            k = k+1;
        end
        flag=0;
    end
    
    seg = [seg seg_end];   
    if seg_end~=N
        seg_start = seg_end + 1;
        seg_end = N;
        k=1;
    else
        % End of data -> break loop
        break;
    end  
end
res = varpack(avp,xkpk); 
end
