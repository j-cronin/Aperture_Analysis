% MJCCLOSE   Close connection to Mujoco
%
%  mjcClose(so)
%  so: socket object, passed to all other functions

function mjcClose(so)

% close socket
so.close;
