function flag=test(lenchrome,LB,UB,code)
%���Խ�纯��
%lenchrom input: Ⱦɫ�峤��,Ҳ����һ��Ⱦɫ���ϵĻ������
%bound input :������ȡֵ��Χ
%code input :Ⱦɫ��ı���ֵ
flag=1;
[m,n]=size(code);
for i=1:n         
    if code(i)<LB(i)||code(i)>UB(i)%Խ�磬���±���
        flag=0;
    end
end