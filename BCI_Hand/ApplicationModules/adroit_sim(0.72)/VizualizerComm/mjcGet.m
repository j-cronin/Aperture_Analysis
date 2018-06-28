% MJCGET Get data from Mujoco
%
%  data = mjcGet(so)
%
%  so:		socket object returned by mjConnect
%  id:		communication id
%  size:	size of data to receive
%  type:	data type

function data = mjcGet(so, id, size, type)

% Check socket's health
if ~isa(so, 'java.net.Socket') || ~so.isConnected,
	error('argument must be connected socket obtained from mjConnect');
end

% Ask Mujoco to send data
so.getOutputStream.write(id);
input = so.getInputStream;

if(isempty(size))
	% read data size
	bytes = zeros(1, 4, 'uint8');
	for i=1:4
		b = input.read;
		bytes(i) = uint8(b);
	end
	size  = double(typecast(bytes(1:4), 'int32'));
end

% Read data stream
if(strcmp(type, 'mjtNum'))
	sizeOfType = 8;
	type='double';
elseif(strcmp(type, 'int'))
	sizeOfType = 4;
	type='int32';
end

bytes = zeros(1, size*sizeOfType, 'uint8');
for i=1:size*sizeOfType
	b = input.read;
	bytes(i) = uint8(b);
end

% Convert
data = double(typecast(bytes, type));

% make sure we read everything
if so.getInputStream.available>0,
	error('Mujoco is sending too much data');
end