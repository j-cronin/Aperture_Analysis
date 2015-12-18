function [ rsq_mean, rsq_std ] = rsquare_chance( x, pos_shuffled )
%RSQUARE_CHANCE takes already shuffled data and computes the mean chance
%value for R-squared
%   Detailed explanation goes here

rsq = zeros(1, size(pos_shuffled,2));
parfor i=1:length(rsq)
    rsq(i) = lmrsquare(x, pos_shuffled(:,i));    
end

rsq_mean = mean(rsq);
rsq_std = std(rsq);
end