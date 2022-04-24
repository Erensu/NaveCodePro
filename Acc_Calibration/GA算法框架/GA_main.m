function [bestchrome,x0] = GA_main(vsb)
%% Algorithm Introduction
%  A test model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author :zouzelan
% Version : V3.0 
% Date :
% File : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g0 = 9.794281725483827;
Sz = (vsb(1,3)-vsb(5,3))/(2*g0);
Sx = (vsb(9,1)-vsb(13,1))/(2*g0);
Sy = (vsb(17,2)-vsb(21,2))/(2*g0);
Bz = (vsb(1,3)+vsb(5,3))/2;
Bx = (vsb(9,1)+vsb(13,1))/2;
By = (vsb(17,2)+vsb(21,2))/2;

Ks=diag([Sx,Sy,Sz])^(-1);
x0 = [Bx,By,Bz,Ks(1,1),Ks(2,2),Ks(3,3),0,0,0];
Sx=Ks(1,1);  Sy=Ks(2,2);  Sz=Ks(3,3);
%% Algorithm time

%% Memory allocation
bf=[];%������Ⱥ�����Ӧ�ȣ���¼ÿһ����������õ���Ӧ�Ⱥ�ƽ����Ӧ�ȣ�����������ͼ��ӳ�Ƿ��������
af=[];%������Ⱥƽ����Ӧ��Ӧ��
navs = [];
best = [];
fit = [];
chrome = [];
%% Initial data 
popsize = 50;%��Ⱥ��С
gensize = 100;%��������
lenchrome = 9;%Ⱦɫ���������������,9��


% LB=[Bx-0.002,By-0.001,Bz-0.003,Sx-0.005,Sy-0.005,Sz-0.005,-0.02,-0.02,-0.02]';   % �����½�
% UB=[Bx+0.001,By+0.001,Bz+0.003,Sx+0.005,Sy+0.005,Sz+0.005,0,0,0]';   % �����Ͻ�

LB=[Bx-0.05,By-0.05,Bz-0.05,Sx-0.01,Sy-0.01,Sz-0.01,-0.02,-0.02,-0.02]';   % �����½�  2020.09.03�޸�
UB=[Bx+0.05,By+0.05,Bz+0.05,Sx+0.01,Sy+0.01,Sz+0.01,0.02,0.02,0.02]';   % �����Ͻ�




%% Function index
% buf=zeros(5*gensize,9);
% kk=1;
%% Algorithm develop
 for k = 1:5   %
     
	for i=1:popsize
         for m= 1:popsize
            individuals.chrome(m,:) = code(lenchrome,LB,UB,2);%�������
            x=individuals.chrome(m,:);%�����Ⱥ��Ⱦɫ�壨������
            individuals.fitness(m)=searchfun(x,vsb,g0,2);%����Ⱦɫ����Ӧ��
         end
         [F,code_index] = sort(individuals.fitness);
         individuals.chrome(i,:) = individuals.chrome(code_index(1),:);
         individuals.fitness(i) = F(1);
    end
    sumfitness = sum(individuals.fitness);
	favg = sumfitness/popsize;
	fmin = min(individuals.fitness);
	alpha = favg/(favg-fmin);beta = fmin*favg/(favg-fmin);
	for i = 1:popsize
		fitness(i)= alpha*individuals.fitness(i)+beta;
    end
    individuals.fitness = fitness;
    
	%����õ�Ⱦɫʹ
	[bestfitness,bestindex]=min(individuals.fitness);%�õ���ʼ����Ⱥ��������Ӧ�Ⱥ���ֵ��λ�á�
	bestchrome=individuals.chrome(bestindex,:);%��Ӧ����õ�Ⱦɫ��
    individuals.fitness = 1./individuals.fitness;
	sumfitness = sum(individuals.fitness);
	fmax = max(individuals.fitness);
	favg = sumfitness/popsize; 

	for i = 1:gensize

		num = i;%����
		individuals = select(popsize,individuals,sumfitness,1);%ѡ��
		
		individuals.chrome = GA_cross(lenchrome,individuals,popsize,LB,UB,num,fmax,favg,5);%����
		
		individuals.chrome = GA_mutation(popsize,individuals,fmax,favg,lenchrome,LB,UB,[1 gensize],num,5);%����
		
		%������Ӧ��
        for j = 1:popsize
            x=individuals.chrome(j,:);
            individuals.fitness(j)=searchfun(x,vsb,g0,2);%����Ⱦɫ����Ӧ��
        end
        
%         individuals = elitism_save(individuals);%��Ӣ��������
        
		[newbestfitness,newbestindex] = min(individuals.fitness);
        if bestfitness >=newbestfitness%�Ƚ�������Ӧ��
           bestfitness = newbestfitness; 
           bestchrome = individuals.chrome(newbestindex,:);%��ǰ���ŵĲ���  
        end
      
        sumfitness = sum(individuals.fitness);
        favg = sumfitness/popsize;
		bf = [bf bestfitness];
		af = [af favg];
		navs=[navs;bestchrome];

        
        individuals.fitness = 1./individuals.fitness;
        sumfitness = sum(individuals.fitness);
        fmax = max(individuals.fitness);
        favg = sumfitness/popsize; 
        
%         buf(kk,:)=bestchrome;  kk=kk+1;
    end
    [fitness,index] = min(bf);
    chrome = navs(index(1),:);
%     % mei10
%     plot(buf(1:kk-1,4));
%      Dd=Dd*0.6;
%      LB=(chrome-Dd)';
%      UB=(chrome+Dd)';
 end
bestchrome = chrome;

end


