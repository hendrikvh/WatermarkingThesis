clc

I = imread('Lenna.png');

scale = 0.6;
J = imresize(I,scale);

theta = 50;
K = imrotate(J,theta);
figure, imshow(K)

input_points = [100  200; 200 400];
base_points = [100  400; 100 200];

cpselect(K,I,input_points,base_points);

t = cp2tform(input_points,base_points,'nonreflective similarity');

                         
ss = t.tdata.Tinv(2,1);
sc = t.tdata.Tinv(1,1);
scale_recovered = sqrt(ss*ss + sc*sc)
theta_recovered = atan2(ss,sc)*180/pi