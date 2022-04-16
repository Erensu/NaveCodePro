%% Algorithm Introduction
%加速度计标定实际实验
% Author :zouzelan
% Version : V3.0 
% Date :
% File : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;                                           % close all figures
clc;                                                 % clear cmd text
clear ;                                              % clear all RAM
disp('加计标定实验');
%% Load data
% load ('C:\Users\zouzelan\Desktop\data\vsb0613.mat')
load ('Data/imu1CaliMethodsPara.mat')
vsb = vsbib';

g0 = 9.794281725483827;
Sz = (vsb(1,3)-vsb(5,3))/(2*g0);
Sx = (vsb(9,1)-vsb(13,1))/(2*g0);
Sy = (vsb(17,2)-vsb(21,2))/(2*g0);
Bz = (vsb(1,3)+vsb(5,3))/2;
Bx = (vsb(9,1)+vsb(13,1))/2;
By = (vsb(17,2)+vsb(21,2))/2;

% x0 = [Bx,By,Bz,Sx,Sy,Sz,0,0,0];
Ks=diag([Sx,Sy,Sz])^(-1);
x0 = [Bx,By,Bz,Ks(1,1),Ks(2,2),Ks(3,3),0,0,0];
Sx=Ks(1,1);  Sy=Ks(2,2);  Sz=Ks(3,3);
%% Algorithm time

%% Memory allocation
bf=[];%缓存种群最佳适应度，记录每一代进化中最好的适应度和平均适应度，可以用来绘图反映是否过早收敛
af=[];%缓存种群平均适应适应度
navs = [];
best = [];
fit = [];
chrome = [];
%% Initial data 
popsize = 50;%种群大小
gensize = 100;%迭代次数
lenchrome = 9;%染色体个数即参数个数,9个

LB=[Bx-0.3,By-0.3,Bz-0.3,Sx-0.01,Sy-0.01,Sz-0.01,-0.2,-0.2,-0.2]';   % 参数下界
UB=[Bx+0.3,By+0.3,Bz+0.3,Sx+0.01,Sy+0.01,Sz+0.01,0.2,0.2,0.2]';   % 参数上界

%% Function index

%% Algorithm develop

for k = 1:1   %可以设置重复数
    for i=1:popsize
         for m= 1:popsize
            individuals.chrome(m,:) = code(lenchrome,LB,UB,2);%随机产生
            x=individuals.chrome(m,:);%随机种群的染色体（参数）
            individuals.fitness(m)=searchfun(x,vsb,g0,2);%计算染色体适应度
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
    
    %找最好的染色使
    [bestfitness,bestindex]=min(individuals.fitness);%得到初始化种群的最大的适应度函数值和位置。
    bestchrome=individuals.chrome(bestindex,:);%适应度最好的染色体
    individuals.fitness = 1./individuals.fitness;
    sumfitness = sum(individuals.fitness);
    fmax = max(individuals.fitness);
    favg = sumfitness/popsize; 

    for i = 1:gensize

        num = i;%计数
        individuals = select(popsize,individuals,sumfitness,1);%选择

        individuals.chrome = GA_cross(lenchrome,individuals,popsize,LB,UB,num,fmax,favg,5);%交叉

        individuals.chrome = GA_mutation(popsize,individuals,fmax,favg,lenchrome,LB,UB,[1 gensize],num,5);%变异

        %计算适应度
        for j = 1:popsize
            x=individuals.chrome(j,:);
            individuals.fitness(j)=searchfun(x,vsb,g0,2);%计算染色体适应度
        end
        sumfitness = sum(individuals.fitness);
        favg = sumfitness/popsize;
        fmin = min(individuals.fitness);
        alpha = favg/(favg-fmin);beta = fmin*favg/(favg-fmin);
        for i = 1:popsize
            fitness(i)= alpha*individuals.fitness(i)+beta;
        end
        individuals.fitness = fitness;
        [newbestfitness,newbestindex] = min(individuals.fitness);
        if bestfitness >=newbestfitness%比较最优适应度
           bestfitness = newbestfitness; 
           bestchrome = individuals.chrome(newbestindex,:);%当前最优的参数  
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
    end
    [fitness,index] = min(bf);
    chrome = navs(index(1),:);
 end

bestchrome = chrome;
disp(bestchrome);%最后一个bestchrome

%% Save Workspace
x = bestchrome(end,:);
%% 测试
% options = optimoptions(@fminunc,'Algorithm','quasi-newton');%设置高斯牛顿法求解
% [QN]= fminunc(@(x)searchfun(x,vsb,g0,2),x0,options);
C = mAccCaliDescent(vsb',([x0(4),0,x0(5),0,0,x0(6),x0(1:3)])',g0,2,2);
x2 = [C.X(7) C.X(8) C.X(9) C.X(1) C.X(3) C.X(6) C.X(2) C.X(4) C.X(5)];

module_value1 = static_pos(x,testda,2);
module_value2 = static_pos(x2,testda,2);
calibrate_before_module_value=sqrt(sum(testda.^2,2));
[vas1,stdvas1,mmvas1]=slideVarStd(module_value1,800);
[vas2,stdvas2,mmvas2]=slideVarStd(module_value2,800);
[vas4,stdvas4,mmvas4]=slideVarStd(calibrate_before_module_value,1000);

