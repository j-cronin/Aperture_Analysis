%% Load in the saved response timing data
ecb43e_trials_NV = [4 9 10 11 12 13 14 15 16 18 19];
responseTime_openALL=[];
responseTime_closedALL = [];
for i=1:length(ecb43e_trials_NV)
    sid = 'ecb43e';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\ecb43e\';
    trialNum = num2str(ecb43e_trials_NV(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_Timing_', trialNum));
    responseTime_openALL = vertcat(responseTime_openALL, responseTime_open);
    responseTime_closedALL = vertcat(responseTime_closedALL, responseTime_closed);
end
responseTime_openALLsubj = [];
responseTime_openALLsubj = vertcat(responseTime_openALLsubj, responseTime_openALL);
responseTime_closedALLsubj = [];
responseTime_closedALLsubj = vertcat(responseTime_closedALLsubj, responseTime_closedALL);
save(strcat(pathToSave, sid, '_resultArrays_responseTiming'), 'responseTime_openALL','responseTime_closedALL');

fca96e_trials_NV = [5 7 8 9 10 17];
responseTime_openALL=[];
responseTime_closedALL = [];
for i=1:length(fca96e_trials_NV)
    sid = 'fca96e';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\fca96e\';
    trialNum = num2str(fca96e_trials_NV(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_Timing_', trialNum));
    responseTime_openALL = vertcat(responseTime_openALL, responseTime_open);
    responseTime_closedALL = vertcat(responseTime_closedALL, responseTime_closed);
end
responseTime_openALLsubj = vertcat(responseTime_openALLsubj, responseTime_openALL);
responseTime_closedALLsubj = vertcat(responseTime_closedALLsubj, responseTime_closedALL);
save(strcat(pathToSave, sid, '_resultArrays_responseTiming'), 'responseTime_openALL','responseTime_closedALL');

cdceeb_trials_NV = [1 2 3];
responseTime_openALL=[];
responseTime_closedALL = [];
for i=1:length(cdceeb_trials_NV)
    sid = 'cdceeb';
    pathToSave = 'C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\cdceeb (wrong-f3e511)\';
    trialNum = num2str(cdceeb_trials_NV(i));
    load(strcat(pathToSave, sid, '_AperANALYSIS_Timing_', trialNum));
    responseTime_openALL = vertcat(responseTime_openALL, responseTime_open);
    responseTime_closedALL = vertcat(responseTime_closedALL, responseTime_closed);
end
responseTime_openALLsubj = vertcat(responseTime_openALLsubj, responseTime_openALL);
responseTime_closedALLsubj = vertcat(responseTime_closedALLsubj, responseTime_closedALL);
save(strcat(pathToSave, sid, '_resultArrays_responseTiming'), 'responseTime_openALL','responseTime_closedALL');

% Save the aggregated results from all of the subjects:
save('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\AggregatedResponseTimes2', 'responseTime_openALLsubj','responseTime_closedALLsubj');


%% Response Timing histograms
responseTime_openALL = responseTime_openALLsubj;
responseTime_closedALL = responseTime_closedALLsubj;

edges_open = 0:50:ceil(max(responseTime_openALL)/50)*50;
figure
hist(responseTime_openALL, edges_open) % Histogram of the response times in ms
title(strcat('Time after stim error (too open, no stim) to change in movement'));
xlabel('response timing (ms)')
ylabel('count')

edges_closed = 0:50:ceil(max(responseTime_closedALL)/50)*50;
figure
hist(responseTime_closedALL, edges_closed) % Histogram of the response times in ms
title(strcat('Time after stim error (too closed, high intensity stim) to change in movement'));
xlabel('response timing (ms)')
ylabel('count')
