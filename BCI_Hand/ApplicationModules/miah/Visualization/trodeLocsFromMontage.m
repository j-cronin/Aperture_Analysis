% subject is encoded subject ID
% Montage is a montage from a given recording (or set of recordings)
function locs = trodeLocsFromMontage(subject, Montage, isTail)
    if (~exist('isTail','var'))
        isTail = false;
    end
    
    base = getSubjDir(subject);
    
    if (~isTail)
        load([base '\trodes.mat']);
    else
        load([base '\tail_trodes.mat']);
    end
    
    locs = [];
    
    for token = Montage.MontageTokenized
        [name, idxStr] = processToken(token{:});
        eval(sprintf('trodesOfInterest = %s(%s, :);', name, idxStr));
        locs = [locs; trodesOfInterest];
    end
end

function [name, idxStr] = processToken(token)
    inpar = strfind(token, '(');
    outpar = strfind(token, ')');
    
    name = token(1:(inpar-1));
    idxStr = token((inpar+1):(outpar-1));
end