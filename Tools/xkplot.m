function xkplot(xkpk)
[m,n] = size(xkpk);
% kalman �˲����
attkalsta = xkpk(:,1:3)./glv.deg;                                         % ״̬����̬���
velkalsta = xkpk(:,4:6);  
poskalsta = xkpk(:,7:9); 
poskalsta(:,1:2) = poskalsta(:,1:2)./glv.deg.*60.*glv.nm;
ebkalsta = xkpk(:,10:12)./glv.dph;
dbkalsta = xkpk(:,13:15)./glv.ug;

%P��ͳ�ƽ��
pkalsta = sqrt(xkpk(:,19:36));
pkalsta(:,1:3) = pkalsta(:,1:3)./glv.deg;
pkalsta(:,7:8) = pkalsta(:,7:8)./glv.deg.*60.*glv.nm;
pkalsta(:,10:12) = pkalsta(:,7:9)./glv.dph;
pkalsta(:,13:15) = pkalsta(:,10:12)./glv.ug;
end