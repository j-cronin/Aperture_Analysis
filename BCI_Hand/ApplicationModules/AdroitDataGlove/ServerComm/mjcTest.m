modelFile = 'V:\merge06\Models\Adroit\Adroit.xml';


%% Launch Mujoco vizualizer and connect
so = mjcVizualizer('', '..\');


%% load model
mjcLoadModel(so, modelFile);


%% get model 
model = mjcGetModel(so);


%% plot
J = 0.2*rand(28,1);
V = 0.01*rand(28,1);
tic 
for i=1:1000
	mjcPlot(so, J, V)
end
toc


%% Close connection
mjcClose(so)