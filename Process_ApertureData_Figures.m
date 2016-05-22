%% This plots results per subject with histograms (ksdensity is used at end)
% Section below will plot the subject traces

clear all, close all
sids = ['ecb43e'; 'fca96e'; 'cdceeb'];

for ii=2:2
    sid = sids(ii,:);
    %load(strcat('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\050616, for reviews\', sid))
    load(strcat('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\051016, for reviews\', sid))
    
    switch(sid)
        case 'fca96e'
            trials = [2 5 7 8 9 10 12 13 15 16 17];
            trials_NV = [5 7 8 9 10 17];
            practiceTrials = [1 0 0 0 0 0 1 1 1 1 0];
            catchTrial = 0;
            
        case 'ecb43e'
            trials = [4 5 6 8 9 10 11 12 13 14 15 16 18 19];
            trials_NV = [4 9 10 11 12 13 14 15 16 18 19];
            practiceTrials = zeros(size(trials)); % Did not have any practice trials as defined above
            catchTrial = 14;
            
        case 'cdceeb'
            trials = [1 2 3];
            trials_NV = [1 2 3];
            practiceTrials = zeros(size(trials)); % Did not have any practice trials as defined above
            catchTrial = 0;
            
        otherwise
            error('unknown SID entered');
    end
    
    %% Accuracy
    % Want to plot visual and non-visual trial in different colors
    NV = ismember(trials, trials_NV);
    trialCount = 1:length(trials);
    
    figure
    width = 1;
    b=bar(trialCount(NV)', [accuracy(NV);chanceAccuracy(NV)]', width);
    myC = ['b'; 'y'];
    for k=1:2
        set(b(k), 'FaceColor', myC(k))
    end
    
    hold on
    b=bar(trialCount(~NV)', [accuracy(~NV);chanceAccuracy(~NV)]', width);
    myC = ['g'; 'y'];
    for k=1:2
        set(b(k), 'FaceColor', myC(k))
    end
    title(strcat('Accuracy of: ', sid));
    legend('Accuracy w/o visual', 'Chance accuracy with std dev', 'Accuracy w/ visual');
    
    h=errorbar([1:length(chanceAccuracy)]+(width/8), chanceAccuracy, std_chanceAccuracy, 'k');
    set(h,'linestyle','none');
    hold off
    
    %% R^2
    figure
    width = 1;
    b=bar(trialCount(NV)', [rsq(NV);chanceRsq(NV)]', width);
    myC = ['b'; 'y'];
    for k=1:2
        set(b(k), 'FaceColor', myC(k))
    end
    
    hold on
    b=bar(trialCount(~NV)', [rsq(~NV);chanceRsq(~NV)]', width);
    myC = ['g'; 'y'];
    for k=1:2
        set(b(k), 'FaceColor', myC(k))
    end
    title(['R^2 of: ', sid, sprintf('\nR-square (1) from entersTarget on')]);
    legend('R^2 w/o visual', 'Chance R^2 with std dev', 'R^2 w/ visual');
    
    h=errorbar([1:length(chanceRsq)]+(width/8), chanceRsq, std_chanceRsq, 'k');
    set(h,'linestyle','none');
    hold off
    
    %% Response times
    
    % Want to separate out response times when there is visual feedback
    % from when there's not, so first create boolean arrays that tell us
    % the NV trials
    trialTypes = {'no visual', 'visual'};
    
    for i = 1:length(trialTypes)
        type = trialTypes{i};
        switch(type)
            case 'no visual'
                T=NV;
            case 'visual'
                T=~NV;
        end
        
        % Response times to state changes
        figure
        subplot(2,3,1)
        h=histogram(cell2mat(responseTime_open(T)));
        h.BinWidth=50; h.BinLimits=[0 1500];
        title(['Response times: ', sid, ' ', type, sprintf('\nStim state changes, open')]);
        subplot(2,3,2)
        h=histogram(cell2mat(responseTime_closed(T)));
        h.BinWidth=50; h.BinLimits=[0 1500];
        title('Stim state changes, closed')
        subplot(2,3,3)
        h= histogram(cell2mat(responseTime_in(T)));
        h.BinWidth=50; h.BinLimits=[0 1500];
        title('Stim state changes, inside')
        
        % Response times to train starts
        subplot(2,3,4)
        h=histogram(cell2mat(responseTimeTrains_open(T)));
        h.BinWidth=50; h.BinLimits=[0 1500];
        title('Stim train starts, open')
        subplot(2,3,5)
        h=histogram(cell2mat(responseTimeTrains_closed(T)));
        h.BinWidth=50; h.BinLimits=[0 1500];
        title('Stim train starts, closed')
        subplot(2,3,6)
        % Ignore the responseTimeTrains_in for the catch trial (if it is a
        % catch trial)
        CT=(trials==catchTrial); % This will be all zeros and not affect matrix if there's no catch
        responseTimeTrains_in_NoCatch = responseTimeTrains_in(~CT);
        h=histogram(cell2mat(responseTimeTrains_in_NoCatch(T(~CT))));
        h.BinWidth=50; h.BinLimits=[0 1500];
        title('Stim train starts, in')
        
        % Response times to random walk
        figure
        subplot(1,3,1)
        h=histogram(cell2mat(reshape(chanceResponseTimes(T,1,:), [], 1)));
        h.BinWidth=50; %h.BinLimits=[0 1500];
        title(['Response times: ', sid, ' ', type, sprintf('\nRandom walk response times, open')]);
        subplot(1,3,2)
        h=histogram(cell2mat(reshape(chanceResponseTimes(T,2,:), [], 1)));
        h.BinWidth=50; %h.BinLimits=[0 1500];
        title('Random walk response times, closed')
        subplot(1,3,3)
        h=histogram(cell2mat(reshape(chanceResponseTimes(T,3,:), [], 1)));
        h.BinWidth=50; %h.BinLimits=[0 1500];
        title('Random walk response times, in')
        
        figure
        h=histogram(cell2mat(reshape(chanceResponseTimes(T,:,:), [], 1)));
        h.BinWidth=50; h.BinLimits=[0 1500];
        title(['Response times: ', sid, ' ', type, sprintf('\nRandom walk response times, aggregate')]);
        
        % Response times to catch trial, if there was one
        if catchTrial % catchTrail is 0 if there wasn't one
            figure
            h=histogram(responseTimeTrains_in{catchTrial});
            h.BinWidth=50; h.BinLimits=[0 1500];
            title(['Catch trial response times: ', sid])
        end
        
        %% Correction times
        figure
        subplot(1,2,1)
        h=histogram(cell2mat(correctionTime_open(T)));
        h.BinWidth=50; h.BinLimits=[0 3200];
        title(['Correction times open: ', sid, ' ', type,]);
        subplot(1,2,2)
        temp=cellfun('isempty',correctionTime_closed);
        correctionTime_closed = correctionTime_closed(~temp);
        temp2=T(~temp);
        h=histogram(cell2mat(correctionTime_closed(temp2)));
        h.BinWidth=50; h.BinLimits=[0 3200];
        title(['Correction times closed: ', sid, ' ', type,]);
        
        %% Response times but plotted with smoothed kernel rather than histograms, assigning bandwidth
        width = 0.2; % smaller bandwidth smooths the density estimate less, which exaggerates some characteristics of the sample
        
        [f, xi] = ksdensity(cell2mat(reshape(chanceResponseTimes(T,:,:), [], 1)),...
            'support','positive', 'function', 'pdf', 'bandwidth', width);
        figure, plot(xi,f)
        hold on
        
        [f, xi] = ksdensity(cell2mat(responseTime_open(T)),...
            'support','positive', 'function', 'pdf', 'bandwidth', width);
        plot(xi,f, 'LineWidth', 2)
        
        [f, xi] = ksdensity(cell2mat(responseTime_closed(T)),...
            'support','positive', 'function', 'pdf', 'bandwidth', width);
        plot(xi,f, 'LineWidth', 2)
        
        [f, xi] = ksdensity(cell2mat(responseTime_in(T)),...
            'support','positive', 'function', 'pdf', 'bandwidth', width);
        plot(xi,f, 'LineWidth', 2)
        
        %         [f, xi] = ksdensity(cell2mat(responseTimeTrains_open(T)),...
        %             'support','positive', 'function', 'pdf', 'bandwidth', width);
        %         plot(xi,f)
        %
        %         [f, xi] = ksdensity(cell2mat(responseTimeTrains_closed(T)),...
        %             'support','positive', 'function', 'pdf', 'bandwidth', width);
        %         plot(xi,f)
        %
        %         [f, xi] = ksdensity(cell2mat(responseTimeTrains_in_NoCatch(T(~CT))),...
        %             'support','positive', 'function', 'pdf', 'bandwidth', width);
        %         plot(xi,f)
        %
        %         % Response times to catch trial, if there was one
        %         if catchTrial % catchTrail is 0 if there wasn't one
        %             [f, xi] = ksdensity(responseTimeTrains_in{catchTrial},...
        %                 'support','positive', 'function', 'pdf', 'bandwidth', width);
        %             plot(xi,f)
        %             legend('chance response times, all', 'stim state changes, open',...
        %                 'stim state changes, closed', 'stim state changes, in',...
        %                 'train starts, open', 'train starts, closed', 'train starts, in', 'catch trial')
        %         else % set legend
        %             legend('chance response times, all', 'stim state changes, open',...
        %                 'stim state changes, closed', 'stim state changes, in',...
        %                 'train starts, open', 'train starts, closed', 'train starts, in')
        %         end
        legend('chance response times, all', 'stim state changes, open',...
            'stim state changes, closed', 'stim state changes, in')
        
        xlim([0 500])
        title(['Response times: ', sid, ' ', type, sprintf('\nBandwidth = '), num2str(width)])
        
        %% Response times but plotted with smoothed kernel rather than histograms, allowing algorithm to choose bandwidth
        [f, xi, bw(1)] = ksdensity(cell2mat(reshape(chanceResponseTimes(T,:,:), [], 1)),...
            'support','positive', 'function', 'pdf');
        figure, plot(xi,f)
        hold on
        
        [f, xi, bw(2)] = ksdensity(cell2mat(responseTime_open(T)),...
            'support','positive', 'function', 'pdf');
        plot(xi,f, 'LineWidth', 2)
        
        [f, xi, bw(3)] = ksdensity(cell2mat(responseTime_closed(T)),...
            'support','positive', 'function', 'pdf');
        plot(xi,f, 'LineWidth', 2)
        
        [f, xi, bw(4)] = ksdensity(cell2mat(responseTime_in(T)),...
            'support','positive', 'function', 'pdf');
        plot(xi,f, 'LineWidth', 2)
        
        %         [f, xi, bw(5)] = ksdensity(cell2mat(responseTimeTrains_open(T)),...
        %             'support','positive', 'function', 'pdf');
        %         plot(xi,f)
        %
        %         [f, xi, bw(6)] = ksdensity(cell2mat(responseTimeTrains_closed(T)),...
        %             'support','positive', 'function', 'pdf');
        %         plot(xi,f)
        %
        %         [f, xi, bw(7)] = ksdensity(cell2mat(responseTimeTrains_in_NoCatch(T(~CT))),...
        %             'support','positive', 'function', 'pdf');
        %         plot(xi,f)
        %
        %         % Response times to catch trial, if there was one
        %         if catchTrial % catchTrail is 0 if there wasn't one
        %             [f, xi, bw(8)] = ksdensity(responseTimeTrains_in{catchTrial},...
        %                 'support','positive', 'function', 'pdf');
        %             plot(xi,f)
        %             legend('chance response times, all', 'stim state changes, open',...
        %                 'stim state changes, closed', 'stim state changes, in',...
        %                 'train starts, open', 'train starts, closed', 'train starts, in', 'catch trial')
        %         else % set legend
        %             legend('chance response times, all', 'stim state changes, open',...
        %                 'stim state changes, closed', 'stim state changes, in',...
        %                 'train starts, open', 'train starts, closed', 'train starts, in')
        %         end
        
        legend('chance response times, all', 'stim state changes, open',...
            'stim state changes, closed', 'stim state changes, in')
        
        xlim([0 500])
        title(['Response times: ', sid, ' ', type, sprintf('\nBandwidth = choosen for each fxn by ksdensity\n'), num2str(bw)])
        
    end
end

%% This will plot the subject traces
sids = ['ecb43e'; 'fca96e'; 'cdceeb'];
for ii=1:3
    sid = sids(ii,:);
    load(strcat('C:\Users\jcronin\Box Sync\Lab\ECoG\Aperture\Data Analysis\051016, for reviews\', sid))
    figs =[9];
    h=figure('position', [0, 0, 2070, 1059]);
    %%
    count=1;
    for i = 1:length(figs)
        switch(sid)
            case 'fca96e'
                trials = [2 5 7 8 9 10 12 13 15 16 17];
                load(strcat('C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\','Aperture-',num2str(trials(figs(i)))));
            case 'ecb43e'
                trials = [4 5 6 8 9 10 11 12 13 14 15 16 18 19];
                load(strcat('C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\Matlab_Aperture\','Aperture_ecb43e-',num2str(trials(figs(i)))));
            case 'cdceeb'
                trials = [1 2 3];
                load(strcat('C:\Users\jcronin\Data\Subjects\cdceeb(wrong-f3e511)\data\d14\Aperture_cdceeb\Matlab\','ApertureCheck-',num2str(trials(figs(i)))));
        end
        
        fs_aper = Aper.info.SamplingRateHz; % sampling rate of the stim data (Hz)
        fs_stim = Stim.info.SamplingRateHz;
        startSampAper = floor(startTime(figs(i))*fs_aper);
        endSampAper = floor(endTime(figs(i))*fs_aper);
        startSampStim = floor(startTime(figs(i))*fs_stim);
        endSampStim = floor(endTime(figs(i))*fs_stim);
        
        data = Aper.data(startSampAper:endSampAper,1);
        high_boundary = Aper.data(startSampAper:endSampAper,2);
        low_boundary = Aper.data(startSampAper:endSampAper,3);
        
        stimI = Stim.data(startSampStim:endSampStim, 4); % This is the stimulation current waveform that was set
        stimV= Stim.data(startSampStim:endSampStim, 5); % This is the stimulation voltage as monitored during delivery at the IZ
        % Times:
        t_aper = (0:1:length(data)-1)/fs_aper; % This was defined previously over the entire time range for use in the aper_startANDendTimes function; now redefining over just the period of interest
        t_stim = (0:length(stimI)-1)/fs_stim; % stim timing (s), starting from the starting Stim (armed) sample)
        
        
        %h.Units = 'inches';
        subplot(length(figs)*3,1,[count count+1])
        ax=gca;
        plot(t_aper, data, 'k', 'Linewidth', 2), hold on
        plot(t_aper, high_boundary,'k:', 'Linewidth', 1), 
        plot(t_aper, low_boundary,'k:', 'Linewidth', 1)
        title(['Trial ' num2str(figs(i))]),
        legend('Aperture (position)', 'High/Low thresholds')
        ylabel('Hand aperture position')
        ax.XTickLabel=[];
        ax.XMinorTick='on';
        set(ax, 'box', 'off');
        ax.YLim=[min(data)-0.1 max(data)+0.1];
        set(ax, 'Ytick', 0:0.5:1);
        set(gca, 'XLim',[0 130])
        
        subplot(length(figs)*3,1, count+2)
        ax=gca;
        plot(t_stim, stimI*2/1000, 'k')
        xlabel('Trial time (s)')
        legend('Biphasic stim trains')
       
        ax.YLim=[-4 4];
        ax.XMinorTick='on';
        ylabel('Current (mA)')
        set(ax, 'box', 'off');
        set(gca, 'XLim',[0 130])
        
        count=count+3;
    end
    %%
end
