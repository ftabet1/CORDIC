clear all;
angle_j = [1, 2, 3, 4, 5, 6, 7, 8];
angle_ptwo = 2.^-(angle_j);
angle_table = atanh(angle_ptwo);
scale_factor_h = 1/0.82816;
angles = linspace(0, 1.1, 5);

rotate_rad = angles(5);

N = 8

pR_expect = [cosh(rotate_rad), sinh(rotate_rad)];
pI = [1, 0];
pR = [1, 0]
pR_temp = [0, 0]
R_Dir = rotate_rad;

for i = 1:N
  pR_temp(1) = pR(1) + sign(R_Dir) * (pR(2)/2^(i))
  pR_temp(2) = pR(2) + sign(R_Dir) * (pR(1)/2^(i))
  R_Dir += -sign(R_Dir)*angle_table(i);
  pR = pR_temp;
endfor

pR = pR * scale_factor_h;
pR_so = [pR(1)/pR_expect(2), pR(2)/pR_expect(1)];

fs = 8000
t = 0:2*pi/fs:2*pi;
t1 = -(2*pi):2*pi/fs:2*pi;

figure (1);
subplot(1,2,1)
plot(t, sin(t));
hold on;
plot(t, cos(t));
hold on;
subplot(1,2,2)
plot(t1, atanh(t1));
hold on;
plot(t1, cosh(t1));

angle_rad = acos(dot(pR, pI)/norm(pR)*norm(pI));
angle = (angle_rad*360)/(2*pi);

