function [num, locsPos, locsNeg] = ZeroCrossing(X)
%ZeroCrossing identifies the number of times and the locations at which the
%signal, X, crosses zero (changes from positive to negative)
%   ZeroCrossing will return both the number of times the signal crosses
%   zero and the indeces of the array at which the signal crossses zero.
%   The 'location' input controls whether the function returns the high or
%   low index of the crossing (i.e., when the signal crosses 0 it may never
%   actually equal 0, therefore the function can return the index of the
%   array just before it crosses 0, or just after)

% TO-DO:
% Actually location will always be high - explain why here....

dir = zeros(size(X));
dir(X>0) = 1;
dir(X<0) = -1;

zero = find(dir==0);
if length(zero)>1
    disp('in')
    for i=1:length(zero)-1
        if zero(i)+1 == zero(i+1)
            dir(zero(i)) = dir(zero(i)-1);
        end
        if dir(zero(i)-1)==dir(zero(i)+1)
            disp('inside 2nd');
            dir(zero(i))=dir(zero(i)-1);
        end
    end
    if  dir(zero(end)-1)==dir(zero(end)+1)
        dir(zero(end))=dir(zero(end)-1);
    end
end

% for i=1:(length(dir)-1)
%     if dir(i)~=dir(i+1) && dir(i)~=0 && dir(i+1)~=0 && isequal('location','high')
%         dir(i+1)=0;
%     elseif dir(i)~=dir(i+1) && dir(i)~=0 && dir(i+1)~=0 && isequal('location','low')
%         dir(i)=0;
%     end
% end

for i=1:(length(dir)-1)
    if dir(i)== -1 && dir(i+1)== 1
        dir(i+1)=0;
    elseif dir(i)== 1 && dir(i+1)== -1
        dir(i+1)=0;
    end
end



locsPos = dir(1:end-1)<dir(2:end)

locsPos = find % change from -1 to 1
locsNeg = % change from 1 to -1
locs = find(dir==0);
num = length(locs);

end

