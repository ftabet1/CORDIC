angle_table = [0.7854, 0.463648, 0.244979, 0.124355, 0.0624188, 0.0312398, 0.0156237, 0.00781234]
angle_table_angle = (angle_table*360)/(2*pi);
scale_factor = prod(cos(angle_table));

rotate_rad = (3*pi)/7;
rotate_ang = (rotate_rad*360)/(2*pi);

N = 8

pI = [1, 0];
pR = [1, 0]
pR_temp = [0, 0]
R_Dir = rotate_rad;

for i = 1:N
  pR_temp(1) = pR(1) - sign(R_Dir) * (pR(2)/2^(i-1))
  pR_temp(2) = pR(2) + sign(R_Dir) * (pR(1)/2^(i-1))
  R_Dir += -sign(R_Dir)*angle_table(i);
  pR = pR_temp;
endfor

pR = pR * scale_factor;

angle_rad = acos(dot(pR, pI)/norm(pR)*norm(pI));
angle = (angle_rad*360)/(2*pi);

