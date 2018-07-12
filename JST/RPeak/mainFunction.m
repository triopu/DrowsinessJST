function [ecgData1, t, R_loc] = mainFunction(fileName, thePath, varbose)
  path        = sprintf('%s',thePath);
  dataFile    = sprintf('%s%s%s',path,fileName,'.txt');
  
  [ecgData,t]             = loadECG(dataFile);
  nData                   = length(ecgData);
  
  ecgData  = ecgData';
  ecgData1 = ecgData;
  t       = t';
  
  %Make Base Plot
  xBase         = 0: t(nData);
  yBase         = zeros(1,t(nData)+1);
  
  N = 1:numel(ecgData);
  
  
  [p,s,mu] = polyfit((1:numel(ecgData)),ecgData,6);
  f_y = polyval(p,(1:numel(ecgData)),[],mu);
    
  ecgData = ecgData - f_y;
  %ecgData    = baselineRemover(ecgData);

  [LPF,HPF,D,SQ,MW]     = filtFunction(ecgData,nData);
  [poss_reg,thresh,right,left] = findEdgeR(MW);
  
  aa =  1.5;
  bb =  4.5;
  cc =  -2.2;
  dd =  2.2;
  
  if varbose == 1
    figure(1,'DefaultAxesFontSize',28,'DefaultAxesFontName','Times New Roman','DefaultLineLineWidth',2);
    plot1 = plot(t, ecgData,'k');
    xlim([aa bb]);
    ylim([cc dd]);
        set(gca, 'ytick', [-1.5 -1.0 -0.5 0 0.5 1 1.5]) 
    %xlabel('Time (s)');
    %ylabel('Amplitude (mV)');
    title('ECG Signal');
    grid off;

    figure(2,'DefaultAxesFontSize',28,'DefaultAxesFontName','Times New Roman','DefaultLineLineWidth',2);
    plot1 = plot(t, LPF,'k');
    xlim([aa bb]);
    ylim([cc dd]);
        set(gca, 'ytick', [-1.5 -1.0 -0.5 0 0.5 1 1.5]) 
    %xlabel('Time (s)');
    %ylabel('Amplitude (mV)');
    title('LPF');
    grid off;
    
    figure(3,'DefaultAxesFontSize',28,'DefaultAxesFontName','Times New Roman','DefaultLineLineWidth',2);
    plot1 = plot(t, HPF,'k');
    xlim([aa bb]);
    ylim([cc dd]);
        set(gca, 'ytick', [-1.5 -1.0 -0.5 0 0.5 1 1.5]) 
    %xlabel('Time (s)');
    %ylabel('Amplitude (mV)');
    title('HPF');
    grid off;
    
    figure(4,'DefaultAxesFontSize',28,'DefaultAxesFontName','Times New Roman','DefaultLineLineWidth',2);
    plot1 = plot(t, D,'k');
    xlim([aa bb]);
    ylim([cc dd]);
        set(gca, 'ytick', [-1.5 -1.0 -0.5 0 0.5 1 1.5]) 
    %xlabel('Time (s)');
    %ylabel('Amplitude (mV)');
    title('D');
    grid off;
    
    figure(5,'DefaultAxesFontSize',28,'DefaultAxesFontName','Times New Roman','DefaultLineLineWidth',2);
    plot1 = plot(t, SQ,'k');
    xlim([aa bb]);
    ylim([cc dd]);
        set(gca, 'ytick', [-1.5 -1.0 -0.5 0 0.5 1 1.5]) 
    %xlabel('Time (s)');
    %ylabel('Amplitude (mV)');
    title('SQ');
    grid off;
    
    figure(6,'DefaultAxesFontSize',28,'DefaultAxesFontName','Times New Roman','DefaultLineLineWidth',2);
    plot1 = plot(t, MW,'k');
    hold on;
    thBase(:,1:length(t)) = thresh;
    hold on;
    plot2 = plot(t,thBase,'--k');
    hold on;
    for i = 1:10
      plot3 = plot([t(right(i)) t(right(i))],[-0.3 0.5],'-.k');
      hold on;
      plot4 = plot([t(left(i)) t(left(i))],[-0.3 0.5],'-.k');
      hold on;
    end
    xlim([aa bb]);
    ylim([-0.5 dd]);
        set(gca, 'ytick', [-1.5 -1.0 -0.5 0 0.5 1 1.5]) 
    %xlabel('Time (s)');
    %ylabel('Amplitude (mV)');
    title('MW');
    grid off;
    
    figure(7,'DefaultAxesFontSize',28,'DefaultAxesFontName','Times New Roman','DefaultLineLineWidth',2);
    plot1 = plot(t, ecgData1,'k');
    xlim([aa bb]);
    ylim([0 5]);
        set(gca, 'ytick', [-1.5 -1.0 -0.5 0 0.5 1 1.5]) 
    %xlabel('Time (s)');
    %ylabel('Amplitude (mV)');
    title('Original');
    grid off;
  end

  ecgFilt = ecgData;

  for i=1:length(left)-1
    [R_value(i) R_loc(i)] = max(ecgData(left(i):right(i)));
    R_loc(i) = R_loc(i)-1+left(i);
  end
end