clc;
clear all;

RGBFrame1 = im2double(imread ('Lenna.png'));
RGBFrame2 = im2double(imread('Lenna.png'));

featA = GetFeatures(RGBFrame1);
featB = GetFeatures(RGBFrame2);

%Euclidian Distance

dist = sqrt(sum(sum((featA - featB).^2)))