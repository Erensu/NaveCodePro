function fit =searchfun(x,vsb,g0,flag)
%% Function Introduction
% This function is...Ŀ�꺯��
%% Load data

% vsb = [(vsb(1:5,:));vsb(9,:);vsb(13,:);vsb(17,:);vsb(21,:)];
vsb = vsb';
%% Function realize 
	N = length(vsb);
	Ka = [x(4),  0,   0
		  x(7), x(5), 0
		  x(8), x(9), x(6)];
	bias = [x(1) x(2) x(3)];

	switch(flag)
		case 1 %ģ��1
			fb = Ka*vsb;
			fb(1,:)=fb(1,:)-bias(1); fb(2,:)=fb(2,:)-bias(2); fb(3,:)=fb(3,:)-bias(3);
		case 2 %ģ��2
			fb = Ka* [vsb(1,:)-bias(1);vsb(2,:)-bias(2);vsb(3,:)-bias(3)];
        case 3 %ģ��3
            fb = vsb+Ka*vsb;
            fb(1,:)=fb(1,:)-bias(1); fb(2,:)=fb(2,:)-bias(2); fb(3,:)=fb(3,:)-bias(3);
	end
	vnm = (fb(1,:).^2 +fb(2,:).^2 +fb(3,:).^2)-g0^2;  % ʸ��ģ
   	fit = sum(vnm.^2)/N;%���ۺ�����ʸ��ģ��С
% 	fit = sum(abs(vnm));%���ۺ�����ʸ��ģ��С
end