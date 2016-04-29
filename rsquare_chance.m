function [ rsq_mean, rsq_std ] = rsquare_chance( x, pos_shuffled )
%RSQUARE_CHANCE takes already shuffled data and computes the mean chance
%value for R-squared along with the standard deviation of all of the chance
%values

rsq = zeros(1, size(pos_shuffled,2));
parfor i=1:length(rsq)
    rsq(i) = lmrsquare(x, pos_shuffled(:,i));    
end

rsq_mean = mean(rsq);
rsq_std = std(rsq);
end