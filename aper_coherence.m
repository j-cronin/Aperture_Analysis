%% aper_coherence determines the time lagged coherence between the stimulations and the hand motion
addpath('C:\Users\jcronin\Box Sync\Code\Matlab\Numerical_Differentiation');

load('C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\Matlab, Aperture\Aperture_ecb43e-13');
startTime = 19;
endTime = 138;
Aper_SamplingRate = Aper.info.SamplingRateHz;
Aper_timeStep = 1/Aper_SamplingRate;
startSampAper = floor(startTime*Aper_SamplingRate);
endSampAper = floor(endTime*Aper_SamplingRate);

data = Aper.data(startSampAper:endSampAper,1);
Aper_time = (0:length(Aper.data(:,1))-1)/Aper_SamplingRate;

%% Uncomment the smoothing function to use
% This 'smoothing' function determines the moments in the dataglove signal
% when there is a significant change in the hand's motion

% 2nd derivative
% kriging
% curvature
% bin into stim and no stim
% numerical differentiation of noisy, nonsmooth data
iter = 40;
% alph = 1e-1;
alph = 100;
u0 = [];
scale = 'large';
ep = 1e-8;
dx = [];
plotflag = 0;
diagflag = 0;
[u, relativeChange, gradientNorm] = TVRegDiff( data, iter, alph, u0, scale, ep, dx, plotflag, diagflag );

%% Plot the resulting points of significant motion change to check
figure
[x,y]=find(diff(abs(u(:,5)))>1.0*10^-6);

% plot(Aper_time(startSampAper:endSampAper), data);
% hold on
% scatter(x/Aper_SamplingRate, data(x+2) ,'filled', 'r')

plot(data);
hold on
scatter(x, data(x+1) ,3,'filled', 'r')

