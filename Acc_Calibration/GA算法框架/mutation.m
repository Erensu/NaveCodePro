function ret = mutation(popsize,individuals,fmax,favg,lenchrome,LB,UB,pop,num,flag3)
	for i = 1:popsize
		pick=rand;%��������������
		while pick==0
			pick=rand;
		end
		index=ceil(pick*popsize);%ȡ�������������Ⱦɫ��ı��
		switch(flag3)
			case 1 
				pm = SGA_mutation();%�򵥱�������
			case 2 
				pm =  AGA_mutation(individuals,fmax,favg,index);%����Ӧ��������
			case 3 
				pm = IAGA_mutation(individuals,fmax,favg,index);%��������Ӧ��������
			case 4 
				pm = HIAGA_mutation(individuals,fmax,favg,index);%��������Ӧ��������
			case 5 
				pm = TIAGA_mutation(individuals,fmax,favg,index,num);%��������Ӧ��������	
		end
        pick=0.1*rand;%����һ��������� pm��0.01-0.05֮�䣬ֱ����rand̫�󣬵�����Ⱥ�����ޱ���
		while pick==0
			pick=rand;
		end
		if pick >pm      %���������������ʴ��ڱ�����ʣ���ô����ѭ�������죬�����ڽ��棬������С�����¼�
			continue;
		end
		flag=0;
		while flag==0
			pick=rand;%���������Ϊ0���������λ��
			while pick==0
				pick=rand;
			end
			pos=ceil(pick*lenchrome);%���������λ�ã�Ҳ����Ⱦɫ���ϵĵڼ����������
			v=individuals.chrome(i,pos);%��i��Ⱦɫ����pos����
			v1=v-LB(pos);
			v2=UB(pos)-v;
			pick=rand;%��ʼ���죬ʵֵ���취
			if pick>0.5
				delta=v2*(1-pick^((1-pop(1)/pop(2))^2));
				individuals.chrome(i,pos)=v+delta;
			else
				delta=v1*(1-pick^((1-pop(1)/pop(2))^2));
				individuals.chrome(i,pos)=v-delta;
			end %�������			
			flag=test(lenchrome,LB,UB,individuals.chrome(i,:));
		end
	end
	ret=individuals.chrome;
end

function res  = SGA_mutation()
	pm = 0.1;%�������
	res = pm;
end

function res  = AGA_mutation(individuals,fmax,favg,index)
	k3=0.1;k4=0.1; 
	f = individuals.fitness(index);
	if f >= favg
        pm = k3*(fmax-f)/(fmax-favg);
    else
        pm = k4;
    end
	res = pm;
end

function res  = IAGA_mutation(individuals,fmax,favg,index)
	pm1=0.1; pm2=0.01;
	f = individuals.fitness(index);
	if f >= favg
        pm = pm1-(pm1-pm2)*(fmax-f)/(fmax-favg);
    else
        pm = pm1;
    end
	res = pm;
end

function res  = HIAGA_mutation(individuals,fmax,favg,index)
	pmmax = 0.1;pmmin = 0.006;beta = 5.512;
	f = individuals.fitness(index);
	alpha = (f - favg)/(fmax-favg);
    if f >= favg
        pm = 4*(pmmax-pmmin)/(exp(2*beta*alpha)+exp(-2*beta*alpha)+2)+pmmin;
    else
        pm = pmmax;
    end
	res = pm;
end

function res  = TIAGA_mutation(individuals,fmax,favg,index,num)
	phi = 0.1; pm2 = 0.01;
	f = individuals.fitness(index);
	alpha = (f - favg)/(fmax-favg);
	pm1 = phi - 0.1/(2+0.8*log10(num));
    if f >= favg
        pm = (pm1+pm2)/2-(pm1-pm2)/2*sin(pi/2*alpha);
    else
        pm = pm1;
    end
	res = pm;
end

