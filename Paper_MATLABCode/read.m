fid = fopen('data.txt');
A = fscanf(fid,'%d,%d,%d,%d',[4,inf])';
fclose(fid);
figure
imdim = 512;
imdimsmall = 128;
img = uint8(zeros(imdim,imdim));

for i = 1:size(A,1)
        currpin = (imdim/512)*A(i,1:2);
        nextpin = (imdim/512)*A(i,3:4);
        
        [x, y, c]=bresenham(currpin(1),currpin(2),nextpin(1),nextpin(2));
        img((x-1)*imdim+y) = img((x-1)*imdim+y) + uint8(c*255);
end
img = 255 - img;
img = imresize(img, [imdimsmall imdimsmall]);
imshow(img);