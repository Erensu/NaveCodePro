function res=select(popsize,individuals,sumfitness,flag)
	switch(flag)
		case 1 
			ret = Roulette_select(popsize,individuals,sumfitness);%���̶Զķ�
		case 2  
			ret = Truncation_select(popsize,individuals,sumfitness);%ֱ�ӽضϷ�
		case 3 
			ret = Modified_Roulette_select(popsize,individuals,sumfitness);%���̶ĸĽ���
	end
	res = ret;
end

function ret = Roulette_select(popsize,individuals,sumfitness)
	index=[];
    sumf=individuals.fitness./sumfitness;%������Ӧ�ȱ���
	for i=1:popsize   
		pick=rand;%����һ����Ϊ0���������
		while pick==0 
			pick=rand;
		end
		for j=1:popsize
			pick=pick-sumf(j);%���������С�ڸ����������ʱ��ѡ��������壬Ȼ�������һ�ζԶ�
			if pick <= 0 
                index = [index j];
				break;
			end
		end
	end
	individuals.chrome=individuals.chrome(index,:);
	individuals.fitness=individuals.fitness(index);
	ret=individuals;%ѡ�����������и���
end

function ret = Truncation_select(popsize,individuals)
	fitness = sort(individuals.fitness,'descend');%������
	individuals.fitness(4*popsize/5+1:popsize) = fitness(1:popsize/5);
	individuals.chrome(4*popsize/5+1:popsize,:) = individuals.chrome(1:popsize/5,:);
	ret=individuals;
end

function ret = Modified_Roulette_select(individuals,sumfitness)%�ο����ף������С����ڸĽ��Ŵ��㷨��������Ա궨������
	for j = 1: popsize/2
		pick = ceil(rand*sumfitness);
		i=1;
		while sumf < pick
			i=i+1;
			sumf = individuals.fitness(i);
			
		end	
		result(j,:) = individuals.chrome(i,:);
		index = [index,i];
		for k=1:popsize
			for m = 1:length(index)
				if k~=index(m)
					sumfitness = individuals.fitness(k);
				end
			end
		end
	end
	for k=1:popsize
			for m = 1:length(index)
				if k~=index(m)
					j=1;
					not_result(j,:) = individuals.chrome(k,:);
					j=j+1;
				end
			end
		end
	ret = result;ret2 = not_result;
end
