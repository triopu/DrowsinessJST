clc;
clear;
more off;
warning off;
pkg load io;

fileFeature = {'data30_Detik.xlsx',
               %'data20_Detik.xlsx',
               %'data10_Detik.xlsx'
               };
               
myFolder        = '/home/trio_pu/Desktop/JST/Features';
dataFile        = sprintf('/%s%s','data','30_Detik');
outputFilename  =sprintf('%s/%s_normalisasi',myFolder,dataFile);


for s=1:length(fileFeature)
  allDataArray  =  xlsread(sprintf('%s/%s','/home/trio_pu/Desktop/JST/Features',
                                    fileFeature{s}));
  for n=1:5
    dat=allDataArray(:,n);
    x(n)=length(dat)
    for y=1:x(n)    
      maks(n)=max(dat);
      mini(n)=min(dat);
      normalis(y,n)=(dat(y)-mini(n))/(maks(n)-mini(n))
    end
    y=1
    dat=dat
  end
  xlswrite(outputFilename, normalis, 'All Data', 'A1');
end
