load('/Users/jcronin/Box Sync/Lab/ECoG/Aperture/Data Analysis/Accuracy/ecb43e_accuracy.mat')
ecb43e_acc = accuracy;
ecb43e_chance = chanceAccuracy;
load('/Users/jcronin/Box Sync/Lab/ECoG/Aperture/Data Analysis/Accuracy/cdceeb_accuracy.mat')
cdceeb_acc = accuracy;
cdceeb_chance = chanceAccuracy;

figure(1), bar([ecb43e_acc; ecb43e_chance]')
figure(2), bar([cdceeb_acc; cdceeb_chance]')

ecb_NVisTrials = [1 0 0 0 1 1 1 1 1 1 1 1 1 1];
ecb_NVis = ecb43e_acc(ecb_NVisTrials==1);
ecb_NVis_chance = ecb43e_chance(ecb_NVisTrials==1);
[max_ecb43e_NVis, ecb_i] = max(ecb_NVis);


[max_cdceeb_NVis, cdc_i] = max(cdceeb_acc); % all cdceeb trials were w/o visual feedback

% Max accuracy
figure(3), bar([max_cdceeb_NVis, cdceeb_chance(cdc_i); ...
    max_ecb43e_NVis, ecb_NVis_chance(ecb_i)])
title('Max accuracies of two subjects');
legend('accuracy', 'chance accuracy');
ylabel('Accuracy'); ylim([0 1])
set(gca,'xticklabel',{'Subject 1', 'Subject 2'})

%% Plot the average of all of the trials with no visual feedback

figure(4)
bar([mean(cdceeb_acc), mean(cdceeb_chance); ...
    mean(ecb_NVis), mean(ecb_NVis_chance)])
title('Mean accuracies of two subjects');
legend('Mean accuracy', 'Mean chance accuracy');
