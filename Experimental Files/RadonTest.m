rotatedLena = testImage;
origLena = refImage;

thetas = linspace(0, 180, 180);


R1 = real(radon(rotatedLena));
R2 = real(radon(origLena));
mesh(R1);
figure
mesh (R2);
