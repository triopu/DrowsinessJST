clc;
clear;
warning off;
more off;
pkg load io;

myFolder = '/home/trio_pu/Desktop/JST/Features';
subFolder = { '30_Detik',
              '20_Detik',
              '10_Detik' };
              
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end

for s = 1:length(subFolder)
  theFolder     = sprintf('%s/%s',myFolder,subFolder{s});
  
  dirList     = dir(fullfile(theFolder, '*.txt'));
  names       = {dirList.name};
  outNames    = {};

  for i=1:numel(names)
    name = names{i};
    if ~isequal(name,'.') && ~isequal(name,'..')
      [~,name] = fileparts(names{i});
      outNames{end+1} = name;
      end
  end   
  
  dataFile      = sprintf('/%s%s','data',subFolder{s});

  folderTXT = sprintf('%s/%s',myFolder,subFolder{s});

  for k = 1 :length(outNames)
    fileTXT = outNames{k};
    fullFileName   = sprintf('%s/%s.txt',folderTXT,fileTXT);
    fprintf(1, 'Now reading %s\n', fullFileName);
    data = load(fullFileName);
    if k == 1
       allDataArray = data;
    else
       allDataArray = [allDataArray; data];
    end
  end
  outputFilename=sprintf('%s/%s',myFolder,dataFile);
  xlswrite(outputFilename, allDataArray, 'All Data', 'A1');
  allDataArray = [];
end

