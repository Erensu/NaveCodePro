function [att,vel,pos,qua,Cnb,eth] = avp_update(wbib,fb,Cnb,qua,p0,v0,dt)
%���ߵ�����
eth = EarthParameter(p0,v0);
fn = Cnb*fb;
an = fn + eth.gcc;
vel = v0 + an*dt;

Mpv = [0 1/eth.RMh 0;1/eth.clRNh 0 0;0 0 1];
pos = p0 + Mpv*vel*dt;

eth = EarthParameter(pos,vel); %�����Ƿ���µ��������
wbnb = wbib - Cnb'*eth.wnin;%bϵ��
qua = qupdt(qua,wbnb*dt);%wbnb*dt���൱�ڵ�Ч��ת����rv
Cnb = q2mat(qua);
att = m2att(Cnb);
end