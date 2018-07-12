warning off;
clear;
clc;
close all;
pkg load ltfat;

[ecgData, time, signalName] = loadECG('/media/trio_pu/Data/Documents/Kuliah Magister/Thesis/RPeak/Database/008.txt');
ecgB  = baselineRemover(ecgData);

plot(ecgData,'r');
hold on;
plot(ecgB,'b');