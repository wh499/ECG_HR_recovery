
%Array=readtable('vivian running (wo b.e.).csv');
%Array=readtable('vivian running (b.e.).csv');
%Array=readtable('sara running (w b.e.).csv');
Array=readtable('vivian_nb.csv');

time = Array{:, 1};
x = Array{:, 3};

figure;
subplot(3, 1, 1);
plot(x)

invert=false;

if(invert)
    x=(-1).*x;
end

Fs= 1000;
%% DSP 
fc = 0.5;     % Cutoff frequency to remove slow drift (Hz)



% 1st-order Butterworth high-pass filter
[b,a] = butter(1, fc/(Fs/2), 'high');
% Apply zero-phase filtering to avoid distortion
x_HPF= filtfilt(b, a, x);

% Plot to compare
subplot(3, 1, 2);
plot(x); hold on;
xlabel('Time (s)'); ylabel('Voltage (s)');
plot(x_HPF);
legend('Original','After DSP');
xlabel('Time (s)'); ylabel('Voltage (s)');
hold off;
    
%Bandpass filter (5–15 Hz)
bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
                    'HalfPowerFrequency1',5, ...
                    'HalfPowerFrequency2',15, ...
                    'SampleRate',Fs);
x_band = filtfilt(bpFilt, x);

x_final=x_band;

%x_final = x_final.^3;
x_final(x_final > 10) = 10 ;
%% findpeaks


[pks,locs] = findpeaks(x_final,Fs,"MinPeakDistance",0.4,"MinPeakProminence",0.5*mad(x_final),"MaxPeakWidth",0.15,"Annotate","peaks");

win = 0.4*Fs;
baseline = movmedian(x_final, win);
noise = movmad(x_final, win);
dynamicThresh = baseline + 2.5*noise;

keep = pks > dynamicThresh(round(locs*Fs));
pks = pks(keep);
locs = locs(keep);

figure;

plot(time/1000, x_final,locs,pks,'o');hold on;
plot(time/1000, dynamicThresh);
% TODO: plot labelling
% TODO: tweak constaints for better peak finding. maybe have the height etc. come from baseline?

%%
beat_length = diff(locs); %heart beat length in seconds
HR = 60./beat_length;

HR(HR > 150) = HR(HR > 150) /3 ;
HR(HR < 70) = HR(HR < 70) *2 ;
HR(HR < 80) = HR(HR < 80) *2 ;
HR(HR < 70) = HR(HR < 70) *2 ;
HR(HR < 70) = HR(HR < 70) *2 ;

%TODO: find outliers and replace manually? 

figure;
subplot(3, 1, 1);
plot(smooth(beat_length));
title("beat length");
xlabel('Time (s)'); ylabel('Beat length (s)');
subplot(3, 1, 2);
plot(smooth(HR));
title("Instantaneous HR");
xlabel('Time (s)'); ylabel('HR (beats/min)');
%subplot(3, 1, 3);
%plot(medfilt1(HR)(150:300));
%title("1st order moving average");

%moving average filter 
%heart rate, beats/min

%%
x= locs(2:end);
y= HR;

% Fit model: a*exp(b*x) + c  (b should be negative for decay)
% Custom exponential decay model
ft = fittype('A*exp(-k*x) + C', ...
        'independent', 'x', ...
        'coefficients', {'A','k','C'});

% Set starting guesses 
opts = fitoptions(ft);
A0 = max(y) - min(y);    % amplitude guess
C0 = min(y);             % baseline guess
k0 = 0;  % slow-ish decay guess
 
opts.StartPoint = [A0, k0, C0];

% Fit
[curve, gof] = fit(x, y, ft, opts);

% Display
disp(curve)

% Plot
figure;
plot(curve, x, y);
title('Custom Exponential Decay Fit');
xlabel('Time (s)'); ylabel('HR (beats/min)');
% Extract parameters
A = curve.A;
k = curve.k;
C = curve.C;

% Compute tau for reference (optional)
tau = 1/k;

% Create equation string
eqnStr = sprintf('y = %.3f e^{-%.3f x} + %.3f\n\\tau = %.3f', A, k, C, tau);

% Add text to plot (adjust position as needed)
xPos = min(x) + 0.05*(max(x)-min(x));
yPos = max(y) - 0.1*(max(y)-min(y));
text(xPos, yPos, eqnStr, 'FontSize', 12, 'BackgroundColor', 'w');
r2= gof.rsquare;
%%
%print(gof);
%average HR, decay rate (normalized by baseline hr?), maybe HRV: 
%boxplot and t test? f test?



