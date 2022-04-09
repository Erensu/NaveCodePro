close all;                                           % close all figures
clc;                                                 % clear cmd text
clear ;                                              % clear all RAM
disp('�ӼƱ궨');
popsize = 100;%��Ⱥ��С
gensize = 500;%��������
lenchrome = 9;%Ⱦɫ���������������,9��
LB=[0.1,0.1,0.1,0.95,0.95,0.95,-0.06,-0.06,-0.06]';   % �����½�
UB=[0.2,0.2,0.2,1.05,1.05,1.05,0.03,0.03,0.03]';   % �����Ͻ�
individuals=struct('fitness',zeros(1,popsize),'chrome',[]);%��Ⱥ�ṹ�������Ӧ�Ⱥ�Ⱦɫ�壬�ṹ������ױ�д����
bf=[];%������Ⱥ�����Ӧ�ȣ���¼ÿһ�������Жc�õ���Ӧ�Ⱥ�ƽ����Ӧ�ȣ�����������ͼ��ӳ�Ƿ��������
af=[];%������Ⱥƽ����Ӧ��Ӧ��
navs=[];

%������ʼ��Ⱥ
for i=1:popsize
    individuals.chrome(i,:) = code(lenchrome,LB,UB,1);%�������
    x=individuals.chrome(i,:);%�����Ⱥ��Ⱦɫ�壨������
    individuals.fitness(i)=searchfun(x,0);%����Ⱦɫ����Ӧ��
end
%��Ӧ�ȱ任
individuals.fitness = fitness_change(individuals,popsize,2);
%����õ�Ⱦɫʹ
[bestfitness,bestindex]=max(individuals.fitness);%�õ���ʼ����Ⱥ��������Ӧ�Ⱥ���ֵ��λ�á�
bestchrome=individuals.chrome(bestindex,:);%��Ӧ����õ�Ⱦɫ��
sumfitness = sum(individuals.fitness);
fmax = max(individuals.fitness);
favg = sumfitness/popsize; 
for i = 1:gensize
	num = i;
	individuals = select(popsize,individuals,sumfitness,1);%ѡ��
	individuals.chrome = cross(popsize,individuals,lenchrome,LB,UB,num,5);%����
	individuals.chrome = mutation(popsize,individuals,fmax,favg,lenchrome,LB,UB,[1 gensize],num,5);%����
    %������Ӧ��
    for j = 1:popsize
        x=individuals.chrome(j,:);
        individuals.fitness(j) = searchfun(x,0);
    end
	individuals.fitness = fitness_change(individuals,popsize,2);
    sumfitness = sum(individuals.fitness);
    fmax = max(individuals.fitness);
    favg = sumfitness/popsize; 
	[newbestfitness,newbestindex] = max(individuals.fitness);
	if bestfitness < newbestfitness%�Ƚ�������Ӧ��
       bestfitness = newbestfitness; 
       bestchrome = individuals.chrome(newbestindex,:);%��ǰ���ŵĲ���  
	end
	navs=[navs;bestchrome];
    bf = [bf bestfitness];
    af = [af favg];
end
disp(bestchrome);%���һ��bestchrome
relative_erro = erro(bestchrome);
splot(bf,af,navs);