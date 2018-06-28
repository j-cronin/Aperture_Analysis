function calibrateGlove(comPort,calibFileName)

% 1 = thumb roll
% 2-3 = thumb
% 4 = thumb abad
% 5-7 = index
% 8-10 = middle
% 11 = ind/middle abad
% 12-14 = ring
% 15 = mid/ring abad
% 16-18 = pinkey
% 19 = ring/pink abad
% 20 = pinkey roll
% 21 = wrist flex
% 22 = wrist yaw

    %Loop through com ports
    
    
    validPort = 0;
    if ~exist('comPort')
        for comNum=1:16
            try
                comPort = sprintf('\\\\.\\COM%i',comNum);
                staticGloveGetSample(comPort, 115200);
                validPort = 1;
                break;
            catch
            end
        end
    else
        try
            staticGloveGetSample(comPort, 115200);
            validPort = 1;
        catch
        end
        
    end
    
    if ~exist('calibFileName', 'var')
        calibFileName = input('File name to save calibration file to => ', 's');       
    end
    
    if validPort == 0
        error('Can''t find glove on desired port(s)');
    end
    
    calibRange = zeros(22,2);
    
    plot(calibRange);
    
    %do curl calib first...
    toCalib = [2 3 5 6 7 8 9 10 12 13 14 16 17 18];
    fprintf('Hand flat...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,1) = rawGlove(toCalib);
    fprintf('Ball fist...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,2) = rawGlove(toCalib);
    plot(calibRange);
    
    %now do ab/ad
    toCalib = [4 11 15 19];
    fprintf('Fingers together...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,1) = rawGlove(toCalib);
    fprintf('Splayed...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,2) = rawGlove(toCalib);
    plot(calibRange);
    
    %now do thumb roll
    toCalib = [1];
    fprintf('Thumb out...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,1) = rawGlove(toCalib);
    fprintf('Thumb roll...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,2) = rawGlove(toCalib);
    plot(calibRange);
    
    %now palm/pinkey
    toCalib = [20];
    fprintf('Hand flat...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,1) = rawGlove(toCalib);
    fprintf('Palm roll/pinkey inward...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,2) = rawGlove(toCalib);
    plot(calibRange);
    
    %now thumb
    toCalib = [2 3];
    fprintf('Thumb Extend...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,1) = rawGlove(toCalib);
    fprintf('Thumb in...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,2) = rawGlove(toCalib);
    plot(calibRange);
    
    %wrist up down
    toCalib = [21];
    fprintf('Wrist down...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,1) = rawGlove(toCalib);
    fprintf('Wrist up...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,2) = rawGlove(toCalib);
    plot(calibRange);
    
    %wrist in out
    toCalib = [22];
    fprintf('Wrist flex in...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,1) = rawGlove(toCalib);
    fprintf('Wrist flex out...\n');
    pause;
    rawGlove = double(staticGloveGetSample(comPort, 115200));
    calibRange(toCalib,2) = rawGlove(toCalib);
    plot(calibRange);
    
    gloveGains = zeros(22,1);
    gloveGains([2 3 5 6 7 8 9 10 12 13 14 16 17 18]) = pi/2;
    gloveGains([11 15 19]) = pi / 5;
    gloveGains(4) = pi / 3;
    gloveGains(1) = pi / 4;
    gloveGains(20) = pi / 16;
    gloveGains(21) = 0.1;
    gloveGains(22) = 0.1;
    eval(sprintf('save %s.mat calibRange gloveGains;',calibFileName));
end

