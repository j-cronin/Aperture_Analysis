%% Initialization
try
    mjcClose(so)
end
% close;
% clear;
clc;

% 0: calibration, 1: Evalution
run_mode = 1;
% 0: use old normalization, 1: re-normalize (only for Evaluation)
norm_mode = 0;
% Required normalization time in seconds
norm_time = 5;
% Plot Raw:: 0: no, 1:yes
plot_mode = 1;
%Size of trace(recording ends when trace is full. Increase for longer recording session)
tracesize = 100000;


%% Load Hand
addpath('ServerComm');
modelFile = 'AdroitGloveCalib.xml';
so = mjcVizualizer;
mjcLoadModel(so, modelFile);

m = mjcGetModel(so);
qPose0  = m.qpos0;


%% Cyberglove init
addpath('cyberglove_matlab')
comPort = LocateCyberGlove();
% comPort = '\\.\COM3'; (fixed for a comp. Save it once you locate it)



%% RUN CALIBRATION ====================================
if (run_mode == 0)
	
	%% calibration poses (-1:0:1 :: qN:q0:qP)
	
	qPose	= xlsread('calibPoses.xls');
	
	%expand positive side (q = q0+k(qP-q0)))
	qRange	= m.jnt_range(:,2)-qPose0;
	qPoseP	= pp(qPose0, tt(qRange, qPose));
	
	%expand negative side (q = q0+k(q0-qN)))
	qRange	= qPose0 - m.jnt_range(:,1);
	qPoseN	= pp(qPose0, tt(qRange, qPose));
	
	%combine appropriatly
	qPose(qPose>=0) = qPoseP(qPose>=0);
	qPose(qPose<0)  = qPoseN(qPose<0);
	
	
	%% buffers
	nSample		= 100;
	trueValue	= zeros(size(qPose,1), nSample*size(qPose,2));
	gloveSamps	= zeros(22, nSample*size(qPose,2));
	
	
	%% Normalization (ask user to achive extreme movements)
	raw_range = [1000*ones(22,1), -1000*ones(22,1)];
	disp('Normalizing glove:: (Press a key when ready)');
	pause();
	disp('Explore the joint limits for next 10 sec.')
	
	tic
	while(toc<norm_time)
		gloveRaw  = double(staticGloveGetSample(comPort, 115200));
		raw_range(gloveRaw<raw_range(:,1),1) = gloveRaw(gloveRaw<raw_range(:,1));
		raw_range(gloveRaw>raw_range(:,2),2) = gloveRaw(gloveRaw>raw_range(:,2));
	end
	disp('Normalization complete')
	
	
	
	%% Render pose to mimic and record
	for i = 1:size(qPose,2)
		% render a pose
		mjcPlot(so, qPose(:,i), zeros(m.nv,1));
		
		% wait for user
		disp('Mimic and press a key')
		pause();
		
		%acquire and save data
		disp('Acquiring samples')
		for iSample=1:nSample
			trueValue(:,(i-1)*nSample + iSample) = qPose(:,i);
			gloveRaw = double(staticGloveGetSample(comPort, 115200));
			gloveSamps(:,(i-1)*nSample + iSample) = gloveRaw;
			
			% normalizing constantly
			raw_range(gloveRaw<raw_range(:,1),1) = gloveRaw(gloveRaw<raw_range(:,1));
			raw_range(gloveRaw>raw_range(:,2),2) = gloveRaw(gloveRaw>raw_range(:,2));
			
		end
		disp('done')
	end
	
	%% Update and normalize
	
	%update range
	extrm = min(gloveSamps,[],2);
	raw_range(extrm<raw_range(:,1),1) = extrm(extrm<raw_range(:,1));
	extrm = max(gloveSamps,[],2);
	raw_range(extrm>raw_range(:,2),2) = extrm(extrm>raw_range(:,2));
	
	%Normalize
	trueNValue = tt(pp(trueValue,-1*m.jnt_range(:,1)),1./(m.jnt_range(:,2)-m.jnt_range(:,1)));
	gloveNSamps = tt(pp(gloveSamps,-1*raw_range(:,1)),1./(raw_range(:,2)-raw_range(:,1)));
	
	%% Decompose the calibration
	
	% First finger calibrate
	map_raw_F	= [4 5 6 7 8 11];
	map_cal_F	= [3 4 5 6];
	calibration(map_cal_F, [map_raw_F 23]) = trueNValue(map_cal_F,:)/[gloveNSamps(map_raw_F,:); ones(1, size(gloveNSamps,2))];
	
	% Second finger calibrate
	map_raw_F	= [8 9 10 11 12 15];
	map_cal_F	= [7 8 9 10];
	calibration(map_cal_F, [map_raw_F 23]) = trueNValue(map_cal_F,:)/[gloveNSamps(map_raw_F,:); ones(1, size(gloveNSamps,2))];
	
	% Ring finger calibrate
	map_raw_F	= [12 13 14 15 19];
	map_cal_F	= [11 12 13 14];
	calibration(map_cal_F, [map_raw_F 23]) = trueNValue(map_cal_F,:)/[gloveNSamps(map_raw_F,:); ones(1, size(gloveNSamps,2))];
	
	% Little finger calibrate
	map_raw_F	= [12 16 17 18 19];
	map_cal_F	= [15 16 17 18 19];
	calibration(map_cal_F, [map_raw_F 23]) = trueNValue(map_cal_F,:)/[gloveNSamps(map_raw_F,:); ones(1, size(gloveNSamps,2))];
	
	% Thumb calibrate
	map_raw_F	= [1 2 3 4 20 21];
	map_cal_F	= [20 21 22 23 24];
	calibration(map_cal_F, [map_raw_F 23]) = trueNValue(map_cal_F,:)/[gloveNSamps(map_raw_F,:); ones(1, size(gloveNSamps,2))];
	
	% Wrist calibrate
	map_raw_F	= [1 20 21 22];
	map_cal_F	= [1 2];
	calibration(map_cal_F, [map_raw_F 23]) = trueNValue(map_cal_F,:)/[gloveNSamps(map_raw_F,:); ones(1, size(gloveNSamps,2))];
	
	%% 	Save Calibration
	save('calibrationSamples','trueValue','gloveSamps','raw_range');
	save('calibration','calibration');
	
	
	
	