%% 数据分析
%% 测试数据对比 
testda = testda';L = length(testda);
RMSE_before = sqrt(sum((sqrt(testda(1,:).^2+testda(2,:).^2+testda(3,:).^2)-g0).^2)/L)/g0;

x3 = x2;
Kan = [x3(4),  0,   0
       x3(7), x3(5), 0
       x3(8), x3(9), x3(6)];
biasn = [x3(1) x3(2) x3(3)];
tsbn = testda;
tbn = Kan*tsbn;
tbn(1,:)=tbn(1,:)-biasn(1); tbn(2,:)=tbn(2,:)-biasn(2); tbn(3,:)=tbn(3,:)-biasn(3);
RMSE_N_after = sqrt(sum((sqrt(tbn(1,:).^2+tbn(2,:).^2+tbn(3,:).^2)-g0).^2)/L)/g0;

Kag = [x(4),  0,   0
       x(7), x(5), 0
       x(8), x(9), x(6)];
biasg = [x(1) x(2) x(3)];
tsbg = testda;
tbg = Kag*tsbg;
tbg(1,:)=tbg(1,:)-biasg(1); tbg(2,:)=tbg(2,:)-biasg(2); tbg(3,:)=tbg(3,:)-biasg(3);
RMSE_G_after = sqrt(sum((sqrt(tbg(1,:).^2+tbg(2,:).^2+tbg(3,:).^2)-g0).^2)/L)/g0;

%% 画图分析
figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',[13 9 10 7]);
set(gca,'looseInset',[0 0 0 0]) %去白边
plot((1:length(mmvas2))/400,mmvas2,'b','Linewidth',2)
hold on
plot((1:length(mmvas2))/400,mmvas1,'k','Linewidth',2)
hold on
plot((1:length(mmvas2))/400,repmat(g0,1,length(mmvas1)),'r','Linewidth',2)
hold on 
plot((1:length(mmvas2))/400,mmvas4,'g','Linewidth',2)
legend('\fontsize{10}\fontname{宋体}经典牛顿法','\fontsize{10}\fontname{宋体}本文方法','\fontsize{10}\fontname{宋体}当地重力真值','\fontsize{10}\fontname{宋体}标定前模值');
xlabel('\fontsize{10}\fontname{宋体}时间(s)'); %fontsize用来设置字体大小，fontname用来设置字体
ylabel('\fontsize{10}\fontname{宋体}加速度值（m/s^2）');
grid on;

figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',[13 9 10 7]);
set(gca,'looseInset',[0 0 0 0]) %去白边
plot(af(101:200),'b','Linewidth',2);
hold on;
plot(bf(101:200),'k','Linewidth',2);
xlabel('\fontsize{10}\fontname{宋体}迭代次数'); %fontsize用来设置字体大小，fontname用来设置字体
ylabel('\fontsize{10}\fontname{宋体}最优适应度值');
legend('\fontsize{10}\fontname{宋体}平均适应度值','\fontsize{10}\fontname{宋体}最佳适应度值');
grid on;

figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',[13 9 10 7]);
set(gca,'looseInset',[0 0 0 0]) %去白边
plot(navs(101:200,1),'b','Linewidth',2);
hold on;
plot(navs(101:200,2),'k','Linewidth',2);
hold on;
plot(navs(101:200,3),'r--','Linewidth',2);
legend('\fontsize{10}\fontname{Times New Roman}B_x','\fontsize{10}\fontname{Times New Roman}B_y','\fontsize{10}\fontname{Times New Roman}B_z');
xlabel('\fontsize{10}\fontname{宋体}种群代数'); %fontsize用来设置字体大小，fontname用来设置字体
ylabel('\fontsize{10}\fontname{宋体}零偏值（m/s^2）');
grid on;

figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',[13 9 10 7]);
set(gca,'looseInset',[0 0 0 0]) %去白边
plot(navs(101:200,4),'b','Linewidth',2);
hold on;
plot(navs(101:200,5),'k','Linewidth',2);
hold on;
plot(navs(101:200,6),'r--','Linewidth',2);
axis on;
legend('\fontsize{10}\fontname{Times New Roman}S_{xx}','\fontsize{10}\fontname{Times New Roman}S_{yy}','\fontsize{10}\fontname{Times New Roman}S_{zz}');
xlabel('\fontsize{10}\fontname{宋体}种群代数'); %fontsize用来设置字体大小，fontname用来设置字体
ylabel('\fontsize{10}\fontname{宋体}标度因子值');
grid on;

figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',[13 9 10 7]);
set(gca,'looseInset',[0 0 0 0]) %去白边
plot(navs(101:200,7),'b','Linewidth',2);
hold on;
plot(navs(101:200,8),'k','Linewidth',2);
hold on;
plot(navs(101:200,9),'r--','Linewidth',2);
legend('\fontsize{10}\fontname{Times New Roman}M_{xx}','\fontsize{10}\fontname{Times New Roman}M_{yy}','\fontsize{10}\fontname{Times New Roman}M_{zz}');
xlabel('\fontsize{10}\fontname{宋体}种群代数'); %fontsize用来设置字体大小，fontname用来设置字体
ylabel('\fontsize{10}\fontname{宋体}非正交误差值');
grid on;