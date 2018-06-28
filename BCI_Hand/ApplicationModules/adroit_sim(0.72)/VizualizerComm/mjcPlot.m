% MJCPLOT provides vizualization
%
%  mjcPlot(so, qpos, qvel)
%
%  so   : socket object returned by mjConnect
%  qpos(optional)   : generalized position
%                   : updated  form mj mex, if not supplied
%  qvel(optional)   : generalized velocities
%                   : updated  form mj mex, if not supplied
%

function mjcPlot(so, qpos, qvel)

if nargin<1
	error('Call with socket_handle obtained using mjConnect(<host>)')
end

try
	if nargin<2
		
		qpos = mj('get','qpos');
		qvel = mj('get','qvel');
		
	elseif nargin<3
		qvel = mj('get','qvel');
	end
catch
	warning('mj not found');
end

% state
state = [qpos; qvel];

% check socket
if ~isa(so, 'java.net.Socket') || ~so.isConnected,
    error('argument must be connected socket obtained from mjConnect');
end

% prepare data stream
sz = typecast(int32(length(state(:))), 'uint8');
bytes = typecast(double(state(:)), 'uint8');

% ask Mujoco to receive state, send data
output = so.getOutputStream;
output.write(2);
output.write(sz);
output.write(bytes);
