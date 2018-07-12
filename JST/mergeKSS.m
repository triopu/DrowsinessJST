clc;
clear;
warning off;
more off;
pkg load io;

folderFeature = '/home/trio_pu/Desktop/JST/Features';
fileFeature   = {'data30_Detik',
                 'data20_Detik',
                 'data10_Detik'};
             
file          = sprintf('%s/%s_normalisasi.xlsx',folderFeature,fileFeature{3});
data          = xlsread(file);
data(:,6)    = 0;

kssFile       = sprintf('%s/%s',folderFeature,'KSS.xlsx');
dataKSS       = xlsread(kssFile);

a             = 1;
b             = 10;

for n = 1:8
  data(a:b,6)  = dataKSS(n,1);
  a             = a+10;
  b             = b+10;
end

outputFilename=sprintf('%s/complete%s',folderFeature, fileFeature{3});
xlswrite(outputFilename, data, 'All Data', 'A1');

