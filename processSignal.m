function results = processSignal(data)
    %Include baseline???

%no plotting, just output 
%time = data{:, 1};
%x = data{:, 3};

time = data{20000:end, 1};
x = data{20000:end, 3};

%figure;
%plot(x)

Fs= 1000;
fc = 0.5;     % Cutoff frequency to remove slow drift (Hz)
%Bandpass filter around QRS (5–15 Hz)
bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
                    'HalfPowerFrequency1',6, ...
                    'HalfPowerFrequency2',12, ...
                    'SampleRate',Fs);
x_band = filtfilt(bpFilt, x);

x_final=x_band;

x_final = x_final;
x_final(x_final > 10) = 10 ;
%% findpeaks


[pks,locs] = findpeaks(x_final,Fs,"MinPeakDistance",0.4,"MinPeakProminence",0.5*mad(x_final),"MaxPeakWidth",0.2,"Annotate","peaks");

win = 0.4*Fs;
baseline = movmedian(x_final, win);
noise = movmad(x_final, win);
dynamicThresh = baseline + noise;
keep = pks > dynamicThresh(round(locs*Fs));
pks = pks(keep);
locs = locs(keep);

%figure;

plot(time/1000, x_final,locs,pks,'o');hold on;
plot(time/1000, dynamicThresh);hold off;
% TODO: plot labelling
% TODO: tweak constaints for better peak finding. maybe have the height etc. come from baseline?

%%
beat_length = diff(locs); %heart beat length in seconds
HR = 60./beat_length;

HR(HR < 70) = HR(HR < 70) *2 ;
HR(HR < 80) = HR(HR < 80) *2 ;
HR(HR < 70) = HR(HR < 70) *2 ;
HR(HR < 70) = HR(HR < 70) *2 ;
HR(HR > 150) = HR(HR > 150) /2 ;

%TODO: find outliers and replace manually? 


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

% Set starting guesses (important!)
opts = fitoptions(ft);
A0 = max(y) - min(y);    % amplitude guess
C0 = min(y);             % baseline guess
k0 = 1 / (max(x)-min(x));  % slow-ish decay guess

opts.StartPoint = [A0, k0, C0];

% Fit
[curve, gof] = fit(x, y, ft, opts);

% Display
disp(curve)


title('Custom Exponential Decay Fit');
xlabel('Time (s)'); ylabel('HR (beats/min)');
% Extract parameters
A = curve.A;
k = curve.k;
C = curve.C;

% Compute tau for reference (optional)
tau = 1/k;


    %results.rPeakLocations  = locs;
    %results.instantaneousHR = HR;       
    %results.avgHR           = avgHR;
    %gof
    results.decayRate       = tau; 
    results.A = A;
    results.k = k;
    results.C = C;
    

end