elseif(run_mode == 1)
%% RUN EVALUATION ====================================
	load('calibration');
	load('calibrationSamples','raw_range');
	
	%% Normalization (ask user to achive extreme movements)
	if(norm_mode)
		disp('Normalizing glove:: (Press a key when ready)');
		pause();
		disp('Explore the joint limits for next 10 sec.')
		raw_range = [1000*ones(22,1), -1000*ones(22,1)];
		tic
		while(toc<norm_time)
			gloveRaw  = double(staticGloveGetSample(comPort, 115200));
			raw_range(gloveRaw<raw_range(:,1),1) = gloveRaw(gloveRaw<raw_range(:,1));
			raw_range(gloveRaw>raw_range(:,2),2) = gloveRaw(gloveRaw>raw_range(:,2));
		end
		disp('Normalization complete')
	end
	
	
	%% Vizualize raw
	if(plot_mode)
		gloveRaw	= [rand(22,1); 1];
		gloveNRaw	= [rand(22,1); 1];
		
		raw_fig		= figure(2543);
		subplot(211); title('Raw data')
		raw_bar		= bar(gloveRaw);
		axis([-1, 24, 0, 300]);
		subplot(212); title('Raw normalized data')
		rawN_bar	= bar(gloveNRaw);
		axis([-1, 24, 0, 1]);
	end
	
	
	%% vizualize hand
	trace.gloveRaw		= zeros(22,tracesize);
	trace.gloveCalib	= zeros(24,tracesize);
	for iter=1:tracesize
		
		%receive data
		gloveRaw = double(staticGloveGetSample(comPort, 115200));
		
		% normalizing constantly
		raw_range(gloveRaw<raw_range(:,1),1) = gloveRaw(gloveRaw<raw_range(:,1));
		raw_range(gloveRaw>raw_range(:,2),2) = gloveRaw(gloveRaw>raw_range(:,2));
		gloveNRaw = (gloveRaw(1:22)-raw_range(:,1)) ./ (raw_range(:,2)-raw_range(:,1));
		
		% calibrate and enforce limits
		gloveCalib = calibration*([gloveNRaw; 1]);
		gloveCalib(gloveCalib<0) = 0;
		gloveCalib(gloveCalib>1) = 1;
		gloveCalib = gloveCalib.*(m.jnt_range(:,2)-m.jnt_range(:,1)) + m.jnt_range(:,1);
		
		%plots
		if(plot_mode)
			set(raw_bar, 'YData', gloveRaw);
			set(rawN_bar, 'YData', gloveNRaw);
			drawnow;
        end
        
    % projectedGloveCalib = ((gloveCalib-mu')'*(U(:,1)*U(:,1)'))'+mu';
             %mjcPlot(so, projectedGloveCalib, zeros(m.nv,1));
		mjcPlot(so, gloveCalib, zeros(m.nv,1));
		
		%record Trace
		trace.gloveRaw(:,iter) =  gloveRaw;
		trace.gloveCalib(:,iter) = gloveCalib;
	end
end

%% Close and save
mjcClose(so); % close socket to release visualizer
save('Recording','trace')




