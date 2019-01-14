% Subject info
startSub=1;
endSub=26;
nSubs = endSub - startSub + 1;
leadingZeros = 1; % Set this to 0 if you don't want leading 0s in your sub numbers (e.g. sub-004)

% Run info
nRuns = 5; % Adjust as nec
standardCondsPerRun = 4; % In the example, correct go, correct stop, failed stop, + cue

% Adding trash by condition or run
nCondTrash = 1; % Change to 0 if no trash per cond (common cond trash: time derivatives)
nRunTrash = 5; % Change to 0 if no trash per run (common run trash: motion)
addCustomTrash = 0; % Change this to 1 if you want to add variable # of extra trash regressors per run, per sub

condsPerRun_wCondTrash = standardCondsPerRun*(nCondTrash+1);
standardNCols = nRuns*standardCondsPerRun;

% Change this to the folder where your condsRemoved (output from makeVecs), contrastNames, and
% contrastWeights files live:
DIR.conInput = '~/Desktop/flexibleConCreation/conInfo'; 
% Change this to the folder where you want your custom contrast output
% files to live:
DIR.conOutput = '~/Desktop/flexibleConCreation/customCons/';

outputFilename = 'customContrasts';
analysis = 'basic'; % Change this to specify which model these contrasts are for
task = 'template'; % Change this to your task name (part of input filenames)
% analysis = 'prepost_analysis';
% task = 'gng';

mkdir([DIR.conOutput filesep task filesep analysis]);

% Specify filenames for contrast input
defaultConMatFile = [DIR.conInput filesep 'contrastWeights_' task '_' analysis '.txt'];
condsRemovedFile = [DIR.conInput filesep 'condsRemoved_' task '_' analysis '.txt'];
condsAddedByRunFile = [DIR.conInput filesep 'condsAddedByRun.txt'];
contrastNamesFile = [DIR.conInput filesep 'contrastNames_' task '_' analysis '.txt'];

% Import sub x cond matrix specifying removed conditions
condsRemoved = dlmread(condsRemovedFile,'\t');

if addCustomTrash
    % Import sub x run matrix specifying how many trash regressors to add per run
    condsAddedByRun = dlmread(condsAddedByRunFile,'\t');
end

% Import default contrast matrix
defaultConMat = dlmread(defaultConMatFile,'\t');
nContrasts = size(defaultConMat,1);

% Generate cell array of contrast names
contrastNames = cell(1,nContrasts);
fid=fopen(contrastNamesFile);
for c=1:nContrasts
    contrastNames{c} = fgets(fid);
end
fclose(fid);

% EDIT defaultConMat to include cond + run trash, for ease of user
% (deal with smaller default contrast matrix)

if nCondTrash > 0 % If you want to intersperse trash after each condition:
    defaultConMat_wCondTrash = nan(nContrasts,standardNCols*(nCondTrash+1));
    defaultConMat_wCondTrash(:,1:(nCondTrash+1):end) = defaultConMat;
    for i = 1:nCondTrash
        % We use intersperse columns of 0s since trash conditions are not included in contrasts
        defaultConMat_wCondTrash(:,(1+i):(nCondTrash+1):end) = 0;
    end
    defaultConMat = defaultConMat_wCondTrash;
end

% Expand the currentCondsRemoved variable to include run trash
if nRunTrash > 0
    defaultConMat_wRunTrash = [];
    for r=1:nRuns
        startCol = 1 + (r-1)*condsPerRun_wCondTrash;
        endCol = r*condsPerRun_wCondTrash;
        defaultConMat_wRunTrash = horzcat(defaultConMat_wRunTrash,defaultConMat(:,startCol:endCol),zeros(nContrasts,nRunTrash));
    end
    defaultConMat = defaultConMat_wRunTrash;
end

% FOR EACH SUBJECT:
% (1) Extract their row of condsRemoved
% (2a) Adjust it based on condTrash (intersperse to indicate trash conditions following each condition)
% (2b) Adjust it based on runTrash (add sets of 1s following each run)
% (3a) Use it to reduce their imported defaultConMat, which will include cond + run trash.
% (3b) Optional: adjust reducedConMat based on custom trash per run, per person.

