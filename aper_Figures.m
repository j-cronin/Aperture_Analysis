%% Load in the saved data for each subject
ecb43e_trials = [4 5 6 8 9 10 11 12 13 14 15 16 18 19];  % including catch
% ecb43e_trials = [4 5 6 8 9 10 11 12 13 15 16 18 19]; % without catch
r2 = zeros(size(ecb43e_trials));
r2_chance = zeros(size(ecb43e_trials));
r2_bar = zeros(length(ecb43e_trials),2);
accuracy = zeros(size(ecb43e_trials));
accuracyChance = zeros(size(ecb43e_trials));
acc_bar = zeros(length(ecb43e_trials),2);
avg_correctionTime_open = zeros(size(ecb43e_trials));
avg_correctionTime_closed = zeros(size(ecb43e_trials));
responseTime_openALL=[];
responseTime_closedALL = [];
for i=1:length(ecb43e_trials)
    sid = 'ecb43e';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\';
    trialNum = num2str(ecb43e_trials(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_', trialNum));
    r2(i) = r2_center;
    r2_bar(i,:) = [r2_center, r2_chance];
    r2_chance(i) = r2_chance;
    accuracy(i) = aper_accuracy;
    accuracyChance(i) = chanceAccuracy;
    acc_bar(i,:) = [aper_accuracy, chanceAccuracy];
    avg_correctionTime_open(i) = mean(correctionTime_open);
    avg_correctionTime_closed(i) = mean(correctionTime_closed);
    responseTime_openALL = vertcat(responseTime_openALL, responseTime_open);
    responseTime_closedALL = vertcat(responseTime_closedALL, responseTime_closed);
end
responseTime_openALLsubj = [];
responseTime_openALLsubj = vertcat(responseTime_openALLsubj, responseTime_openALL);
responseTime_closedALLsubj = [];
responseTime_closedALLsubj = vertcat(responseTime_closedALLsubj, responseTime_closedALL);

ecb43e_avg_correctionTime_open = mean(avg_correctionTime_open(~isnan(avg_correctionTime_open)));
ecb43e_avg_correctionTime_closed = mean(avg_correctionTime_closed(~isnan(avg_correctionTime_closed)));
save(strcat(pathToSave, sid, '_resultArrays'), 'r2','r2_chance','r2_bar', 'accuracy', 'accuracyChance','avg_correctionTime_open','avg_correctionTime_closed','responseTime_openALL','responseTime_closedALL');

fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];
r2 = zeros(size(fca96e_trials));
r2_chance = zeros(size(fca96e_trials));
r2_bar = zeros(length(fca96e_trials),2);
accuracy = zeros(size(fca96e_trials));
accuracyChance = zeros(size(fca96e_trials));
acc_bar = zeros(length(fca96e_trials),2);
avg_correctionTime_open = zeros(size(fca96e_trials));
avg_correctionTime_closed = zeros(size(fca96e_trials));
responseTime_openALL=[];
responseTime_closedALL = [];
for i=1:length(fca96e_trials)
    sid = 'fca96e';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\';
    trialNum = num2str(fca96e_trials(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_', trialNum));
    r2(i) = r2_center;
    r2_bar(i,:) = [r2_center, r2_chance];
    r2_chance(i) = r2_chance;
    accuracy(i) = aper_accuracy;
    accuracyChance(i) = chanceAccuracy;
    acc_bar(i,:) = [aper_accuracy, chanceAccuracy];
    avg_correctionTime_open(i) = mean(correctionTime_open);
    avg_correctionTime_closed(i) = mean(correctionTime_closed);  
    responseTime_openALL = vertcat(responseTime_openALL, responseTime_open);
    responseTime_closedALL = vertcat(responseTime_closedALL, responseTime_closed);
end
responseTime_openALLsubj = vertcat(responseTime_openALLsubj, responseTime_openALL);
responseTime_closedALLsubj = vertcat(responseTime_closedALLsubj, responseTime_closedALL);

fca96e_avg_correctionTime_open = mean(avg_correctionTime_open(~isnan(avg_correctionTime_open)));
fca96e_avg_correctionTime_closed = mean(avg_correctionTime_open(~isnan(avg_correctionTime_open)));
save(strcat(pathToSave, sid, '_resultArrays'), 'r2','r2_chance','r2_bar', 'accuracy', 'accuracyChance','avg_correctionTime_open','avg_correctionTime_closed','responseTime_openALL','responseTime_closedALL');

cdceeb_trials = [2 3];
r2 = zeros(size(cdceeb_trials));
r2_chance = zeros(size(cdceeb_trials));
r2_bar = zeros(length(cdceeb_trials),2);
accuracy = zeros(size(cdceeb_trials));
accuracyChance = zeros(size(cdceeb_trials));
acc_bar = zeros(length(cdceeb_trials),2);
avg_correctionTime_open = zeros(size(cdceeb_trials));
avg_correctionTime_closed = zeros(size(cdceeb_trials));
responseTime_openALL=[];
responseTime_closedALL = [];
for i=1:length(cdceeb_trials)
    sid = 'cdceeb';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\cdceeb (wrong-f3e511)\';
    trialNum = num2str(cdceeb_trials(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_', trialNum));
    r2(i) = r2_center;
    r2_bar(i,:) = [r2_center, r2_chance];
    r2_chance(i) = r2_chance;
    accuracy(i) = aper_accuracy;
    accuracyChance(i) = chanceAccuracy;
    acc_bar(i,:) = [aper_accuracy, chanceAccuracy];
    avg_correctionTime_open(i) = mean(correctionTime_open);
    avg_correctionTime_closed(i) = mean(correctionTime_closed);    
    responseTime_openALL = vertcat(responseTime_openALL, responseTime_open);
    responseTime_closedALL = vertcat(responseTime_closedALL, responseTime_closed);
end
responseTime_openALLsubj = vertcat(responseTime_openALLsubj, responseTime_openALL);
responseTime_closedALLsubj = vertcat(responseTime_closedALLsubj, responseTime_closedALL);

cdceeb_avg_correctionTime_open = mean(avg_correctionTime_open(~isnan(avg_correctionTime_open)));
cdceeb_avg_correctionTime_closed = mean(avg_correctionTime_open(~isnan(avg_correctionTime_open)));
save(strcat(pathToSave, sid, '_resultArrays'), 'r2','r2_chance','r2_bar', 'accuracy', 'accuracyChance','avg_correctionTime_open','avg_correctionTime_closed','responseTime_openALL','responseTime_closedALL');

save('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\AverageCorrectionTimes',...
    'ecb43e_avg_correctionTime_open', 'ecb43e_avg_correctionTime_closed',...
    'fca96e_avg_correctionTime_open', 'fca96e_avg_correctionTime_closed',...
    'cdceeb_avg_correctionTime_open', 'cdceeb_avg_correctionTime_closed');

%% Average correction time
load('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\AverageCorrectionTimes.mat')
correctionTimes=[cdceeb_avg_correctionTime_closed, cdceeb_avg_correctionTime_open, ecb43e_avg_correctionTime_closed, ecb43e_avg_correctionTime_open, fca96e_avg_correctionTime_closed, fca96e_avg_correctionTime_open];
mean(correctionTimes)
min(correctionTimes)

%% Make R^2 figure
sid = 'ecb43e';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\';
load(strcat(pathToSave, sid, '_resultArrays'));
figure
subplot(3,1,1)
bar(r2_bar)
title(strcat(sid, ': r^2'));
legend('r2','chance')

sid = 'fca96e';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\';
load(strcat(pathToSave, sid, '_resultArrays'));
subplot(3,1,2)
bar(r2_bar)
title(strcat(sid, ': r^2'));
legend('r2','chance')

sid = 'cdceeb';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\cdceeb (wrong-f3e511)\';
load(strcat(pathToSave, sid, '_resultArrays'));
subplot(3,1,3)
bar(r2_bar)
title(strcat(sid, ': r^2'));
legend('r2','chance')

%% Accuracy plots
sid = 'ecb43e';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\';
load(strcat(pathToSave, sid, '_resultArrays'));
figure
bar(accuracy, 0.5)
hold on
bar(accuracyChance, 0.25, 'c')
title(strcat(sid, ': Accuracy with chance inlaid'));
legend('subject accuracy','chance accuracy')

sid = 'fca96e';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\';
load(strcat(pathToSave, sid, '_resultArrays'));
figure
bar(accuracy, 0.5)
hold on
bar(accuracyChance, 0.25, 'c')
title(strcat(sid, ': Accuracy with chance inlaid'));
legend('subject accuracy','chance accuracy')

sid = 'cdceeb';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\cdceeb (wrong-f3e511)\';
load(strcat(pathToSave, sid, '_resultArrays'));
figure
bar(accuracy, 0.5)
hold on
bar(accuracyChance, 0.25, 'c')
title(strcat(sid, ': Accuracy with chance inlaid'));
legend('subject accuracy','chance accuracy')

%% Load in the saved dx3 data
ecb43e_trials = [4 5 6 8 9 10 11 12 13 14 15 16 18 19];
avg_dx3_noChange = zeros(size(ecb43e_trials));
avg_dx3_stateChange = zeros(size(ecb43e_trials));
for i=1:length(ecb43e_trials)
    sid = 'ecb43e';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\';
    trialNum = num2str(ecb43e_trials(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_dx3_', trialNum));
    avg_dx3_noChange(i) = mean(abs(dx3_noChange));
    avg_dx3_stateChange(i) = mean(abs(dx3_stateChange));
end
save(strcat(pathToSave, sid, '_resultArrays_dx3'), 'avg_dx3_noChange','avg_dx3_stateChange');

fca96e_trials = [2 5 7 8 9 10 12 13 15 16 17];
avg_dx3_noChange = zeros(size(fca96e_trials));
avg_dx3_stateChange = zeros(size(fca96e_trials));
for i=1:length(fca96e_trials)
    sid = 'fca96e';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\';
    trialNum = num2str(fca96e_trials(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_dx3_', trialNum));
    avg_dx3_noChange(i) = mean(abs(dx3_noChange));
    avg_dx3_stateChange(i) = mean(abs(dx3_stateChange));
end
save(strcat(pathToSave, sid, '_resultArrays_dx3'), 'avg_dx3_noChange','avg_dx3_stateChange');

cdceeb_trials = [2 3];
avg_dx3_noChange = zeros(size(cdceeb_trials));
avg_dx3_stateChange = zeros(size(cdceeb_trials));
for i=1:length(cdceeb_trials)
    sid = 'cdceeb';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\cdceeb (wrong-f3e511)\';
    trialNum = num2str(cdceeb_trials(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_dx3_', trialNum));
    avg_dx3_noChange(i) = mean(abs(dx3_noChange));
    avg_dx3_stateChange(i) = mean(abs(dx3_stateChange));
end
save(strcat(pathToSave, sid, '_resultArrays_dx3'), 'avg_dx3_noChange','avg_dx3_stateChange');

%% Plot dx3 data
sid = 'ecb43e';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\';
load(strcat(pathToSave, sid, '_resultArrays_dx3'));
figure
bar(avg_dx3_stateChange, 0.5)
hold on
bar(avg_dx3_noChange, 0.25, 'c')
title(strcat(sid, ': Comparison of average jerk with and without a state change'));
legend('state change','no state change')

sid = 'fca96e';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\';
load(strcat(pathToSave, sid, '_resultArrays_dx3'));
figure
bar(avg_dx3_stateChange, 0.5)
hold on
bar(avg_dx3_noChange, 0.25, 'c')
title(strcat(sid, ': Comparison of average jerk with and without a state change'));
legend('state change','no state change')

sid = 'cdceeb';
pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\cdceeb (wrong-f3e511)\';
load(strcat(pathToSave, sid, '_resultArrays_dx3'));
figure
bar(avg_dx3_stateChange, 0.5)
hold on
bar(avg_dx3_noChange, 0.25, 'c')
title(strcat(sid, ': Comparison of average jerk with and without a state change'));
legend('state change','no state change')

%% Not using:
%% Response Timing histograms
responseTime_openALLsubj = responseTime_openALL;
responseTime_closedALLsubj = responseTime_closedALL;
figure
subplot(1,2,1)
edges_open = 0:50:ceil(max(responseTime_openALLsubj)/50)*50;
hist(responseTime_openALLsubj, edges_open) % Histogram of the response times in ms
% title(strcat(sid, ': Time after stim error (too open, no stim) to change in movement'));
title('Response Time')
xlabel('Time delay (ms)')
ylabel('Count')

subplot(1,2,2)
edges_closed = 0:50:ceil(max(responseTime_closedALLsubj)/50)*50;
hist(responseTime_closedALLsubj, edges_closed) % Histogram of the response times in ms
% title(strcat(sid, ': Time after stim error (too closed, high intensity stim) to change in movement'));
title('Response Time')
xlabel('Time delay (ms)')
ylabel('Count')

