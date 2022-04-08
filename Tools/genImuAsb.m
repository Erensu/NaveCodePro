function [Asba,Asbg]= genImuAsb(gyroAngle,acceAngle)
% �����������任���󣬴����� b ϵ�� ������ϵ�������ǡ����ٶȼ�����ϵ��
% ������ת��˳������������� Zs: ����Zb ���� x ��ת -> ���� y�� ת
%   vector_s=Asba*vector_b; 
%   vector_s=Asbg*vector_b;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���������
%        gyroAngle:[xy,xz,yz,yx,zx,zy]   % ������ת��˳��ĽǶȣ���λ������
%        acc3Angle:[xy,xz,yz,yx,zx,zy]
% ���������
%        Asba: ���ٶȼ�����ϵ��������ϵ  �任����
%        Asbg: ����������ϵ��������ϵ  �任����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : xutongxu
% Version : 1
% Date : 2019.12.16
% File : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Csx_b=mgenRotM(gyroAngle(2),'z',2)*mgenRotM(gyroAngle(1),'y',2);
Rx=Csx_b(1,:);                               % bϵʸ���� s ϵ x����ͶӰ
Csy_b=mgenRotM(gyroAngle(4),'x',2)*mgenRotM(gyroAngle(3),'z',2);
Ry=Csy_b(2,:);                               % bϵʸ���� s ϵ x����ͶӰ
Csz_b=mgenRotM(gyroAngle(6),'y',2)*mgenRotM(gyroAngle(5),'x',2);
Rz=Csz_b(3,:);                               % bϵʸ���� s ϵ x����ͶӰ
Asbg=[Rx;Ry;Rz];                              % ����ϵbϵʸ������sϵͶӰ �任����
Rxb=(Csx_b')*[1;0;0];
Ryb=(Csy_b')*[0;1;0];
Rzb=(Csz_b')*[0;0;1];
ax2y=acos(sum(Rxb.*Ryb)/(norm(Rxb)*norm(Ryb)))*180/pi;
ax2z=acos(sum(Rxb.*Rzb)/(norm(Rxb)*norm(Rzb)))*180/pi;
ay2z=acos(sum(Ryb.*Rzb)/(norm(Ryb)*norm(Rzb)))*180/pi;
fprintf('\n������  ��x-y�нǣ�%.3f��, x-z�нǣ�%.3f��,y-z�нǣ�%.3f��\n',ax2y,ax2z,ay2z);

Csx_b=mgenRotM(acceAngle(2),'z',2)*mgenRotM(acceAngle(1),'y',2);
Rx=Csx_b(1,:);                               % bϵʸ���� s ϵ x����ͶӰ
Csy_b=mgenRotM(acceAngle(4),'x',2)*mgenRotM(acceAngle(3),'z',2);
Ry=Csy_b(2,:);                               % bϵʸ���� s ϵ x����ͶӰ
Csz_b=mgenRotM(acceAngle(6),'y',2)*mgenRotM(acceAngle(5),'x',2);
Rz=Csz_b(3,:);                               % bϵʸ���� s ϵ x����ͶӰ
Rxb=(Csx_b')*[1;0;0];
Ryb=(Csy_b')*[0;1;0];
Rzb=(Csz_b')*[0;0;1];
Asba=[Rx;Ry;Rz];                              % ����ϵbϵʸ������sϵͶӰ �任����
ax2y=acos(sum(Rxb.*Ryb)/(norm(Rxb)*norm(Ryb)))*180/pi;
ax2z=acos(sum(Rxb.*Rzb)/(norm(Rxb)*norm(Rzb)))*180/pi;
ay2z=acos(sum(Ryb.*Rzb)/(norm(Ryb)*norm(Rzb)))*180/pi;
fprintf('���ٶȼƣ�x-y�нǣ�%.3f��, x-z�нǣ�%.3f��,y-z�нǣ�%.3f��\n',ax2y,ax2z,ay2z);
% 
% Ka=Asba;
% Kg=Asbg;
% ax2y=acos(sum(Ka(:,1).*Ka(:,2))/(norm(Ka(:,1))*norm(Ka(:,2))))*180/pi;
% ax2z=acos(sum(Ka(:,1).*Ka(:,3))/(norm(Ka(:,1))*norm(Ka(:,3))))*180/pi;
% ay2z=acos(sum(Ka(:,2).*Ka(:,3))/(norm(Ka(:,2))*norm(Ka(:,3))))*180/pi;
% 
% fprintf('������  ��x-y�нǣ�%.3f��, x-z�нǣ�%.3f��,y-z�нǣ�%.3f��\n',ax2y,ax2z,ay2z);
 end

function mrot=mgenRotM(radian,xyz,check)
% 3ά��������ת����,�������Ҿ���x='x',y='y',z='z':check=1��ת��check=2��������. check��ﲻ��ȷ
% 2020.11.12
r=zeros(3,3);
if(check==1)
    switch xyz
        case 'x'
            r=[1 0 0;
             0, cos(radian), -sin(radian);
             0, sin(radian), cos(radian)];
        case 'y'
          r=[cos(radian), 0, sin(radian);
           0,   1,0;
           -sin(radian),0 , cos(radian)];
         case 'z'
          r=[cos(radian), -sin(radian),0;
            sin(radian),cos(radian),0;
            0, 0, 1];
    end
elseif(check==2)
        switch xyz
         case 'x'
            r=[1 0 0;
             0, cos(radian), sin(radian);
             0, -sin(radian), cos(radian)];
        case 'y'
        r=[cos(radian), 0, -sin(radian);
           0,   1,0;
           sin(radian),0 , cos(radian)];
        case 'z'
        r=[cos(radian), sin(radian),0;
            -sin(radian),cos(radian),0;
            0, 0, 1];
    end
end
mrot=r;
end