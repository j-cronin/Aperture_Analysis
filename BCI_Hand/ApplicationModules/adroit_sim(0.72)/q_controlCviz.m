close all
clear variables
addpath('VizualizerComm')

%% User Inputs

% Model to be loaded
model = 'Adroit_Hand';
act	  = 'joint';

% Actuation gains
gain_A    = 250;     % Arm
gain_W    = 100;     % Wrist
gain_F    = 35;      % Fingers

%vizualizer comp ip
vizIP   = ''; % localhost
vizDir  = ''; % local


%% Launch Mujoco vizualizer and connect
so = mjcVizualizer(vizIP, vizDir);


%% Load Model in vizualizer and in matlab
mjcLoadModel(so, [model '.xml']);
mj('load', [model '.xml']);
m = mj('getmodel');
mjcPlot(so);


%% Load calibration
CM		= csvread('Adroit_gripcurve.txt');


%% Preparations

iter    = size(CM,2);
U		= zeros(m.nq,iter);
gainP	= 1*[gain_W*ones(2,1); gain_F*ones(m.nv-2,1)];
gainD	= -0.4*ones(m.nv, 1);


%traces
tLen    = zeros(m.ntendon, iter);
Jnt     = zeros(m.nq, iter);
dJnt    = zeros(m.nv, iter);


%% Initialize
mj reset				% Reset the state

% Random initialization of hand
J0  = m.jnt_range(:,1) + rand(m.njnt,1).*( m.jnt_range(:,2)-m.jnt_range(:,1) );
V0  = randn(m.nv,1);
mj('set','qpos',J0);	% Set data in Mujoco
mj('set','qvel',V0);
mj forward;
mjcPlot(so, J0, V0);


%% Start controls
tic
for i=1:iter
	
	% Get your synergies 
	syn = i;		% update this from the BCI packet
	qdes = CM(:,syn);
		
    mj step1;       % Pre control dynamic steps
     
    % control
	q = mj('get', 'qpos');
	e = qdes - q;
	qdot = mj('get', 'qvel');
	ctrl = gainP.* e + gainD.*qdot;
	mj('set','qfrc_applied', ctrl);
	
    mj step2;		% Pre control dynamic steps
    
    % Save trace
    U(:,i)      = ctrl;
    [tLen(:,i)] = mj('get','ten_length');
    [Jnt(:,i)]  = mj('get','qpos');
    [dJnt(:,i)] = mj('get','qvel');
    
    % Visualize
    if (~(mod(i,8)))
        mjcPlot(so, Jnt(:,i), dJnt(:,i)); % Vizualize the state of the model
    end
end
toc


%% Close connection
mjcClose(so);



















%% FINALIZE AND PLOT TRACE

%% plot tendons
fig_t = figure(334);clf
set(gcf,'name','Tendons', 'NumberTitle','off');
for i = 1:m.ntendon
    try
        subaxis(11,4,i, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.02, 'Font', 6);
    catch exception
        subplot(11,4,i)
    end
    plot(tLen(i,:));
    t = title(mj('getname','tendon',i-1),'fontsize',6, 'FontWeight', 'bold','Interpreter', 'none', 'BackgroundColor','yellow');
    hold on;
    line([1, iter], [m.tendon_range(i,1) m.tendon_range(i,1)], 'Color',[1 0 0]);
    line([1, iter], [m.tendon_range(i,2) m.tendon_range(i,2)], 'Color',[1 0 0]);
end


%% plot joints and joint vel
fig_j = figure(347);clf
set(gcf,'name','Joints', 'NumberTitle','off');
for i = 1:m.nq
    try
        subaxis(6,4,i, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.02, 'Font', 6);
    catch exception
        subplot(6,4,i);
    end
    plot(0.1*dJnt(i,:),'g');
    hold on;
	line([1, iter], +.1*[m.dof_maxvel(i) m.dof_maxvel(i)], 'Color',[0 .5 0], 'LineStyle',':');
    line([1, iter], -.1*[m.dof_maxvel(i) m.dof_maxvel(i)], 'Color',[0 .5 0], 'LineStyle',':');
	
    plot(Jnt(i,:),'LineWidth',2);
	plot(CM(i,:),'LineWidth',1, 'Color',[0 0 1], 'LineStyle',':');
    axis auto
    t = title(mj('getname','joint',i-1),'fontsize',6, 'FontWeight', 'bold','Interpreter', 'none','BackgroundColor','green');
    line([1, iter], [m.jnt_range(i,1) m.jnt_range(i,1)], 'Color',[1 0 0]);
    line([1, iter], [m.jnt_range(i,2) m.jnt_range(i,2)], 'Color',[1 0 0]);
	
end


%% plot controls
fig_u = figure(356);clf
if(strcmpi(act, 'tendon'))
    set(gcf,'name','Tendon forces', 'NumberTitle','off');
    for i = 1:m.nu
        try
            subaxis(10,4,i, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.02, 'Font', 6);
        catch exception
            subplot(10,4,i)
        end
        plot(-U(i,:),'.-');
        hold on
        line([1, iter], [m.actuator_forcerange(i,1) m.actuator_forcerange(i,1)], 'Color',[1 0 0], 'LineWidth', 3);
        line([1, iter], [m.actuator_forcerange(i,2) m.actuator_forcerange(i,2)], 'Color',[1 0 0], 'LineWidth', 3);
        
        axis auto
        t = title(mj('getname','actuator',i-1),'fontsize',6, 'FontWeight', 'bold','Interpreter', 'none','BackgroundColor',[0 .75 1]);
    end
elseif(strcmpi(act,'joint'))
    set(gcf,'name','Joint torques', 'NumberTitle','off');
    for i = 1:m.nq
        try
            subaxis(6,4,i, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.02, 'Font', 6);
        catch exception
            subplot(6,4,i)
        end
        plot(-U(i,:),'.-');
        axis auto
        t = title(mj('getname','joint',i-1),'fontsize',6, 'FontWeight', 'bold','Interpreter', 'none', 'BackgroundColor',[1 .25 0]);
    end
end

%%
fprintf('done\n');
% beep