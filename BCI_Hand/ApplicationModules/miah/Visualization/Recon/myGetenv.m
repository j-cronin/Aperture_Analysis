%% myGetenv.m
% THIS IS PART OF THE MIAH COMPATIBILITY LAYER
%
function value = myGetenv(name)
    value = getenv(name);
    
%     if (length(value) < 1)
%         if (exist('setupEnvironment.m', 'file') == 2)
%             setupEnvironment;
%             value = getenv(name);    
%         else
%             error(['The getting and setting of bci group environment '...
%                    'variables requires that you have a m-file on your '...
%                    'path called setupEnvironment.m that sets both '...
%                    'matlab_devel_dir and subject_dir corresponding '...
%                    'to your environment settings.  See setupEnvironment.m.example']);
%         end
%     end
end