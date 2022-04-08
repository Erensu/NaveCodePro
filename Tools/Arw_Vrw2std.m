function res=Arw_Vrw2std(arw,vrw,dt,pos0,flag)
% �Ϲ��������� ARW, VRW �� ������׼���ת��
% ����ԭ�ͣ� res=Arw_Vrw2std(arw,vrw,dt,pos0,flag)
% ���������
%    dt�������������λ s.    pos0:[γ��; ����; �߶�], γ�ȡ����ȵ�λ��rad���߶ȵ�λm
%  falg=1ʱ, arw��λ ��/sqrt(h),  vrw��λ ug/sqrt(Hz)
%  flag=2ʱ, arw��λ ��/s,  vrw��λ m/s2, Ϊ��ֹ���ݱ�׼��.
%
%  �������;res: {arw, vrw, acc_std, gyro_std}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : Xu Tongxu
% Date : 2021.3.31
% File : 2015.NaveGo: a simulation framework for low-cost integrated navigation systems.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eth=earth(pos0,zeros(3,1));
g0  = mxGetGravity(pos0(1),pos0(3));
ug=g0*10^(-6);

if(flag==1)
    % ��/sqrt(h) ת ��/s
    gyro_std=(arw/(60*sqrt(dt)));         % ������� dt�£���̬���ݱ�׼�����
    % ug/sqrt(Hz) ת m/s2
    acc_std=(vrw/sqrt(dt))*ug;            % ������� dt�£���̬���ݱ�׼�����
else
    if(flag==2)
        gyro_std=arw;     acc_std=vrw;
         %  ��/s  ת  ��/sqrt(h)
         arw=gyro_std*60*sqrt(dt);
         
         % m/s2   ת  ug/sqrt(Hz)
         vrw=acc_std*sqrt(dt)/ug;
    end
end

res=varpack(arw,vrw,gyro_std,acc_std);

end