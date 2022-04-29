clc;
clear;
load('allan_analysis.txt')
Gyroscope = allan_analysis(:,[6,7,8]);
% data = dlmread('test7.txt');             %���ı��ж�ȡ���ݣ���λ��deg/s�����ʣ�100Hz
% data = data(720000:2520000, 3:5)*3600;  %��ȡ��������Сʱ��ģ����Сʱ�����ݣ��� deg/s תΪ deg/h
[A, B] = allan(Gyroscope*3600, 100, 100);         %��Allan��׼���100����������

loglog(A, B, '.');                  %��˫��������ͼ
xlabel('time:sec');                 %���x���ǩ
ylabel('Sigma:deg/h');              %���y���ǩ
legend('X axis','Y axis','Z axis'); %��ӱ�ע
grid on;                            %���������
hold on;                            %ʹͼ�񲻱�����

C(1, :) = nihe(A', (B(:,1)').^2, 2)';   %���
C(2, :) = nihe(A', (B(:,2)').^2, 2)';
C(3, :) = nihe(A', (B(:,3)').^2, 2)';

Q = sqrt(abs(C(:, 1) / 3));             %������������λ��deg/h
N = sqrt(abs(C(:, 2) / 1)) / 60;	%�Ƕ�������ߣ���λ��deg/h^0.5
Bs = sqrt(abs(C(:, 3))) / 0.6643;	%��ƫ���ȶ��ԣ���λ��deg/h
K = sqrt(abs(C(:, 4) * 3)) * 60;	%���������ߣ���λ��deg/h/h^0.5
R = sqrt(abs(C(:, 5) * 2)) * 3600;	%����б�£���λ��deg/h/h

fprintf('��������      X�᣺%f Y�᣺%f Z�᣺%f  ��λ��deg/h\n', Q(1), Q(2), Q(3));
fprintf('�Ƕ��������  X�᣺%f Y�᣺%f Z�᣺%f  ��λ��deg/h^0.5\n', N(1), N(2), N(3));
fprintf('��ƫ���ȶ���  X�᣺%f Y�᣺%f Z�᣺%f  ��λ��deg/h\n', Bs(1), Bs(2), Bs(3));
fprintf('����������    X�᣺%f Y�᣺%f Z�᣺%f  ��λ��deg/h/h^0.5\n', K(1), K(2), K(3));
fprintf('����б��      X�᣺%f Y�᣺%f Z�᣺%f  ��λ��deg/h/h\n', R(1), R(2), R(3));

D(:, 1) = sqrt(C(1,1)*A.^(-2) + C(1,2)*A.^(-1) + C(1,3)*A.^(0) + C(1,4)*A.^(1) + C(1,5)*A.^(2));	%������Ϻ���
D(:, 2) = sqrt(C(2,1)*A.^(-2) + C(2,2)*A.^(-1) + C(2,3)*A.^(0) + C(2,4)*A.^(1) + C(2,5)*A.^(2));
D(:, 3) = sqrt(C(3,1)*A.^(-2) + C(3,2)*A.^(-1) + C(3,3)*A.^(0) + C(3,4)*A.^(1) + C(3,5)*A.^(2));

loglog(A, D);   %��˫��������ͼ