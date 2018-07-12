function [ecgSignal, time, signalName] = loadECG(fileName)
  rawData   = load(fileName);
  ecgSignal = rawData(:,2);
  time      = rawData(:,1);
end

