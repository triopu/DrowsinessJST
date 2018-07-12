function [LPF,HPF,D,SQ,MW] = filtFunction(ecgData,nData)
  %LPF (1-z^-6)^2/(1-z^-1)^2
  b     = [1 0 0 0 0 0 -2 0 0 0 0 0 1];
  a     = [1 -2 1];
  h_LP  = filter(b,a,[1 zeros(1,12)]);  % impulse response of LPF
  LPF   = conv(ecgData ,h_LP);
  LPF   = LPF (6+[1: nData]);           % cancle delay
  LPF   = LPF/max(abs(LPF));

  %HPF = Allpass-(Lowpass) = z^-16-[(1-z^-32)/(1-z^-1)]
  d     = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
  c     = [1 -1];
  h_HP  = filter(d,c,[1 zeros(1,32)]);    % impulse response of HPF
  HPF   = conv(LPF,h_HP);
  HPF   = HPF(16+[1: nData]);
  HPF   = HPF/max(abs(HPF));

  %Derivative Filter
  h = [-1 -2 0 2 1]/8;
  D = conv (HPF ,h);                     % Apply filter
  D = D(2+[1: nData]);
  D = D/max(abs(D));

  %Squaring
  SQ  = D.^2;
  SQ  = SQ/max(abs(SQ));

  %Moving WIndow Integration
  h     = ones (1 ,31)/31;
  Delay = 15;             % Delay in samples
  MW    = conv (SQ ,h);   % Apply filter
  MW    = MW (15+[1:nData]);
  MW    = MW/ max(abs(MW));
  return;
end
