function z=snrr(x,y)%��������ȣ�x��ԭʼ�źţ�y��ȥ����ź�
y1=sum(x.^2);
y2=sum((y-x).^2);
z=10*log10((y1/y2));
end
