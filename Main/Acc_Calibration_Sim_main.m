% ���ٶȼƱ궨����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : xutongxu
% Version :  
% Date : 2020.4.
% File : 
clc;                                                 % clear cmd text
clear;                                              % clear all RAM

load('data\AccBiasSimu.mat');
g0 = 9.794281725483827;
mmg=g0*10^(-3);
global Vsb;
%% �ڴ����
n=20;
m=100;    % �ظ���100�� ����ֻ����ǰ20��
Xpar1=cell(1,n);  
Xpar2=cell(1,n);
for i=1:n
     Xpar1{i}=zeros(m,9);
     Xpar2{i}=zeros(m,9);
end
tic
for i=10:10   % 20����ƫ
    for j=1:m                        % ÿ����ƫ��100���ظ���
        Vsb=vsib{i,j};                % 24λ������
        [x1,x0] = GA_main(Vsb');
        C=mAccCaliDescent(Vsb,([x0(4),0,x0(5),0,0,x0(6),x0(1:3)])',g0,2,2);
        x2 = [C.X(7) C.X(8) C.X(9) C.X(1) C.X(3) C.X(6) C.X(2) C.X(4) C.X(5)];
        Xpar1{i}(j,:)= x1;
        Xpar2{i}(j,:)= x2;
    end
end
toc
%% ������
% ģ��1��rKa*v - bias,  ģ��2��rKa*(v-bias)
rKa=(Saj*Asba)^(-1); %�ο���ֵ
er=zeros(m,9);
Err1=cell(1,n);
for i=1:m
    Err1{i}=er;
end

er2=zeros(m,9);
Err2=cell(1,n);
for i=1:m
    Err2{i}=er2;
end
for i=10:10   % bias
    bis0=Saj*[1;1;1]*biasi(i);
    rbis1=bis0;
    er=[Xpar1{i}(:,1)-rbis1(1), Xpar1{i}(:,2)-rbis1(2), Xpar1{i}(:,3)-rbis1(3),...
        Xpar1{i}(:,4)-rKa(1,1),Xpar1{i}(:,5)-rKa(2,2),Xpar1{i}(:,6)-rKa(3,3),...
        Xpar1{i}(:,7)-rKa(2,1),Xpar1{i}(:,8)-rKa(3,1),Xpar1{i}(:,9)-rKa(3,2)];   
    Err1{i}=er;
    er2=[Xpar2{i}(:,1)-rbis1(1), Xpar2{i}(:,2)-rbis1(2), Xpar2{i}(:,3)-rbis1(3),...
        Xpar2{i}(:,4)-rKa(1,1),Xpar2{i}(:,5)-rKa(2,2),Xpar2{i}(:,6)-rKa(3,3),...
        Xpar2{i}(:,7)-rKa(2,1),Xpar2{i}(:,8)-rKa(3,1),Xpar2{i}(:,9)-rKa(3,2)];   
    Err2{i}=er2;
end

%% ��ͼ����
mErr1=zeros(m*n,9);
Ebias=zeros(m*n,1);
for i=1:n
    ind1=(m*(i-1)+1); ind2=i*m;
    mErr1(ind1:ind2,1:9)=Err1{i}(:,1:9); 
    Ebias(ind1:ind2)=Ebias(ind1:ind2)+biasi(i);
end
Ebias=Ebias/mmg;

figure;
plot(Ebias, mErr1(:,1)/mmg,'r.',Ebias+0.9,mErr1(:,2)/mmg,'g.',Ebias+1.8,mErr1(:,3)/mmg,'b.');
xlabel('��ƫ(mg)');  ylabel('���(mg)');  title('��ƫ�������');
legend('x bias','y bias','z bias');

figure;
plot(Ebias, 100*mErr1(:,4)/rKa(1,1),'r.',Ebias+0.9,100*mErr1(:,5)/rKa(2,2),'g.',Ebias+1.8,100*mErr1(:,6)/rKa(3,3),'b.');
xlabel('��ƫ(mg)');  ylabel('������(%)');  
legend('K11','K22','K33');

figure;
plot(Ebias, mErr1(:,7),'r.',Ebias+0.9,mErr1(:,8),'g.',Ebias+1.8,mErr1(:,9),'b.');
xlabel('��ƫ(mg)');  ylabel('���');  
legend('K21','K31','K32');

