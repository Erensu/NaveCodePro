%% Algorithm Introduction
% The row vector is recommended
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The trajectory simulation script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author :
% Version : V0.1.0
% Date : 
% File : 
% output:
%		trj.ts ����ʱ��                      
%		trj.avp ����ϵ�������ĵ������� 
%			��λ��rad  rad  rad  m/s^2   rad rad m s 
%		 		[pitch roll yaw ve vn vu lat lon h t]
%		trj.imu  ���Ե�Ԫ���
%				 ������   �ٶ����� s 
%				[wx,wy,wz,ax,ay,az,t]
%		trj.avp0 ��ʼ��������
%		trj.wat  �˶��켣����
%            	wat(:,1) - period lasting time ����ʱ��
%            	wat(:,2) - period initial velocity magnitude ��ʼ�ٶ�
%            	wat(:,3:5) - angular rate in trajectory-frame ������
%            	wat(:,6:8) - acceleration in trajectory-frame ���ٶ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;                                                                       % clear command
close all;                                                                 % close figures
clear ;                                                                    % clear data space
disp('This is a trajectory simulation script');
%% Initial data 
glvs
ts = 0.005;       %  200HZ sampling interval ��ʱ�� 722s
avp0 = avpset([0;0;0], [0,0,0], glv.pos0); % init avp. if need the initial velocity, it is need to set in avp0
%��ʼ�ٶ������Ϊ0 �������г��ٶ���ת��켣�������⡣
%% Function index
xxx = [];
%% Algorithm develop
% trajectory segment setting

% seg = trjsegment(xxx, 'init',         0);
% seg = trjsegment(seg, 'uniform',      50);
% seg = trjsegment(seg, 'accelerate',   20, xxx, 1.5);%��1m/s^2���� 
% seg = trjsegment(seg, 'uniform',      100);
% seg = trjsegment(seg, 'turnleft',   45, 2, xxx, 4);%Э����ת��ʱ��
% seg = trjsegment(seg, 'uniform',      135);
% seg = trjsegment(seg, 'deaccelerate',   5, xxx, 1);%��1m/s^2���� 
% % seg = trjsegment(seg, 'coturnright',  45, 2, xxx, 4);%Э����ת�䣬
% seg = trjsegment(seg, 'turnright',   45, 2, xxx, 4);%Э����ת��ʱ��
% seg = trjsegment(seg, 'uniform',      100);
% seg = trjsegment(seg, 'deaccelerate', 5, xxx, 1);%��1m/s^2���� 
% seg = trjsegment(seg, 'uniform',      100);
% seg = trjsegment(seg, 'turnright',   45, 2, xxx, 4);%Э����ת��ʱ��
% seg = trjsegment(seg, 'uniform',      100);
% seg = trjsegment(seg, 'accelerate', 5, xxx, 1);%��1m/s^2���� 
% seg = trjsegment(seg, 'uniform',      100);
% seg = trjsegment(seg, 'turnleft',   45, 2, xxx, 4);%Э����ת��ʱ��
% seg = trjsegment(seg, 'uniform',      100);
% % seg = trjsegment(seg, 'deaccelerate',   5, xxx, 1);%��1m/s^2���� 
% trj = trjsimu(avp0, seg.wat, ts, 1);                 % truth data

% seg = trjsegment(xxx, 'init',         0);
% seg = trjsegment(seg, 'uniform',      25*60);
% trj = trjsimu(avp0, seg.wat, ts, 1);
%% 
% 8���˶�
% seg = trjsegment(xxx, 'init',         0);
% seg = trjsegment(seg, 'uniform',     60);
% seg = trjsegment(seg, 'accelerate',   5, xxx, 1); 
% seg = trjsegment(seg, '8turn',        90, 2, xxx, 4);
% seg = trjsegment(seg, 'uniform',      10);
% seg = trjsegment(seg, 'deaccelerate', 5,  xxx, 1);
% seg = trjsegment(seg, 'uniform',      1500);
% trj = trjsimu(avp0, seg.wat, ts, 1);                 % truth data

%% 
%��Բ�˶�
% seg = trjsegment(xxx, 'init',         0);%�����ȶ�seg��ʼ��һ��
% seg = trjsegment(seg, 'uniform',     10);
% seg = trjsegment(seg, 'coturnleft',   45, 2,xxx, 4);
% seg = trjsegment(seg, 'coturnleft',   45, 2,xxx, 4);
% seg = trjsegment(seg, 'coturnleft',   45, 2,xxx, 4);
% seg = trjsegment(seg, 'coturnleft',   45, 2,xxx, 4);
% trj = trjsimu(avp0, seg.wat, ts, 1);                 % truth data

%% 
%%����̬�������
% xxx = [];
% seg = trjsegment(xxx, 'init',         0);
% seg = trjsegment(seg, 'uniform',      10);
% seg = trjsegment(seg, 'accelerate',   4, xxx, 5);%��1m/s^2���� 
% seg = trjsegment(seg, 'uniform',      20);
% seg = trjsegment(seg, 'deaccelerate',   5, xxx, 4);%��1m/s^2���� 
% seg = trjsegment(seg, 'uniform',      10);
% seg = trjsegment(seg, 'accelerate',   5, xxx, 7);%��1m/s^2���� 
% seg = trjsegment(seg, 'deaccelerate',   10, xxx, 3);%��1m/s^2���� 
% seg = trjsegment(seg, 'uniform',      10);
% seg = trjsegment(seg, 'deaccelerate',   5, xxx, 1);%��1m/s^2���� 
% seg = trjsegment(seg, 'uniform',      20);
% seg = trjsegment(seg, 'accelerate',   10, xxx, 1);%��1m/s^2���� 
% trj = trjsimu(avp0, seg.wat, ts, 1);                 % truth data

%% 
%ת��ģʽ����
% xxx = [];
seg = trjsegment(xxx, 'init',         0);
seg = trjsegment(seg, 'uniform',      10);
seg = trjsegment(seg, 'accelerate',   4, xxx, 5);%��1m/s^2���� 
seg = trjsegment(seg, 'uniform',      10);
seg = trjsegment(seg, 'turnleft',   3, 2, xxx, 4);%��ת��ʱ��Сת��
seg = trjsegment(seg, 'uniform',      10);
seg = trjsegment(seg, 'deaccelerate', 5, xxx, 2);%��1m/s^2���� 
seg = trjsegment(seg, 'uniform',      10);
seg = trjsegment(seg, 'turnright',   10, 9, xxx, 4);%����ת��
seg = trjsegment(seg, 'uniform',      20);
seg = trjsegment(seg, 'accelerate',   3, xxx, 2);%��1m/s^2����
seg = trjsegment(seg, 'uniform',      10);
seg = trjsegment(seg, 'turnleft',   60, 3, xxx, 4);%��ת��ʱ��Сת��
seg = trjsegment(seg, 'uniform',      30);
seg = trjsegment(seg, 'turnright',   2, 5, xxx, 4);%С��ת��
seg = trjsegment(seg, 'uniform',      30);
trj = trjsimu(avp0, seg.wat, ts, 1);                 % truth data

%% Plot figures
insplot(trj.avp);
imuplot(trj.imu);
%% Save Workspace
% pos(rad,rad,m) vel(m/s) att(rad)
save('trj.mat', 'trj');


%% End