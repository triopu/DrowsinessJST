%%%%======JST RBF Untuk Klasifikasi tingkat kantuk======%%%%
clear;clc; %hapus semua variabel dan command window

addpath('AlgoritmakMeans');
addpath('JSTRBF');

%membuka data
load normaltarget.mat
data = normalis;
X1 = data(:,3);
X2 = data(:,4);
X3 = data(:,8);
X4 = data(:,10);
X=[X1 X2 X3 X4];
y= data(:,13);

%menghitung jumlah data
m=size(X,1);

%============Training JST RBF============%
disp('1.menTraining JST RBF untuk klasifikasi tingkat kantuk...')

%mentraining JST RBF dengan jumlah pusat n per tingkat kantuk
[pusat,betas,Theta]= trainJSTRBF(X, y, 74, true);

%======Plotting kontur

%====== mengukur akurasi
disp('Mengukur akaurasi JST...');

jmlbenar=0;
salah=[];

for i=1:m
    scores=testingJSTRBF(pusat, betas, Theta, X(i,:));
    [maxScore,tingkat]=max(scores);
    if (tingkat==y(i))%memvalidasi
        jmlbenar=jmlbenar+1;
    else
        salah=[salah;X(i,:)];
    end
end
akurasi=jmlbenar/m*100;
fprintf('Akurasi JST pengklasifikasi :  %d / %d, %f%%\n',jmlbenar,m, akurasi)
if exist('OCTAVE_VERSION') fflush(stdout);end;
        