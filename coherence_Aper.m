%% Coherence analysis
fileName = 'C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\Matlab, Aperture\Aperture_ecb43e-12';
load(fileName);

SamplingRate = Stim.info.SamplingRateHz;
Stim_timeStep = 1/SamplingRate;
Stim_time = (0:length(Stim.data(:,1))-1)/SamplingRate;

Aper_SamplingRate = Aper.info.SamplingRateHz;
Aper_timeStep = 1/Aper_SamplingRate;
Aper_time = (0:length(Aper.data(:,1))-1)/Aper_SamplingRate;

figure
plot(Stim_time, Stim.data(:,5), 'r')
hold on
plot(Aper_time, Aper.data(:,1),'b')
plot(Aper_time, Aper.data(:,2),'g')
plot(Aper_time, Aper.data(:,3),'g')

startTime = 31.09;
endTime = 151;

startSampAper = floor(startTime*Aper_SamplingRate);
endSampAper = floor(endTime*Aper_SamplingRate);

startSampStim = floor(startTime*SamplingRate);
endSampStim = floor(endTime*SamplingRate);


% stimSampled = Stim.data(startSampStim:SamplingRate/Aper_SamplingRate:endSampStim,5);
% stimSampled = stim(1:SamplingRate/Aper_SamplingRate:end,5);
aper = Aper.data(startSampAper:endSampAper-1,1);


stimState = Stim.data(startSampStim:endSampStim,3);
stimStat2 = zeros(size(stimState));
stimState2(stimState==2)=0;
stimState2(stimState==3)=2;
stimState2(stimState==1)=1;
stimState = stimState2;


dxState = diff(Stim.data(:,3));


%% Determine coherence based on stimulation data in volts (post IZ2) 
% stim = Stim.data(startSampStim:endSampStim,5);
% stim2 = zeros(size(stim));
% % for iter=1:length(stim)
% %     if stim(iter)>-0.6 & stim(iter)<0.3
% %         stim2(iter)=0;
% %     elseif stim(iter)>0.3 & stim(iter)<4.3 || stim(iter)<-0.6 & stim(iter)>-4
% %         stim2(iter)=1;
% %     elseif stim(iter)>4.3 || stim(iter)<-4
% %         stim2(iter)=2;
% %     end
% % end
% 
% for iter=1:length(stim)
%     if stim(iter)<0.3
%         stim2(iter)=0;
%     elseif stim(iter)>=0.3 & stim(iter)<=4.23
%         stim2(iter)=1;
%     elseif stim(iter)>4.23
%         stim2(iter)=2;
%     end
% end
% 
% [pks,locs] = findpeaks(stim2);
% figure
% plot(stim2, 'g')
% hold on
% stem(locs, pks, 'b')
% plot(stim,'r')
% 
% stim3 = zeros(size(stim2));
% ITI_samps = Stim.info.SamplingRateHz*max(Stm0.data(:,13))*10^(-3);
% for i=1:length(locs)-1
%     if pks(i) == pks(i+1) && (locs(i+1)-locs(i))<=ITI_samps + 121
%         stim3(locs(i):locs(i+1)) = pks(i);
%     else
%         stim3(locs(i):locs(i)+121+ITI_samps) = pks(i);
% %     elseif pks(i) ~= pks(i+1) && (locs(i+1)-locs(i))<=ITI_samps + 121
% %         stim3(locs(i):locs(i)+121) = pks(i);
% %     elseif pks(i) == pks(i+1) && (locs(i+1)-locs(i))>ITI_samps + 121
% %         stim3(locs(i):locs(i)+121+ITI_samps) = pks(i);
% %     elseif pks(i) ~= pks(i+1) && (locs(i+1)-locs(i))>ITI_samps + 121
% %         stim3(locs(i):locs(i)+121+ITI_samps) = pks(i);
%     end
% end
% 
% 
% figure
% plot(stim,'r')
% hold on
% plot(stim3, 'b');
% plot(stimState, 'g');

%% Determine coherence based on stimulation data in amps (stim wave to use) 
stim = Stim.data(startSampStim:endSampStim,4);
[pks,locs] = findpeaks(stim);
% figure
% plot(stim)
% hold on
% stem(locs, pks, 'r')

stim2 = zeros(size(stim));
ITI_samps = Stim.info.SamplingRateHz*max(Stm0.data(:,13))*10^(-3);
for i=1:length(locs)-1
    if pks(i) == pks(i+1) && (locs(i+1)-locs(i))<=ITI_samps + 121
        stim2(locs(i):locs(i+1)) = pks(i);
    else
        stim2(locs(i):locs(i)+121+ITI_samps) = pks(i);
    end
end

figure
plot(stim,'r')
hold on
plot(stim2, 'b');
%plot(stimState*1000, 'g');

%% Diffs

stim3(stim2==0) = 0;
stim3(stim2==max(Stm0.data(:,1))) = 1;
stim3(stim2==max(Stm1.data(:,1))) = 2;

sample_stim3 = stim3(1:SamplingRate/Aper_SamplingRate:end);
dx_aper = diff(aper);
dx_stim = diff(sample_stim3);
figure
plot(dx_aper*50)
hold on
plot(dx_stim, 'r')

%%

% N = length(stim);
% M = round(sqrt(N));
% [cxyM,w] = mscohere(aper', stim', M);
% 
% figure
% stem(w/2,cxyM,'*'); % w goes from 0 to 1 (odd convention)
% legend('');         % needed in Octave
% grid on;
% ylabel('Coherence');
% xlabel('Normalized Frequency (cycles/sample)');
% axis([0 1/2 0 1]);