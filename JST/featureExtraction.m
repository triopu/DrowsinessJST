clc;
clear;
close all;
more off;
warning off;

pkg load signal;

folderTXT   = '/home/trio_pu/Desktop/JST/Data/';
rrFolder    = '/home/trio_pu/Desktop/JST/RRFeature/';

dirList     = dir(fullfile(folderTXT, '*.txt'));
names       = {dirList.name};
outNames    = {};

for i=1:numel(names)
  name = names{i};
  if ~isequal(name,'.') && ~isequal(name,'..')
    [~,name] = fileparts(names{i});
    outNames{end+1} = name;
    end
end   

for k = 1:length(outNames)
  
  fileTXT = outNames{k};

  rrSave  = fopen(sprintf('%s%s.txt',rrFolder,outNames{k}),'w');
  fprintf('Extracting data %s.txt',outNames{k});

  txt           = sprintf('%s%s.txt',folderTXT,fileTXT);
  
  ecgData       = load(txt);
  ecgRecord     = ecgData(:,2);
  time          = ecgData(:,1);
  samplingFreq  = 250;
 
  [qrsAmplitude,qrsIndex,delay]=panTompkin(ecgRecord,samplingFreq,0);
  

  for i=1:length(qrsIndex)-1
    rrInt(i)  = time(qrsIndex(i+1))-time(qrsIndex(i));
    rrTime(i) = time(qrsIndex(i+1));
    fprintf(rrSave,'%0.4f\t%0.4f\n',rrTime(i),rrInt(i));
  end
  
  fclose(rrSave);
  
  QRS = length(qrsIndex);
  disp(QRS);
  
  figure(k);
  plot(time, -ecgRecord);
  hold on;
  plot(time(qrsIndex),-ecgRecord(qrsIndex),'*');
  %plot(rrTime, rrInt,'*');
  %ylim([0 2]);
  title(fileTXT);
  xlabel('t(s)');
  ylabel('RR-int');
  
  rrInt = [];
  rrTime = [];
end

