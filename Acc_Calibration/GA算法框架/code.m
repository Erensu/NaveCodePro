function ret = code(lenchrome,LB,UB,flag)
%% Function Introduction
%���Ա��������ʼ��Ⱥ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Function realize  
    switch(flag)
        case 1
            ret = liner_code(lenchrome,LB,UB);%���Ա���
        case 2
            ret = adaptive_code(lenchrome,LB,UB);%���ֱ���     
    end
end

function res = liner_code(lenchrome,LB,UB)
	flag=0;
    LB=LB';UB=UB';%��ԭ������������Ϊ������
    while flag==0
		pick1 = rand(1,6);
		ret1=LB(1:6)+(UB(1:6)-LB(1:6)).*pick1;
		pick2 = 0.5*rand(1,3);
		ret2=LB(7:9)+(UB(7:9)-LB(7:9)).*pick2;
		ret = [ret1 ret2];
		flag=test(lenchrome,LB,UB,ret);%�߽���
    end
    res = ret;
end

function res = adaptive_code(lenchrome,LB,UB)
   flag=0;
    while flag==0
		pick = rand(1,lenchrome);
		ret  = LB' +(UB' - LB').*pick; 
		flag=test(lenchrome,LB,UB,ret);%�߽���
    end
    res = ret;
end

