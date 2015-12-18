filenames = dir('C:\Users\jiwu\Desktop\r2_analysis');
filenames = {filenames(~[filenames.isdir]).name};

r2netresults = zeros(27, 4);
mccount = 100;


i = 1; % use this as the .mat counter
for fi = 1:numel(filenames) % fi increments even if it isn't a .mat!!!
    if(strcmp(filenames{fi}(end-3:end),'.mat'))
        disp(['Running ' filenames{fi}])
        load(filenames{fi})
        namepieces = regexp(filenames{fi}(1:end-4), '_', 'split');
    
        switch(namepieces{1})
            case 'ecb43e'
                r2netresults(i, 1) = 1;
            case 'cdceeb'
                r2netresults(i, 1) = 2;
            case 'fca96e'
                r2netresults(i, 1) = 3;
        end
        
        r2netresults(i, 2) = str2double(namepieces{4});
        
        mdl = LinearModel.fit(center_boundary, data_entered);
        r2netresults(i, 3) = mdl.Rsquared.Ordinary;
                
        shuffleresults = zeros(mccount, 1);
        parfor j = 1:mccount
            mdls = LinearModel.fit(center_boundary, phaseshuffle(data_entered));
            shuffleresults(j) = mdls.Rsquared.Ordinary;
            fprintf('%d ', j);
        end
        fprintf('\n');
        r2netresults(i, 4) = mean(shuffleresults);
        
        i = i+1;
    end
end

r2netresults = sortrows(r2netresults, [1 2]);