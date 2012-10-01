
function [theta] = RadonRotate(refImage, receivedImage)

% Only pay attention to 0 to 180 degrees of FFT
thetas = linspace(0, 180, 180);

F1 = abs(fft(radon(refImage, thetas)));
F2 = abs(fft(radon(receivedImage, thetas)));

correlation = sum(fft2(F1) .* fft2(F2));
peaks = real(ifft(correlation));
theta = max(peaks);