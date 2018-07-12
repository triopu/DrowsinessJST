clear;
clc;
close all;
warning off;
more off;
pkg load io;

tic
addpath('/home/trio_pu/Desktop/AD8232/JST/Klasifikasi Kantuk/AlgoritmakMeans');
addpath('/home/trio_pu/Desktop/AD8232/JST/Klasifikasi Kantuk/JSTRBF');
addpath('/home/trio_pu/Desktop/AD8232/JST/Features');

akurat=[];
spesifitas=[];
sensitivitas=[];
akurasi=[];

%membuka data
theData = xlsread('/home/trio_pu/Desktop/JST/Features/completedata10_Detik.xlsx');
indices = crossvalind('Kfold',432,5);
for i = 1:5
  test    = (indices == i); 
  train   = ~test;
  data    = theData(train,:);
  dattest = theData(test,:);
  
  X1 = data(:,1);
  X2 = data(:,2);
  X3 = data(:,3);
  X4 = data(:,4);
  X5 = data(:,5);
  X=[X1 X2 X3 X4 X5];
  y= data(:,6);

  %menghitung jumlah data
  m=size(X,1);

  %============Training JST RBF============%
  disp('1.menTraining JST RBF untuk klasifikasi tingkat kantuk...')

  %mentraining JST RBF dengan jumlah pusat n per tingkat kantuk
  [pusat,betas,Theta]= trainJSTRBF(X, y, 10, false);
  bnr=0;
  jmlsalah=[];

  %akurasi training
  for i=1:m
    scores=testingJSTRBF(pusat, betas, Theta, X(i,:));
    [maxScore,tingkat]=max(scores);
    if (tingkat==y(i))%memvalidasi
      bnr=bnr+1;
    else
      jmlsalah=[jmlsalah;X(i,:)];
    end
  end
  
  %======Plotting kontur

  %====== mengukur akurasi
  disp('Mengukur akaurasi JST...');

  benar1=0;
  benar2=0;
  salah=[];

  % dattest = datatest;
  x1 = dattest(:,1);
  x2 = dattest(:,2);
  x3 = dattest(:,3);
  x4 = dattest(:,4);
  x5 = dattest(:,5);
  x=[x1 x2 x3 x4 x5];
  Y= dattest(:,6);


  n=size(x,1);
  tingkat_kantuk1=length(find(dattest(:,6)==1));
  tingkat_kantuk2=length(find(dattest(:,6)==2));
  for i=1:n
    scores=testingJSTRBF(pusat, betas, Theta, x(i,:));
    [maxScore,tingkat]=max(scores);
    if (tingkat==Y(i)) && tingkat==1%memvalidasi
      benar1=benar1+1;
    elseif(tingkat==Y(i)) && tingkat==2 %memvalidas
      benar2=benar2+1;
    else
      salah=[salah;x(i,:)];
    end
  end
  akurat=[akurat;bnr/m*100];
  spesifitas=[spesifitas;benar1/tingkat_kantuk1*100];
  sensitivitas=[sensitivitas;(benar2/tingkat_kantuk2)*100];
  akurasi=[akurasi;(benar1+benar2)/n*100];
end

fprintf('Akurasi training JST  : %f \n',mean(akurat));
fprintf('Spesifitas     : %f \n',mean(spesifitas));
fprintf('Sensitivitas   : %f \n',mean(sensitivitas));
fprintf('Akurasi JST pengklasifikasi : %f \n',mean(akurasi));
toc
if exist('OCTAVE_VERSION') fflush(stdout);end;