%function [] = analyze_Aper_data()
calculateChanceAccuracy = 0;
fileName = 'C:\Users\jcronin\Data\Subjects\ecb43e\d7\MIT_Glove_ecb43e\Matlab, MIT glove\MIT_Glove_ecb43e-10';
load(fileName);

SamplingRate = Stim.info.SamplingRateHz;

Stim_timeStep = 1/SamplingRate;
Stim_time = 0:Stim_timeStep:Stim_timeStep*length(Stim.data(:,1))-Stim_timeStep;
% figure(2)
% subplot(6,1,1)
% plot(Stim_time, Stim.data(:,1))
% ylabel('Stim 0')
% subplot(6,1,2)
% plot(Stim_time, Stim.data(:,2))
% ylabel('Stim 1')
% subplot(6,1,3)
% plot(Stim_time, Stim.data(:,3))
% ylabel('Stim State used')
% subplot(6,1,4)
% plot(Stim_time, Stim.data(:,4))
% ylabel('Stim Wave to Use')
% subplot(6,1,5)
% plot(Stim_time, Stim.data(:,5))
% ylabel('Stim Wave Used (post IZ2)')
% subplot(6,1,6)
% plot(Stim_time, Stim.data(:,6))
% ylabel('Counter')

% figure(3)
% plot(Stim.data(:,1))
% title('Stim 0');
% 
% figure(4)
% plot(Stim.data(:,2))
% title('Stim 1');
% 
% figure(5)
% plot(Stim.data(:,5))
% title('Stim Wave Used (post IZ2)');
% 
% figure(6)
% plot(Stim.data(:,4))
% title('Stim Wave to Use');
%end

%% Stim 0 calculations
% amp = max(Stim.data(:,1));
% neg_amp = min(Stim.data(:,1));
%phase_duration_pos =


%% Plot the target space and aperture positions
Panl_SamplingRate = Panl.info.SamplingRateHz;
Panl_timeStep = 1/Panl_SamplingRate;
Panl_time = 0:Panl_timeStep:Panl_timeStep*length(Panl.data(:,1))-Panl_timeStep;

figure
plot(Panl_time, -Panl.data(:,1),'b')
hold on
plot(Panl_time, -Panl.data(:,4),'r')
plot(Panl_time, -Panl.data(:,5),'r')
% xlabel('Time (s)');
% ylabel('Hand Aperture Position');
% legend('hand aperture', 'high target', 'low target');

%% Compute the chance value
if calculateChanceAccuracy == 1
    
    accuracyChance = zeros(1000,1);
    % Find time when the task started
    % StartingTaskIndeces = find(Task.data(:,1)==1,3);
    % startTime = StartingTaskIndeces(2)/Task.info.SamplingRateHz;
    startTime = 131; %seconds
    endTime = 250; %seconds
    startSamp = floor(startTime*Panl_SamplingRate);
    endSamp = floor(endTime*Panl_SamplingRate);
    %endSamp = length(Aper.data(:,1))-100;
    dx = diff(Panl.data(startSamp:endSamp,1));
    
    for i=1:1000
        dx_shuffled = dx(randperm(length(dx)));
        pos_shuffled = cumsum([Panl.data(startSamp,1) dx_shuffled']);
       
        % Calculate the accuracy
        accuracyChance(i, 1) = sum(pos_shuffled' < Panl.data(startSamp:endSamp,4) & pos_shuffled' > Panl.data(startSamp:endSamp,5))/length(pos_shuffled');
    end
% Plot
figure
plot(Panl_time(startSamp:endSamp), pos_shuffled, 'b')
hold on
plot(Panl_time(startSamp:endSamp), Panl.data((startSamp:endSamp),4),'r')
plot(Panl_time(startSamp:endSamp), Panl.data((startSamp:endSamp),5),'r')
%stem(startingTime, 'y')

averageChanceAccuracy = mean(accuracyChance)

end

%% Print the parameter values
% catchVar = max(Task.data(:,4))
% NStimChans = max(Task.data(:,6))
% disp('Stim 0')
% pulseAmp = max(Stm0.data(:,1))
% pulseDur = max(Stm0.data(:,2))
% IPI = max(Stm0.data(:,5))
% PulseTrainDur = max(Stm0.data(:,8))
% ITI = max(Stm0.data(:,11))
% disp('Stim 1')
% pulseAmp = max(Stm1.data(:,1))
% pulseDur = max(Stm1.data(:,2))
% IPI = max(Stm1.data(:,5))
% PulseTrainDur = max(Stm1.data(:,8))
% ITI = max(Stm1.data(:,11))
% accuracy = max(Task.data(15090:length(Task.data),8))
% figure
% plot(Task.data(:,8))
