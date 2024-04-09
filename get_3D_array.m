clear;clc;close all;

VIDEO = zeros(512,512,2000,'int16');

for i = 1:2000
    
    filename = ['raw',sprintf('%04d',i-1),'.tif'];
    ad = fullfile(pwd,'images',filename);
    obj = Tiff(ad,'r');
    c_img = read(obj);
    VIDEO(:,:,i) = c_img;
    
    i
end