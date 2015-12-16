function [ pos_shuffled, entersTarget, averageChanceAccuracy, std_chance] = aper_chanceAccuracy(data, data_interp, high_boundary, low_boundary)
%Computes the chance accuracy value, starting from when subject first
%enters the target range
%   Detailed explanation goes here

accuracyChance = zeros(1000,1);

% Determine when subject first enters the target range - that will be
% used as the starting point
entersTarget = find(data < high_boundary & data > low_boundary, 1); % + startSamp-1;

% Either use diff of the interp signal or tne non-interp signal:
% dx = diff(data_interp(entersTarget:end));
dx = diff(data(entersTarget:end)); % Using the non-interpolated data for the diff because it results in a more varied random walk
pos_shuffled = zeros(length(dx)+1, 1000);

for i=1:1000
    pos_shuffled(:,i)= cumsum([data(entersTarget) dx(randi(length(dx), size(dx)))']); % drawing with replacement
  
    % Calculate the accuracy
    accuracyChance(i, 1) = sum(pos_shuffled(:,i) < high_boundary(entersTarget:end) & pos_shuffled(:,i) > low_boundary(entersTarget:end))/length(pos_shuffled(:,i));
end

averageChanceAccuracy = mean(accuracyChance);
std_chance = std(accuracyChance); 

%% Plot
figure
plot(pos_shuffled(:,1), 'b')
hold on
plot(high_boundary(entersTarget:end),'r')
plot(low_boundary(entersTarget:end),'r')
title('Shuffled position in blue');
end

