% close all
clear variables


%% User Inputs

% Model to be loaded  ( 'Adroit_Hand' / 'Adroit' )--------
model = 'Adroit';

% Type of actuation  ( 'tendon' / 'joint' )
act     = 'joint';

% Actuation gains
gain_A    = 250;      % Arm
gain_W    = 100;      % Wrist
gain_F    = 35;      % Fingers

% Simmulation count
iter    = 5500;

%% Load Model
mj('load', [model '.xml']);
m = mj('getmodel');

sim = mjplot;

%% Preparations

%traces
tLen    = zeros(m.ntendon, iter);
Jnt     = zeros(m.nq, iter);
dJnt    = zeros(m.nv, iter);
if(strcmpi(act, 'tendon'))
    U    = zeros(m.nu,iter);
    mask = mod(1:m.nu,2)'; % selection Flexors/Extensors
    if(strcmpi(model, 'Adroit_Hand'))
        gain = [gain_W*ones(4,1); gain_F*ones(m.nu-4,1)];
    elseif (strcmpi(model, 'Adroit'))
        gain = [gain_A*[1 1 1 1 2 2 1 1]'; gain_W*ones(4,1); gain_F*ones(m.nu-12,1)];
    end
elseif(strcmpi(act, 'joint'))
    U    = zeros(m.nq,iter);
    mask = 1;
    if(strcmpi(model, 'Adroit_Hand'))
        gain = .01*[gain_W*ones(2,1); gain_F*ones(m.nv-2,1)];
    elseif(strcmpi(model, 'Adroit'))
        gain = .01*[20*gain_A*[1 2 1 1]'; 10*gain_W*ones(2,1); gain_F*ones(m.nv-6,1)];
    end
end

mj reset                        % Reset the state
ctrl = zeros(m.nu,1);


%% Control
figure(sim);

% Example of kinematic positioning
% Random initialization
J0  = m.jnt_range(:,1) + rand(m.njnt,1).*( m.jnt_range(:,2)-m.jnt_range(:,1) );
V0  = randn(m.nv,1);
mj('set','qpos',J0);                % Set data in Mujoco
mj('set','qvel',V0);
mj forward;
mjplot;


%% Example of dynamics.
tic
for i=1:iter
    mj step1;                       % Pre control dynamic steps
    
    % compute controls
    if (mod(i, 1000) ==0)
        disp('switch controls')
        if(strcmpi(act, 'tendon'))
            mask = ~mask;
        elseif(strcmpi(act, 'joint'))
            mask = -1*mask;
        end
    end
    
    % control
    if(strcmpi(act, 'tendon'))
        ctrl = gain.* (mask.*ones(m.nu,1));
        mj('set','ctrl', ctrl);
    elseif(strcmpi(act, 'joint'))
        ctrl = gain.* (mask*ones(m.nq,1));
        mj('set','qfrc_applied', ctrl);
    end
    
    mj step2;
    
    % Save trace
    U(:,i)      = ctrl;
    [tLen(:,i)] = mj('get','ten_length');
    [Jnt(:,i)]  = mj('get','qpos'); % Query Mujoco for data
    [dJnt(:,i)] = mj('get','qvel');
    
    % Visualize
    if (~(mod(i,50)))
        mjplot;                     % Vizualize the state of the model
        drawnow;
    end
end
toc

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
            subaxis(7,4,i, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.02, 'Font', 6);
        catch exception
            subplot(7,4,i)
        end
        plot(-U(i,:),'.-');
        axis auto
        t = title(mj('getname','joint',i-1),'fontsize',6, 'FontWeight', 'bold','Interpreter', 'none', 'BackgroundColor',[1 .25 0]);
    end
end

%%
fprintf('done\n');
% beep