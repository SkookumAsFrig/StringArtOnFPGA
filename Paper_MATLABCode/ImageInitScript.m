clc
clear all
close all
img = imread('ada.png');
imgr = imresize(img,[512 512]);
figure
imgr = 1*imgr;
imshow(imgr);
img2 = 255 - imgr;
figure
imshow(img2);
file = fopen('ada.txt','w');
img1 = img2(:,:,1);
fprintf(file,'%x\t',img1);
fclose(file);
