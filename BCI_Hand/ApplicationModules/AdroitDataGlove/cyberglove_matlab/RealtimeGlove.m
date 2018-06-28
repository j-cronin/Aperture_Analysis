function RealtimeGlove(calibRange, gloveGains)

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
    
    if validPort == 0
        error('Can''t find glove on desired port(s)');
    end
    
    
    figure;
    axis equal;
    view(-131, 20);
    set(gca,'xlim',[-120 100]);
    set(gca,'ylim',[-25 330]);
    set(gca,'zlim',[-200 25]);
    
    
    while(1)
        gloveSamps = double(staticGloveGetSample(comPort, 115200));
        DrawHand(gloveSamps,calibRange, gloveGains);
        
        drawnow;
    end
end

