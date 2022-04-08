function err=mToolLatLonErrorMeters(rflat,rflon,lat,lon,rfH)
% ���ߣ�ת����γ����� Ϊ�ף�������
%%======================================================================= 
%input:
%   lat:�����γ�� 1*N
%   lon:����ľ��� 1*N
%   relat:�ο��켣��γ�� 1*N
%   reflon:�ο��켣�ľ��� 1*N
%   rfH: �ο��߶�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : xutongxu
% Version :  
% Date : 2020.9.8
% File : 
%output :err.erx:γ�����
%             err.ery:�������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=length(rflat);
erlat=lat-rflat;
erlon=lon-rflon;
Re=6378137.0;
f=0.003352813177897;

Rm=zeros(1,N);   Rn=Rm;
ery=zeros(1,N);   erx=ery;
if(nargin>4)
	for i=1:N
		L0=rflat(i);
		Rm(i)=Re*(1-2*f+3*f*sin(L0)^2) +rfH(i);
		Rn(i)=Re*(1+f*sin(L0)^2) +rfH(i); 
		ery(i)=Rm(i)*erlat(i);
		erx(i)=Rn(i).*erlon(i)*cos(L0);
	end
else
    for i=1:N
		L0=rflat(i);
		Rm(i)=Re*(1-2*f+3*f*sin(L0)^2);
		Rn(i)=Re*(1+f*sin(L0)^2); 
		ery(i)=Rm(i)*erlat(i);
		erx(i)=Rn(i).*erlon(i)*cos(L0);
    end
end

% theta*R=arc
% erN=Rm.*erlat;
% erE=Rn.*erlon;
err=varpack(ery,erx);
end