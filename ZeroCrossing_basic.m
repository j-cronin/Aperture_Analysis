function [locsPos, locsNeg] = ZeroCrossing_basic(X)
%ZeroCrossing identifies the number of times and the locations at which the
%signal, X, crosses zero (changes from positive to negative)
%   ZeroCrossing will return both the number of times the signal crosses
%   zero and the indeces of the array at which the signal crossses zero.
%   The 'location' input controls whether the function returns the high or
%   low index of the crossing (i.e., when the signal crosses 0 it may never
%   actually equal 0, therefore the function can return the index of the
%   array just before it crosses 0, or just after)

% Actually location will always be high - explain why here

dir = zeros(size(X));
dir(X>0) = 1;
dir(X<0) = -1;
% figure
% plot(dir)
% hold on

theZeros = find(dir==0);
consec = find(diff(theZeros)~=1); % Find when there aren't zeros in a row

if ~isempty(theZeros) && ~isempty(consec)
    disp('enter')
    if theZeros(1)~=1
        if dir(theZeros(1)-1) == dir(theZeros(consec(1))+1)
            dir(theZeros(1):theZeros(consec(1))) = dir(theZeros(1)-1);
        end
    end
    for i=2:length(consec)
        if dir(theZeros(consec(i-1)+1)-1) == dir(theZeros(consec(i))+1)
            dir(theZeros(consec(i-1)+1):theZeros(consec(i))) = dir(theZeros(consec(i-1)+1)-1);
        end
    end
    if length(dir)>theZeros(end)
        if dir(theZeros(consec(end)+1)-1) == dir(theZeros(end)+1)
            dir(theZeros(consec(end)+1)-1:theZeros(end)+1) = dir(theZeros(consec(end)+1)-1);
        end
    end
end

pos = dir(1:end-1)<dir(2:end) & dir(2:end)~=0;
neg = dir(1:end-1)>dir(2:end) & dir(2:end)~=0;

% Add 0 to the front of the array and shift pos and neg down, so that
% locations correspond to the actual zero crossings in array 
pos = cat(1, 0, pos);
neg = cat(1, 0, neg);

locsPos = find(pos==1); % locsPos is when you cross from negative to positive
locsNeg = find(neg==1); % locsNeg is when you cross from positive to negative


%plot(dir, 'r')
% plot(pos, 'b')
% plot(neg, 'g')

end



