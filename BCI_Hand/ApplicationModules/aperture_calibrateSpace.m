function [apertureMovements, raw_range, apertureVector, mu, min_aperture_position, max_aperture_position] = aperture_calibrateSpace(calibration, tracesize, normalize, raw_range)
disp('Aperture movements: (Press a key when ready)');
pause();
disp('Open and close hand for the next 20 sec.');


%%
running_aperture = 0;

[apertureMovements, raw_range]= glove_trace(calibration, tracesize, plot_mode, normalize, raw_range, running_aperture);

% gloveApertureMovements_raw = trace.gloveRaw;
% gloveApertureMovements_calib = trace.gloveCalib;

%% Determine the primary movement vector for projection
[centeredGloveAp, mu] = center(apertureMovements.gloveCalib');
[U,S,V] = svd(centeredGloveAp');
apertureVector = U(:,1);

%% Check that the aperture vector is going in the correct direction
load('openAperturePosition.mat');
if  acos(dot(apertureVector, openAperturePosition)/(norm(apertureVector)*norm(openAperturePosition))) < 1.5
    disp('acos = ')
    acos(dot(apertureVector, openAperturePosition)/(norm(apertureVector)*norm(openAperturePosition)))
    apertureVector = apertureVector*(-1);
    disp('Flipped apertureVector');
end

%% Determine min and max
aperture_position_gloveApertureMovements = zeros(1, length(apertureMovements.gloveCalib));
for k=1:length(apertureMovements.gloveCalib)
    aperture_position_gloveApertureMovements(1,k) = (apertureMovements.gloveCalib(:,k)-mu')'*apertureVector;
end
min_aperture_position = min(aperture_position_gloveApertureMovements);
max_aperture_position = max(aperture_position_gloveApertureMovements);

end