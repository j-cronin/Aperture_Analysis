% LocateCyberGlove	:: Finds the port on which the glove is located. 
% **NOTE**			:: Only the first call gives you are correct answer.
% 
% Input				
%		scanPort(opt): which port to check
% Output			
% 		comPort		: com port number, if found
% 					: Nan, if comport not found

function comPort = LocateCyberGlove(scanPort)

comPort = nan;

if (nargin==0)
	scanPort=1:16;
end

%Loop through com ports
for i = scanPort
	try
		icomPort = sprintf('\\\\.\\COM%i',i);
		staticGloveGetSample(icomPort, 115200);
		comPort = icomPort;
		break;
	catch
	end
end

if isnan(comPort)
	warning('Can''t find glove');
end