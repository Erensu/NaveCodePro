clear all;
clc;
close all;
snr=5;% ���������
N=1000;
t=1:N;
y=sin(0.03*t);%���������ź�
[s,noise]=Gnoisegen(y,snr);%�Ӹ�˹������
figure(1)
subplot(211);
plot(y);
xlabel('�������');
ylabel('��ֵ');
title('ԭʼ�ź�');
subplot(212);
plot(s);
xlabel('�������');
ylabel('��ֵ');
title('�����ź�');
%̽��С������ȥ��Ч����Ӱ��
sym=['sym1';'sym2';'sym3';'sym4';'sym5';'sym6';'sym7';'sym8'];
db=['db1';'db2';'db3';'db4';'db5';'db6';'db7';'db8'];
coif=['coif1';'coif2';'coif3';'coif4';'coif5'];
snrsym=levelandth1(y,s,sym,8);
snrdb=levelandth1(y,s,db,8);
snrcoif=levelandth1(y,s,coif,5);
ksym=1:8;
kdb=1:8;
kcoif=1:5;
figure(2)
plot(ksym,snrsym,'r-',kdb,snrdb,'g-',kcoif,snrcoif,'b-'),grid on;
legend('symС��ϵ','dbС��ϵ','coifС��ϵ');
xlabel('С����');
ylabel(' ȥ��������/dB');
title('С������ȥ�������ȵĹ�ϵ');

%̽�ַֽ������ȥ��Ч����Ӱ��
thrrr1='sqtwolog';
thrrr2='rigrsure';
thrrr3='heursure';
thrrr4='minimaxi';
wavec='sym4';
[M1,snrxd1]=level(y,s,thrrr1,wavec);%ȷ��С����ѷֽ����
[M2,snrxd2]=level(y,s,thrrr2,wavec);
[M3,snrxd3]=level(y,s,thrrr3,wavec);
[M4,snrxd4]=level(y,s,thrrr4,wavec);
fprintf('sqtwolog��ֵ��ѷֽ����:%d \n',M1);
fprintf('rigrsure��ֵ��ѷֽ����: %d\n',M2);
fprintf('heursure��ֵ��ѷֽ����: %d\n',M3);
fprintf('minimaxi��ֵ��ѷֽ����: %d\n',M4);
k=1:10;
figure(3)
plot(k,snrxd1,'r-',k,snrxd2,'m-',k,snrxd3,'g-',k,snrxd4,'b-'),grid on;
legend('sqtwolog��ֵ','rigrsure��ֵ','heursure��ֵ','minimaxi��ֵ');
xlabel('�ֽ����');
ylabel(' ȥ��������/dB');
title('�ֽ������ȥ�������ȵĹ�ϵ');

%�Ľ���ֵ����
wname='sym4';% ѡsym4С����
lev=5;% 5��ֽ�
[c,l]=wavedec(s,lev,wname);
a5=appcoef(c,l,wname,lev);%��ȡ��Ƶϵ��
d5=detcoef(c,l,5);% ��ȡ��Ƶϵ��
d4=detcoef(c,l,4);
d3=detcoef(c,l,3);
d2=detcoef(c,l,2);
d1=detcoef(c,l,1);
a=4;%���õ�������
cD=[d1,d2,d3,d4,d5];
sigma=median(abs(cD))/0.6745;% cDΪ�����ĸ�ƵС��ϵ��
thr1=(sigma*sqrt(2*(log(length(y)))))/(log(1+1));
for i=1:length(d1)
if(d1(i)>=thr1)
    cD1(i)=d1(i)-thr1/(1+exp(((d1(i)-thr1).^2)/a))-thr1/(2*exp(1/a));% ���Ƶ�һ��С��ϵ��
else if(abs(d1(i))<thr1)
        cD1(i)=0;
    else
        cD1(i)=d1(i)+thr1/(1+exp(((-d1(i)-thr1).^2)/a))+thr1/(2*exp(1/a));
    end
end
end
thr2=(sigma*sqrt(2*(log(length(y)))))/(log(2+1));
for i=1:length(d2)
if(d2(i)>=thr2)
    cD2(i)=d2(i)-thr2/(1+exp(((d2(i)-thr2).^2)/a))-thr2/(2*exp(1/a));% ���Ƶڶ���С��ϵ��
else if(abs(d2(i))<thr2)
        cD2(i)=0;
    else
        cD2(i)=d2(i)+thr2/(1+exp(((-d2(i)-thr2).^2)/a))+thr2/(2*exp(1/a));
    end
end
end
thr3=(sigma*sqrt(2*(log(length(y)))))/(log(3+1));
for i=1:length(d3)
if(d3(i)>=thr3)
    cD3(i)=d3(i)-thr3/(1+exp(((d3(i)-thr3).^2)/a))-thr3/(2*exp(1/a));% ���Ƶ�����С��ϵ��
else if(abs(d3(i))<thr3)
        cD3(i)=0;
    else
        cD3(i)=d3(i)+thr3/(1+exp(((-d3(i)-thr3).^2)/a))+thr3/(2*exp(1/a));
    end
