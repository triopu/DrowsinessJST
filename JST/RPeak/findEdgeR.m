function [poss_reg,thresh,right,left]=findEdgeR(MW)
  
  %Find the Edge
  max_h     = max(MW);
  thresh    = mean(MW);
  thresh    = thresh*max_h;
  poss_reg  = (MW>thresh);

  left      = find(diff([0 poss_reg])==1);
  right     = find(diff([poss_reg 0])==-1);

  if left(1) < 2
    for n = 1 : length(left)-1
      left(n)   = left(n+1);
      right(n)  = right(n+1);
    end
  end

end