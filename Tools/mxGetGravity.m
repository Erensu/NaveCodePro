function gravity=mxGetGravity(L,h)
% ����γ�ȡ��߶� �����������ٶ�
% ����ԭ�ͣ�gravity=mxGetGravity(L,h)
% L:γ�ȣ���λ������ h:�߶ȣ���Ժ�ƽ��
% �ο����ף������Ե������ڶ��棬����Ԫ��178ҳ����ʽ��7.2.17��,7.2.18
Re=6378137;% m
var1=(1+0.00193185138639*sin(L)^2);
var2=sqrt(1-0.00669437999013*sin(L)^2);
g=978.03267714*var1/var2;
gra=g*Re^2/((Re+h)^2); % cm/s^2
gravity=gra/100;
return ;