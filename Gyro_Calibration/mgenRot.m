function mrot=mgenRot(radian,xyz,check)
% 3ά��������ת����,�������Ҿ���x='x',y='y',z='z':check=1��ת��check=2��������.
% ����ԭ�ͣ�mrot=mgenRot(radian,xyz,check)
r=zeros(3,3);

if(check==1)
    switch xyz
        case 'x'
            r=[1 0 0;
             0, cos(radian), -sin(radian);
             0, sin(radian), cos(radian)];
        case 'y'
          r=[cos(radian), 0, sin(radian);
           0,   1,0;
           -sin(radian),0 , cos(radian)];
         case 'z'
          r=[cos(radian), -sin(radian),0;
            sin(radian),cos(radian),0;
            0, 0, 1];
    end
elseif(check==2)
        switch xyz
         case 'x'
            r=[1 0 0;
             0, cos(radian), sin(radian);
             0, -sin(radian), cos(radian)];
        case 'y'
        r=[cos(radian), 0, -sin(radian);
           0,   1,0;
           sin(radian),0 , cos(radian)];
        case 'z'
        r=[cos(radian), sin(radian),0;
            -sin(radian),cos(radian),0;
            0, 0, 1];
    end
end
mrot=r;
return 