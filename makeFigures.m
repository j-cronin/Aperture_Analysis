% make the figures
catchTrial = 14; % NOTE: This will need to be changed depending on which is the catch trial!!!!!!

load('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_correctionTime.mat')
load('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_inTime.mat')
load('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data\ecb43e\ecb43e_avg_responseTime.mat')

avg_correctionTime(catchTrial, :) = NaN; % Change the catch trial values to NaN, since there really can't be a true correction time in the case of a catch since all of the stimulation is the same and there's no stim change to base the measurement off of
correctionTimesLow = avg_correctionTime(4:end,1);
correctionTimesHigh = avg_correctionTime(4:end,2);
correctionTimesLow = correctionTimesLow(find(correctionTimesLow~=0));
correctionTimesHigh = correctionTimesHigh(find(correctionTimesHigh~=0));

avg_responseTime(catchTrial, :) = NaN; % Change the catch trial values to NaN, since there really can't be a true response time in the case of a catch since all of the stimulation is the same and there's no stim change to base the measurement off of
responseTimesLow = avg_responseTime(4:end,1);
responseTimesHigh = avg_responseTime(4:end,2);
responseTimesLow = responseTimesLow(find(responseTimesLow~=0));
responseTimesHigh = responseTimesHigh(find(responseTimesHigh~=0));

inTime = avg_inTime(4:end);
inTime = inTime(find(inTime~=0));

figure(1)
subplot(2,1,1)
bar(correctionTimesHigh)
xlabel('Trials')
ylabel('Time (s)')
title('Average Time to Correction, from too open')
subplot(2,1,2)
bar(correctionTimesLow)
xlabel('Trials')
ylabel('Time (s)')
title('Average Time to Correction, from too closed')

figure(2)
subplot(2,1,1)
bar(responseTimesHigh)
xlabel('Trials')
ylabel('Time (s)')
title('Average Response Time, from too open')
subplot(2,1,2)
bar(responseTimesLow)
xlabel('Trials')
ylabel('Time (s)')
title('Average Response Time, from too closed')

figure(3)
bar(inTime)
xlabel('Trials')
ylabel('Time (s)')
title('Average periods of time within target range')

%%
num_periodsInside = [3
2
22

24
27
14
21
39
31
8
14
21

28
41
]';

figure(4)
bar(num_periodsInside);

xlabel('Trials')
ylabel('Time (s)')
title('Number of periods/walks in the target range')

%% Average time outside the target range
% copied values from the excel spreadsheet
timeOutside = [11.9454
6.9562
2.5331

1.8529
1.4272
1.4397
1.4924
1.1556
0.9468
11.8635
3.155
3.2548

2.0833
1.0493
];
figure

h1 = bar(1:7, timeOutside(1:7), 'g')
hold on
h2 = bar(8:9, timeOutside(8:9), 'b')
% bar(10, timeOutside(10), 'facecolor', [1,0,1])
h3 = bar(10, timeOutside(10), 'r')
h4 = bar(11:14, timeOutside(11:14), 'b')

xlabel('Trials')
ylabel('Time (s)')
title('Average Period of Time Outside of Target')
set(get(get(h4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
legend()
%% accuracies

accuracy = dlmread('C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\accuracy.csv');
accuracy = accuracy(2:end)

chance = 0.234133333;

figure
plot(accuracy)
hold on
plot(0:14, repmat(chance, 1, 15), 'g')
% plot(1:7, accuracy(1:7), 'b')
% hold on
% 
% plot(1:7, accuracy(1:7), 'g')
% plot(7:9, accuracy(7:9), 'b')
% plot(9:10, accuracy(9:10), 'r')
% plot(10:14, accuracy(10:14), 'b')

plot(10, accuracy(10), 'o')


xlabel('Trials')
ylabel('Time (s)')
title('Accuracy (percent time within target)')