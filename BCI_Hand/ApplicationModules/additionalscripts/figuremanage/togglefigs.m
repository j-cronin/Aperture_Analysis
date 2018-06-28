function togglefigs(N)
%SHOWMETHEFIGS     Allow user to cycle between all figures by hitting any key
%
% INPUT: (optional)
%   N = number of times to cycle through
%     Default = 1
%      -1 - Effectively infinite loop. 
%           Break with ctrl-C (I know it ain't pretty)
%   N can also be a vector, specifying the figure numbers in
%    the order to be viewed

% Scott Hirsch
% shirsch@mathworks.com

figs=sort(get(0,'Children'));		%ordered list of figures

if nargin==0
   N=-1;
end;

if length(N)>1
   figs=N;
   N=1;
elseif N<0
   N=99999;
end;

res=get(0,'ScreenSize');
ii=1;
for jj=1:N    
    if ishandle(figs(ii))
        figure(figs(ii))
        set(gcf,'Position',[1 1 res(3) res(4)-64]); %Leave room for title bar

        pause
        if (strcmp(get(gcf,'CurrentKey'),'escape'))
            break;
        elseif (strcmp(get(gcf,'CurrentKey'),'leftarrow'))&&(ii>1)
            ii=ii-1;
        elseif (strcmp(get(gcf,'CurrentKey'),'rightarrow'))&&(ii<length(figs))
            ii=ii+1;
        end
    end;
end
  
end

% for jj=1:N
%     for ii=1:length(figs)
%         if ishandle(figs(ii))
%             figure(figs(ii))
%             pause
%             if (strcmp(get(gcf,'CurrentKey'),'escape'))
%                 break;
%             elseif (strcmp(get(gcf,'CurrentKey'),'leftarrow'))&&(ii>1)
%                 ii=ii-2;
%             end
%         end;
%     end
%     if (strcmp(get(gcf,'CurrentKey'),'escape'))
%         break;
%     end
% end

