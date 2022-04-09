function ret = crossover(popsize,individuals,lenchrome,LB,UB,num,flag)
	sumfitness = sum(individuals.fitness);
	fmax = max(individuals.fitness);
    favg = sumfitness/popsize;
    for i=1:popsize %�Ƿ���н�������ɽ�����ʾ�����continue����)
		pick=rand(1,2);%��������[0,1]֮�������
		while prod(pick)==0%prod�����������ˣ������һ��Ϊ0����Ϊ0
			pick=rand(1,2);
		end
		index=ceil(pick.*popsize);%ceil�������ұ�ȡ�����õ����ѡȡ��������ʹ,�˺�����indexΪ�����ţ�Ҳ����Ⱦɫ����
		pick=rand;%���������Ϊ0�Ľ������
		while pick==0
			pick=rand;
		end
		switch(flag)
			case 1 
				pc = SGA_cross();%�򵥽�������
			case 2 
				pc =  AGA_cross(individuals,fmax,favg,index);%����Ӧ��������
			case 3 
				pc = IAGA_cross(individuals,fmax,favg,index);%��������Ӧ��������
			case 4 
				pc = HIAGA_cross(individuals,fmax,favg,index);%��������Ӧ��������
			case 5 
				pc = TIAGA_cross(individuals,fmax,favg,index,num);%��������Ӧ��������	
		end
		if pick > pc        %������ʾ����Ƿ񽻲�
			continue;           %���������ʴ��ڽ�����ʣ���ô������د��ѭ����Ҳ������د�β�����
		end
		flag=0;                 %�Ƿ���н���ı�־λ
		while flag==0           %flag=0����н���
			pick=rand;          %����1�����������������λ�Z
			while pick==0
				pick=rand;
			end
			pos=ceil(pick*lenchrome);%���ѡ�񽻲�λ��
			pick=rand;%�������ӣ��������
			v1=individuals.chrome(index(1),pos);%��ѡ�н��н��������Ⱦɫ���еĵ�һ�����н����λ��
			v2=individuals.chrome(index(2),pos);%��ѡ�н��н��������Ⱦɫ���еĵڶ������н����λ��
			individuals.chrome(index(1),pos)=pick*v2+(1-pick)*v1;    %�м�����
			individuals.chrome(index(2),pos)=pick*v1+(1-pick)*v2;    %�������
			flag1=test(lenchrome,LB,UB,individuals.chrome(index(1),:));%���齻���Ⱦɫ��Ŀ�����
			flag2=test(lenchrome,LB,UB,individuals.chrome(index(2),:));
			if(flag1*flag2==0)
				flag=0;      %��������1��Ⱦɫ�岻���У������½���
			else
				flag=1;   
			end
		end
    end
    ret=individuals.chrome;
end

function res = SGA_cross()
	pc = 0.9;
	res = pc;
end

function res = AGA_cross(individuals,fmax,favg,index)
	k1=0.9;k2=0.6; 
	f = individuals.fitness(index);
    if f(1) >= f(2)
        f_ = f(1);
    else
        f_ = f(2);
    end
    if f_ > favg
		pc = k1*(fmax-f_)/(fmax-favg);
	else
		pc = k2;
    end
	res = pc;
end

function res = IAGA_cross(individuals,fmax,favg,index)
	pc1=0.9;pc2=0.6; 
	f = individuals.fitness(index);
	if f(1) >= f(2)
        f_ = f(1);
    else
        f_ = f(2);
    end
	if f_ > favg
		pc = pc1-(pc1-pc2)*(f_-favg)/(fmax-favg);
	else
		pc = pc1;
	end
	res = pc;
end

function res = HIAGA_cross(individuals,fmax,favg,index)
	pcmax=0.9;pcmin=0.6; beta = 5.512;
	f = individuals.fitness(index);
	if f(1) >= f(2)
        f_ = f(1);
    else
        f_ = f(2);
    end
	alpha = (f_ - favg)/(fmax-favg);
	if f_ > favg
		pc = 4*(pcmax-pcmin)/(exp(2*beta*alpha)+exp(-2*beta*alpha)+2)+pcmin;
	else
		pc = pcmax;
	end
	res = pc;
end

function res  = TIAGA_cross(individuals,fmax,favg,index,num)
	phi = 0.9; pc2 = 0.6;
	f = individuals.fitness(index);
	if f(1) >= f(2)
        f_ = f(1);
    else
        f_ = f(2);
    end
	alpha = (f_ - favg)/(fmax-favg);
	pc1 = phi + 1/(2+log10(num));
    if f >= favg
        pc = (pc1+pc2)/2-(pc1-pc2)/2*sin(pi/2*alpha);
    else
        pc = pc1;
    end
	res = pc;
end