end
end
thr4=(sigma*sqrt(2*(log(length(y)))))/(log(4+1));
for i=1:length(d4)
if(d4(i)>=thr4)
    cD4(i)=d4(i)-thr4/(1+exp(((d4(i)-thr4).^2)/a))-thr4/(2*exp(1/a));% ���Ƶ��Ĳ�С��ϵ��
else if(abs(d4(i))<thr4)
        cD4(i)=0;
    else
        cD4(i)=d4(i)+thr4/(1+exp(((-d4(i)-thr4).^2)/a))+thr4/(2*exp(1/a));
    end
end
end
thr5=(sigma*sqrt(2*(log(length(y)))))/(log(5+1));
for i=1:length(d5)
if(d5(i)>=thr5)
    cD5(i)=d5(i)-thr5/(1+exp(((d5(i)-thr5).^2)/a))-thr5/(2*exp(1/a));% ���Ƶ����С��ϵ��
else if(abs(d5(i))<thr5)
        cD5(i)=0;
    else
        cD5(i)=d5(i)+thr5/(1+exp(((-d5(i)-thr5).^2)/a))+thr5/(2*exp(1/a));
    end
end
end
% ��ʼ�ع�
cd=[a5,cD5,cD4,cD3,cD2,cD1];
c=cd;
yhs=waverec(cd,l,wname);

%������ֵ������ֵ������ȥ��Ч���Ƚ�
xdh1=wden(s,'sqtwolog','h','mln',M1,wavec);
figure(5)
subplot(211);
plot(xdh1);
xlabel('�������');
ylabel('��ֵ');
title('sqtwolog��ֵ+Ӳ��ֵ����ȥ�뷨Ч��ͼ');
xds1=wden(s,'sqtwolog','s','mln',M1,wavec);
subplot(212);
plot(xds1);
xlabel('�������');
ylabel('��ֵ');
title('sqtwolog��ֵ+����ֵ����ȥ�뷨Ч��ͼ');
xdh2=wden(s,'rigrsure','h','mln',M2,wavec);
figure(6)
subplot(211);
plot(xdh2)
xlabel('�������');
ylabel('��ֵ');
title('rigrsure��ֵ+Ӳ��ֵ����ȥ�뷨Ч��ͼ');
xds2=wden(s,'rigrsure','s','mln',M2,wavec);
subplot(212);
plot(xds2);
xlabel('�������');
ylabel('��ֵ');
title('rigrsure��ֵ+����ֵ����ȥ�뷨Ч��ͼ');
xdh3=wden(s,'heursure','h','mln',M3,wavec);
figure(7)
subplot(211);
plot(xdh3);
xlabel('�������');
ylabel('��ֵ');
title('heursure��ֵ+Ӳ��ֵ����ȥ�뷨Ч��ͼ');
xds3=wden(s,'heursure','s','mln',M3,wavec);
subplot(212);
plot(xds3);
xlabel('�������');
ylabel('��ֵ');
title('heursure��ֵ+����ֵ����ȥ�뷨Ч��ͼ');
xdh4=wden(s,'minimaxi','h','mln',M4,wavec);
figure(8)
subplot(211);
plot(xdh4);
xlabel('�������');
ylabel('��ֵ');
title('minimaxi��ֵ+Ӳ��ֵ����ȥ�뷨Ч��ͼ');
xds4=wden(s,'minimaxi','s','mln',M4,wavec);
subplot(212);
plot(xds4);
xlabel('�������');
ylabel('��ֵ');
title('minimaxi��ֵ+����ֵ����ȥ�뷨Ч��ͼ');
figure(9)
subplot(211);
plot(yhs,'LineWidth',1);
xlabel('�������');
ylabel('��ֵ');
title('�Ľ�����ֵȥ�뷨Ч��ͼ');

%����ȥ��������
snrxn=snrr(y,s);
fprintf(' ԭ�����ź������ %4.4f\n',snrxn);
snrxdh1=snrr(y,xdh1);
fprintf(' sqtwolog��ֵ+Ӳ��ֵ����ȥ������� %4.4f\n',snrxdh1);
snrxdh1=snrr(y,xds1);
fprintf(' sqtwolog��ֵ+����ֵ����ȥ������� %4.4f\n',snrxdh1);
snrxdh2=snrr(y,xdh2);
fprintf(' rigrsure��ֵ+Ӳ��ֵ����ȥ������� %4.4f\n',snrxdh2);
snrxds2=snrr(y,xds2);
fprintf(' rigrsure��ֵ+����ֵ����ȥ������� %4.4f\n',snrxds2);
snrxdh3=snrr(y,xdh3);
fprintf(' heursure��ֵ+Ӳ��ֵ����ȥ������� %4.4f\n',snrxdh3);
snrxds3=snrr(y,xds3);
fprintf(' heursure��ֵ+����ֵ����ȥ������� %4.4f\n',snrxds3);
snrxdh4=snrr(y,xdh4);
fprintf(' minimaxi��ֵ+Ӳ��ֵ����ȥ������� %4.4f\n',snrxdh4);
snrxds4=snrr(y,xds4);
fprintf(' minimaxi��ֵ+����ֵ����ȥ������� %4.4f\n',snrxds4);
snrys=snrr(y,yhs);
fprintf(' �Ľ��������� %4.4f\n',snrys);
