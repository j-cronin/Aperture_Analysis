% MJCVIZUALIZER Launch the wx vizualizer
%
%  so = mjcVizualizer(vizIP, vizDir)
%
%  so               : socket object to the vizualizer returned by mjConnect
%  vizIP(optional)  : IP of the computer running the vizualizer
%                   : Localhost, if not specified
%  vizDir(optional) : path from pwd to the Mujoco.exe
%    		

function so = mjcVizualizer(vizIP, vizDir)

if(nargin<1)
    vizIP = '';
    vizDir ='';
elseif (nargin<2)
    vizDir ='';
end

% check if vizualizer is active
so = mjcConnect(vizIP);

% if inactive, launch and connect
if(isempty(so))
	disp('No free visualizer found. Starting a new visualizer');
    system(['start ' vizDir 'Mujoco.exe']);
    pause(1);
    so = mjcConnect(vizIP);
	disp('Connected to the new vizualizer')
else
	disp('Connected to a already runing Vizualizer');
end