for s=startSub:endSub
    
    % Extract current sub's removed conditions (one row of condsRemoved)
    currentCondsRemoved = condsRemoved(s,:);
    currentCondsRemoved(isnan(currentCondsRemoved))=1; % change NaN to 1 (=removed)
    
    % Expand the currentCondsRemoved variable to include cond trash
    
    if nCondTrash > 0 %If you want to intersperse trash after each condition:
        currentCondsRemoved_wCondTrash = nan(1,length(currentCondsRemoved)*(nCondTrash+1));
        currentCondsRemoved_wCondTrash(1:(nCondTrash+1):end) = currentCondsRemoved;
        for i = 1:nCondTrash
            % We use currentCondsRemoved to intersperse, so that we remove a trash
            % condition associated with a removed condition, but retain
            % a trash condition associated with a retained condition:
            currentCondsRemoved_wCondTrash((1+i):(nCondTrash+1):end) = currentCondsRemoved;
        end
        currentCondsRemoved = currentCondsRemoved_wCondTrash;
    end
    
    % Expand the currentCondsRemoved variable to include run trash
    if nRunTrash > 0
        currentCondsRemoved_wRunTrash = [];
        for r=1:nRuns
            startCol = 1 + (r-1)*condsPerRun_wCondTrash;
            endCol = r*condsPerRun_wCondTrash;
            
            % Add nRunTrash 0s to retain trash for runs retained
            % Add nRunTrash 1s to remove trash for runs removed
            % First determine whether a run is retained:
            runEntries = currentCondsRemoved(startCol:endCol);
            runRetained = find(~runEntries); % is TRUE if you find a 0 entry in this run (a retained condition); if not, FALSE
            if runRetained
                currentCondsRemoved_wRunTrash = horzcat(currentCondsRemoved_wRunTrash,currentCondsRemoved(startCol:endCol),zeros(1,nRunTrash));
            else
                currentCondsRemoved_wRunTrash = horzcat(currentCondsRemoved_wRunTrash,currentCondsRemoved(startCol:endCol),ones(1,nRunTrash));
            end
        end
        currentCondsRemoved = currentCondsRemoved_wRunTrash;
    end
    
    
    % Reduce defaultConMat by removing columns with missing conditions
    reducedConMat = defaultConMat(:,~currentCondsRemoved);
    
    if addCustomTrash;
        % Initialize final contrast matrix for this sub
        finalConMat = [];
        
        % Starting from reducedConMat, add extra regressors (trash, motion,
        % etc) as necessary
        for r = 1:nRuns
            
            % Determine how which columns remain in run r:
            priorColCount = sum(~currentCondsRemoved(1:standardCondsPerRun*(r-1)));
            startCol = priorColCount + 1;
            defaultStartCol = 1 + (r-1)*standardCondsPerRun;
            defaultEndCol = r*standardCondsPerRun;
            currentRunCondCount = sum(~currentCondsRemoved(defaultStartCol:defaultEndCol));
            endCol = priorColCount + currentRunCondCount;
            
            % Grab portion of reducedConMat for run r
            currentRunWeights = reducedConMat(:,(startCol:endCol));
            % Append zero regressors for this run to the currentRunWeights
            addedZeroWeights = zeros(nContrasts,condsAddedByRun(s,r));
            expandedRunWeights = horzcat(currentRunWeights,addedZeroWeights);
            % Add this run to the final contrast matrix
            
            finalConMat = horzcat(finalConMat,expandedRunWeights);
        end
    else
        finalConMat = reducedConMat;
    end
    
    % Scale appropriately for missing conditions
    for con = 1:nContrasts
        currentCon = finalConMat(con,:);
        isPos = currentCon>0;
        isNeg = currentCon<0;
        posSum = sum(currentCon(isPos));
        negSum = abs(sum(currentCon(isNeg))); % Makes neg sum is POS so that it simply scales and does not flip sign!
        
        % Scale positive side
        currentCon(isPos) = currentCon(isPos)/posSum;
        % Scale negative side, if it exists (won't for >Rest contrasts)
        if negSum > 0
            currentCon(isNeg) = currentCon(isNeg)/negSum;
        end
        finalConMat(con,:) = currentCon;
    end
    
    % Create cell array with one contrast per cell
    contrastCellArray = mat2cell(finalConMat,ones(1,nContrasts),size(finalConMat,2));
    
    if leadingZeros
        if s<10
            placeholder = '00';
        elseif s<100
            placeholder = '0';
        else placeholder = '';
        end
    else placeholder = '';
    end
    
    % Save individual subject's subConMat and contrastNames
    save([DIR.conOutput filesep task filesep analysis filesep outputFilename '_sub-' placeholder num2str(s) '_' task '_' analysis '.mat'],'finalConMat','contrastCellArray','contrastNames')
end