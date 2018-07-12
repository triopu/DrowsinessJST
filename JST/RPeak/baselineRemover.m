function datOut = baselineRemover(datIn)
  [c,info]=fwt(datIn,'db8',10);
  multiplizer=size(c,1)/1024;
  c(1:multiplizer*(2**2))=0;      % remove baseline wander
  datOut=ifwt(c,info);
end