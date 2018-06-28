% MJCGETSTATE   load model file in Mujoco
%
%  state = mjLoadModel(so, modelFile)
%
%  so: socket object returned by mjConnect
%  modelFile: fileName with path relative to Mujoco.exe location
%    		

function mjcLoadModel(so, modelFile)

% check socket
if ~isa(so, 'java.net.Socket') || ~so.isConnected,
    error('argument must be connected socket obtained from mjConnect');
end

% prepare data stream
modelFile(end+1) = 0;
sz = typecast(int32(length(modelFile(:))), 'uint8');
bytes = uint8(char(modelFile(:)));

% ask Mujoco to receive state, send data
output = so.getOutputStream;
output.write(1);
output.write(sz);
output.write(bytes);
pause(1);