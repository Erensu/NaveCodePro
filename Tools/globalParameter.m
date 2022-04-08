function glv = globalParameter(L,h)
    glv = [];
    glv.g0 = mxGetGravity(L,h);
    glv.wie = 7.2921151467e-5;
    glv.mg = 1.0e-3*glv.g0;         % milli g������λmg
    glv.ug = 1.0e-6*glv.g0;         % micro g������λug
    glv.Re = 6378137;                   %���򳤰���
    glv.f = 1/298.257;                      % flattening �������
    glv.Rp = (1-glv.f)*glv.Re;      % semi-minor axis����̰���
    glv.e = sqrt(2*glv.f-glv.f^2);  %ƫ����
	glv.e2 = glv.e^2; % 1st eccentricity ��һƫ����
    glv.ep = sqrt(glv.Re^2-glv.Rp^2)/glv.Rp; glv.ep2 = glv.ep^2; % 2nd eccentricity�ڶ�ƫ����    
    glv.ppm = 1.0e-6;               % parts per million �����֮
    glv.deg = pi/180;               % arcdeg �Ȼ�Ϊ����
    glv.min = glv.deg/60;           % arcmin ����/��
    glv.sec = glv.min/60;           % arcsec ����/��
    glv.hur = 3600;                 % time hour (1hur=3600second) 1h = 3600s
    glv.dps = pi/180/1;             % arcdeg / second ����/��
    glv.dph = glv.deg/glv.hur;      % arcdeg / hour  ����/Сʱ
    glv.dpss = glv.deg/sqrt(1);     % arcdeg / sqrt(second) ����/������
    glv.dpsh = glv.deg/sqrt(glv.hur);  % arcdeg / sqrt(hour) ����/����Сʱ
    glv.dphpsh = glv.dph/sqrt(glv.hur); % (arcdeg/hour) / sqrt(hour) ����/Сʱ/����Сʱ
    glv.Hz = 1/1;                   % HertzƵ��
    glv.dphpsHz = glv.dph/glv.Hz;   % (arcdeg/hour) / Hz  ����/Сʱ/����
    glv.ugpsHz = glv.ug/sqrt(glv.Hz);  % ug / sqrt(Hz)    ug/���ź���
    glv.ugpsh = glv.ug/sqrt(glv.hur); % ug / sqrt(hour)	ug/����Сʱ
    glv.mpsh = 1/sqrt(glv.hur);     % m / sqrt(hour)  1/����Сʱ
    glv.mpspsh = 1/1/sqrt(glv.hur); % (m/s) / sqrt(hour), 1*mpspsh~=1700*ugpsHz 1/1/����Сʱ = 1/����Сʱ
    glv.ppmpsh = glv.ppm/sqrt(glv.hur); % ppm / sqrt(hour) �����֮/����Сʱ
    glv.mil = 2*pi/6000;            % mil 
    glv.nm = 1853;                  % nautical mile 1����
    glv.kn = glv.nm/glv.hur;        % knot ����/Сʱ
    glv.I33 = eye(3); glv.o33 = zeros(3);
    glv.cs = [                      % coning & sculling compensation coefficients
    [2,    0,    0,    0,    0    ]/3
    [9,    27,   0,    0,    0    ]/20
    [54,   92,   214,  0,    0    ]/105
    [250,  525,  650,  1375, 0    ]/504 
    [2315, 4558, 7296, 7834, 15797]/4620 ];
 glv.csmax = size(glv.cs,1)+1;  % max subsample number
 glv.tscale = 1;  % =1 for second, =60 for minute, =3600 for hour, =24*3600 for day
end