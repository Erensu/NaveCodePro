%% Algorithm Introduction
%  ��֤��������F1�Ĵ��ݶ�׼
%  ���ݸ�ʽ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : 
% Version : 
% Date : 
% File : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear all;
disp('���ݶ�׼�㷨��֤');
%% Load data
load('imuSTGnss0608_F1.mat')
%%  Change Dataformat to Standard
trj.avp = [imuSTGn0608_1.ref(:,2:4) imuSTGn0608_1.ref(:,8:10) imuSTGn0608_1.ref(:,5:7) imuSTGn0608_1.ref(:,1)];
trj.avp = [trj.avp(:,1:3)*pi/180 trj.avp(:,4:6) trj.avp(:,7:8)*pi/180 trj.avp(:,9) trj.avp(:,10)];
global glv 
glv = globalParameter(trj.avp(1,7),trj.avp(1,9));
imu = [imuSTGn0608_1.imu1(:,2:4)*pi/180 imuSTGn0608_1.imu1(:,5:7)*glv.g0 imuSTGn0608_1.imu1(:,12)];

%% Initial data 
mavp = trj.avp;
load('f1savp.mat') %������װ��֮�󱣴���ӹߵ����ݣ������ο�ֵ
%/---------------------����ʵ��İ�װ������-----------------------/
% avp = [savp(:,1:3)*pi/180 savp(:,4:6) savp(:,7:8)*pi/180 savp(:,9) savp(:,10)];
% savp = mavp;
% matt = [-0.5589 -0.01512 -0.4445];%F1�������ӹߵ�֮��İ�װ��
% qbbs = a2qua(matt.*glv.deg);  
% for i = 1:length(savp)
%     % �ӹߵ����ݣ�ֻ���ǰ�װ����
%     qnb = a2qua(trj.avp(i,1:3));                                           % ��ʵ��̬
%     qnbs = qmul(qnb, qbbs);
%     qnbsk(i,:) = qnbs';
%     savp(i,1:3) = q2att(qnbs)';   
% end

imuerr = imuerrset(2, 1000, 0.2, 100);
davp = avpseterr([-30;30;30], [0.1;0.1;0.1]*1, [1;1;1]*2);              % �趨��ʼ��̬���ٶȡ�λ�����
avp0 = trj.avp(1,:)';
%% Algorithm develop
res  = SINS186Att_Vel_TransferAlignment(imu, mavp, imuerr, davp,avp0);
%% Error analysis and Plot figures
fplot(res.avp,trj.avp,1) %���Ի��ȵ�λ����
xkplot(res.xkpk) %���Ի��ȵ�λ����
%% Save Workspace

%% End