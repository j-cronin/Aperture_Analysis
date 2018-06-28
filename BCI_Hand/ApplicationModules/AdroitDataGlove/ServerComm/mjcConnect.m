% MJCCONNECT   Connect to Mujoco
%
%  so = mjcConnect(host)
%
%  so: socket object, passed to all other functions
%
%  host: name or ip address of host where Mujoco is running (type 'string')
%      : if not supplied or is empty, defaults to local machine

function so = mjcConnect(host)

if nargin<1 || isempty(host)
	address = java.net.InetAddress.getLocalHost;
	IPaddress = char(address.getHostAddress);
	host = IPaddress;
end

% open socket, set options
try 
    so = java.net.Socket(host,50000);
    so.setTcpNoDelay(1);
    so.setSoTimeout(5000);
catch
    so = [];
end