function [signalName, qrs_amp, qrs_ind] = RPeakComparison(fid,fileName, thePath, folder, n, fig)
  close all;
  path        = sprintf('%s/Database/%s/',thePath,folder);
  pathSave    = sprintf('%s/SaveData/%s/',thePath,folder);

  dataFile    = sprintf('%s%s%s',path,fileName,'.mat');
  fileInfo    = sprintf('%s%s%s',path,fileName ,'.info');
  [freq,ecgData,t,signalName]  = loadECG(dataFile,fileInfo,n);
  nData                   = length(ecgData);
  nSam                    = 1000/freq;

  %Make Base Plot
  xBase         = 0: t(nData);
  yBase         = zeros(1,t(nData)+1);
  
  [p,s,mu] = polyfit((1:numel(ecgData)),ecgData,6);
  f_y = polyval(p,(1:numel(ecgData)),[],mu);
    
  ecgData = ecgData - f_y;
  Fs          = freq;
  X           = ecgData;
  
  qrs_amp = {};
  qrs_ind = {};

  first_period = round(1.0*Fs);                                                   % 1 s period for initializing

  filter_parameter = 16;                                                          % As per FD52
  parameter = 8;                                                                  % As per FD52
  successive_value_count = fix(0.01*Fs);                                          % FD5x specifies a successive count of 2 samples at 200 Hz
                                                                                  % This means the slope needs to be above the threshold for 10 ms 
  ignore_count = fix(0.2*Fs);                                                     % Detection ignore period (200 ms or physiological constraint)

  ecg_dim = size(X, 2);
  ecg_len = size(X, 1);

  Ts = (0:ecg_len-1)/Fs;

  figure(100);

  ax1 = subplot(4,1,1);
  plot( Ts, X );
  title('Original signal');
  xlabel('Time [s]');

  %% Lowpass filter (4th-order Butterworth, Fc = 100 Hz)
  [b, a] = butter(4, 100/(Fs/2));
  X1 = filtfilt(b, a, X);

  ax2 = subplot(4,1,2);
  plot( Ts, X1 );
  title('Lowpass-filtered signal (4th-order Butterworth, Fc = 100 Hz)');
  xlabel('Time [s]');

  %% Bandpass filter (50 Hz band reject)
  % Inspired by http://dsp.stackexchange.com/a/1090
  freqRatio = 50/(Fs/2);

  notchWidth = 0.1;

  notchZeros = [exp( 1j*pi*freqRatio ), exp( -1j*pi*freqRatio )];

  notchPoles = (1-notchWidth) * notchZeros;

  b = poly(notchZeros);
  a = poly(notchPoles);

  X1 = filtfilt(b, a, X1);

  ax3 = subplot(4,1,3);
  plot( Ts, X1 );
  title('Notch-filtered signal (Fc = 50 Hz)');
  xlabel('Time [s]');

  %% Derivative H(z) = (1/8)*(-2z^-2 - z^-11 + z^1 + 2z^2)
  h = [2 1 0 -1 -2]';
  X2 = [];
  for kk=1:ecg_dim,
      X2 = [X2 conv(X1(:, kk), h)];
  end
  X2 = X2(3:end-2, :);

  ax4 = subplot(4,1,4);
  plot( Ts, X2 );
  title('Derivative filter output');
  xlabel('Time [s]');

  linkaxes([ax1, ax2, ax3, ax4], 'xy');

  %% Maximum slope calculation (FD5x)

  % Iterate on all leads
  for kk=1:ecg_dim,

      %% Initial run
      if kk==1,                                                                   % Reset plot buffers on 1st lead only
          onset_ind_buf = [];
          onset_buf = [];
          slope_thresh_buf = [];
          maxi_buf = [];
          r_amp_buf = [];
          r_ind_buf = [];
      end
      
      r_amp = [];
      r_ind = [];
      
      successive_count = 0;
      
      slope = X2(:, kk);                                                          % Slope of signal
      signalpf = X1(:, kk);                                                       % Original signal, post-filtered
      signal = X(:, kk);                                                          % Original signal
      
      % Initial maximum slope
      [~, II_pos] = max(slope(1:first_period));                                   % First maxi is the maximum earliest slope value
      [~, II_neg] = min(slope(1:first_period));
      
      II = min(II_pos, II_neg);
      
      % First onset
      height_at_onset = signalpf(II);                                             % Take signal value at II
      
      % First peak
      peak = 0;
      I = II;
      
      while ~peak,                                                                % Find peak by checking diff
          peak = (signalpf(I+1) - signalpf(I)) < 0;
          I = I+1;
      end
      
      I = I-1;
      height_of_R_point = signalpf(I);                                            % Take signal value at I
      
      % Initial maxi
      maxi = abs(slope(II));                                                      % Initialize maxi
      
      % Initial threshold
      slope_threshold = (parameter/16)*maxi;
      
      % Store data in buffer
      if kk==1,
          onset_ind_buf = [onset_ind_buf II];
          onset_buf = [onset_buf height_at_onset];
          slope_thresh_buf = [slope_thresh_buf slope_threshold];
          maxi_buf = [maxi_buf maxi];
          r_amp_buf = [r_amp_buf signal(I)];
          r_ind_buf = [r_ind_buf I];
      end
      
      r_amp = [r_amp signal(I)];
      r_ind = [r_ind I];
      
      %% Iteration
      ll = first_period+1;
      
      ignore = 0;
      
      while ll<=size(slope,1),
          
          larger_than_slope_threshold = (abs(slope(ll)) > slope_threshold);       % Evaluate condition for slope
          
          if ignore,
              ignore = rem(ignore+1, ignore_count);                               % Ignore any detection within the count range
          end
              
          if larger_than_slope_threshold,                                         % If condition is true
              if ~ignore,                                                         % If not ignoring detection
                  successive_count = successive_count + 1;                        % Consider candidate, and start count
              end
          else
              successive_count = 0;
          end
          
          if successive_count == successive_value_count,                          % If candidate fulfills count value
              
              height_at_onset = signalpf(ll);                                     % Update onset height
              
              peak = 0;
              l = ll;

              while ~peak,                                                        % Detect R peak
                  peak = (signalpf(l+1) - signalpf(l)) < 0;
                  l = l+1;
                  if l==size(slope,1),
                      l = l+1;
                      peak = 1;
                  end
              end

              l = l-1;
              height_of_R_point = signalpf(l);                                    % Update R peak
              
              first_max = abs(height_of_R_point - height_at_onset);
              
              maxi = ( (first_max - maxi)/filter_parameter ) + maxi;              % Update maxi
              
              slope_threshold = (parameter/16)*maxi;                              % Update threshold
              
              successive_count = 0;
              ignore = 1;
              
              if kk==1,
                  onset_ind_buf = [onset_ind_buf ll];
                  onset_buf = [onset_buf height_at_onset];
                  slope_thresh_buf = [slope_thresh_buf slope_threshold];
                  maxi_buf = [maxi_buf maxi];
                  r_amp_buf = [r_amp_buf signal(l)];
                  r_ind_buf = [r_ind_buf l];                
              end
              
              r_amp = [r_amp signal(l)];
              r_ind = [r_ind l];
              
          end
          
          ll = ll+1;
          
      end
      
      qrs_amp{kk} = r_amp';
      qrs_ind{kk} = r_ind';

  end

  figure(101);

  ax11 = subplot(2,1,1);
  hold on;
  plot( Ts, X(:,1), 'LineWidth', 1.5 );
  title('Algorithm output');
  xlabel('Time [s]');

  plot(onset_ind_buf/Fs, onset_buf, 'bx', 'LineWidth', 2);
  plot(r_ind_buf/Fs, r_amp_buf, 'ro', 'LineWidth', 2);
  legend('Signal', 'Estimated onset', 'Estimated R peak', 'Location', 'best');

  ax22 = subplot(2,1,2);
  hold on;
  plot( Ts, X2(:,1), 'LineWidth', 1.5);
  title('Derivator output');
  xlabel('Time [s]');

  plot(r_ind_buf/Fs, slope_thresh_buf, 'ko--', 'LineWidth', 1.2);
  plot(r_ind_buf/Fs, maxi_buf, 'ro--', 'LineWidth', 1.2);
  legend('Derivator output', 'Slope threshold', 'Slope maximum', 'Location', 'best');

  linkaxes([ax11, ax22], 'x');
end
