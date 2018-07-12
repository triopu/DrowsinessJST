clc;
clear;
close all;
pkg load signal;
pkg load io;
more off;           

dataBase  = '/home/trio_pu/Desktop/JST/Data/';
rrFolder  = '/home/trio_pu/Desktop/JST/RRFeature/';
dirList   = dir(fullfile(dataBase,'*.txt'));
names     = {dirList.name};
outNames  = {};
for i=1:numel(names)
  name = names{i};
  if ~isequal(name,'.') && ~isequal(name,'..')
    [~,name] = fileparts(names{i});
    outNames{end+1} = name;
  end
end

for i=1:length(outNames)
  [ecgData,t,R_loc] = mainFunction(outNames{i},dataBase,0);
  fprintf('R%s: %0.0f\n',outNames{i},length(R_loc));
  rrSave  = fopen(sprintf('%s%s.txt',rrFolder,outNames{i}),'w');
  fprintf('Extracting data %s.txt',outNames{i});
  
  for i=1:length(R_loc)-1
    rrInt(i)  = t(R_loc(i+1))-t(R_loc(i));
    rrTime(i) = t(R_loc(i+1));
    fprintf(rrSave,'%0.4f\t%0.4f\n',rrTime(i),rrInt(i));
  end
  fclose(rrSave);
  rrInt = [];
  rrTime = [];
  %clc;
end