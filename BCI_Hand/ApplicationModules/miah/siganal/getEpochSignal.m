%% getEpochSignal.m
%  jdw - 19JUN2011
%
% Changelog:
%   19JUN2011 - originally written
%
% This function breaks signal in to epoch based chunks as specified by 
%   starts and ends.  
%
% Parameters:
%   signal - a vector length M containing the signal to break in to epochs.
%   starts - a vector containing the start offsets of each epoch
%   ends - a vector containing the end offsets of each epoch
%
% Return Values:
%   epochSignal - a matrix containing the signal, divided in to epochs.
%

function epochSignal = getEpochSignal(signal, starts, ends)
%     if (size(signal,2) ~= 1) 
%         warning('2(+)-D matrix passed for signal, ignoring all but first column');
%         while (size(signal, 2) ~= 1)
%             signal = squeeze(signal(:, 1));
%         end
%     end
    if(length(starts) ~= length(ends))
        error('starts and ends must be of same length');
    end
    if (max(ends-starts) ~= min(ends-starts))
        error('epochs of variable length, cannot break in multi-d array');
    end

    if (isempty(starts))
        epochSignal = [];
        return;
    end
    
    epochSignal = zeros(ends(1)-starts(1), size(signal,2), length(starts));
    
    for c = 1:length(starts)
        epochSignal(:,:,c) = signal(starts(c):ends(c)-1,:);
    end; clear c;
end