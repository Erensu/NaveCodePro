function  err = fplot(avp,refavp,flag)
%% -----------Introduction------------
%ͨ�û�ͼ����
%input: 
%-------avp : �Ի��ȴ��� N*10
%-------refavp : �Ի��ȴ��� N*10
global glv
t = refavp(:,end);
set(0,'defaultfigurecolor','w') %figure ������ɫ
set(gcf,'unit','centimeters','position',[13 9 12 9]);
set(gcf, 'Color', [1,1,1]);%ͼ����Χ��Ϊ��ɫ
%�ο��켣
% figure('name','avp�ο��˶���Ϣ')
% subplot(321), plot(t, refavp(:,1:2)/glv.deg,'Linewidth',2); xygo('pr');%����͸�����̬��
% subplot(322), plot(t, refavp(:,3)/glv.deg,'Linewidth',2); xygo('y');%�����̬��
% subplot(323), plot(t, [refavp(:,4:6),sqrt(refavp(:,4).^2+refavp(:,5).^2+refavp(:,6).^2)],'Linewidth',2); xygo('V');%�ٶȼ����ٶ�
% dxyz = dposxyz(refavp(:,7:9));
% subplot(325), plot(t, dxyz(:,1:3),'Linewidth',2); xygo('DP');%λ������
% subplot(3,2,[4,6]), plot(0, 0, 'rp');   % ���
% hold on, plot(dxyz(end,2), dxyz(end,1),'gp');   %�յ�
% hold on, plot(dxyz(:,2), dxyz(:,1),'Linewidth',2); xygo('est', 'nth');

%���ͼ
avp = [avp(:,1:3)/glv.deg avp(:,4:6) avp(:,7:8)/glv.deg avp(:,9) avp(:,10)];%��Ϊ��׼��λ
refavp = [refavp(:,1:3)./glv.deg refavp(:,4:6) refavp(:,7:8)./glv.deg refavp(:,9) refavp(:,10)];
erratt = -aa2phi(avp(:,1:3).*glv.deg,refavp(:,1:3).*glv.deg)./glv.deg;
errvel = avp(:,4:6) - refavp(:,4:6);
errpos = avp(:,7:9) - refavp(:,7:9);
errpos(:,1:2) = errpos(:,1:2).*60.*glv.nm;

err = varpack(erratt,errvel,errpos);
if flag
figure('name', 'KF��̬���');
set(gcf,'unit','centimeters','position',[13 9 12 9]);
set(gcf, 'Color', [1,1,1]);%ͼ����Χ��Ϊ��ɫ
plot(t,erratt(:,1:3),'Linewidth',2);grid on;
xlabel('\fontsize{12}\fontname{Times New Roman}Time(s)') %fontsize�������������С��fontname������������
ylabel('\fontsize{12}\fontname{Times New Roman}Attitude Error (deg)')
legend('\fontsize{12}\fontname{����}������','\fontsize{12}\fontname{����}�����','\fontsize{12}\fontname{����}��ƫ��');

figure('name', 'KF�ٶ����');
set(gcf,'unit','centimeters','position',[13 9 12 9]);
set(gcf, 'Color', [1,1,1]);%ͼ����Χ��Ϊ��ɫ
plot(t,errvel(:,1:3),'Linewidth',2);grid on;
xlabel('\fontsize{12}\fontname{Times New Roman}Time(s)') %fontsize�������������С��fontname������������
ylabel('\fontsize{12}\fontname{Times New Roman}Velocity Error (m/s)')
legend('\fontsize{12}\fontname{����}�����ٶ�','\fontsize{12}\fontname{����}�����ٶ�','\fontsize{12}\fontname{����}�����ٶ�');

figure('name', 'KFλ�����');
set(gcf,'unit','centimeters','position',[13 9 12 9]);
set(gcf, 'Color', [1,1,1]);%ͼ����Χ��Ϊ��ɫ
plot(t,errpos(:,1:3),'Linewidth',2);grid on;
xlabel('\fontsize{12}\fontname{Times New Roman}Time(s)') %fontsize�������������С��fontname������������
ylabel('\fontsize{12}\fontname{Times New Roman}Position Error (m)')
legend('\fontsize{12}\fontname{����}γ��','\fontsize{12}\fontname{����}����','\fontsize{12}\fontname{����}�߶�');
end
end