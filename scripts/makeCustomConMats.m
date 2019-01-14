startSub=1;
endSub=26; 
nRuns = 5; % Adjust as nec
standardCondsPerRun = 4; % In the example, correct go, correct stop, failed stop, + cue
leadingZeros = 1; % Set this to 0 if you don't want leading 0s in your sub numbers (e.g. sub-004)
addCustomTrash = 0; % Change this to 1 if you want to add variable # of extra trash regressors per run, per sub
addStandardTrash = 1;
nTrashPerCond = 1; % Change to 0 if no trash per cond (common cond trash: time derivatives)
nTrashPerRun = 3; % Change to 0 if no trash per run (common run trash: motion)
nSubs = endSub - startSub + 1;

condsPerRun_wCondTrash = standardCondsPerRun + nCondTrash;
standardNCols = nRuns*standardCondsPerRun;

DIR.conInput = '~/Desktop/flexibleConCreation/conInfo';
DIR.conOutput = '~/Desktop/flexibleConCreation/customCons/';

studyFolder = '/Volumes/research/sanlab/Studies/Incentive/';
outputFilename = 'customContrasts';
analysis = 'basic'; % Change this to specify which model these contrasts are for
task = 'template';
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
    
    % Expand the currentCondsRemoved variable to include standard trash
    if addStandardTrash
        
        if nStandardCondTrash > 0 %If you want to intersperse trash after each condition:
            currentCondsRemoved_addCondTrash = nan(length(currentCondsRemoved)*(nTrashPerCond+1));
            currentCondsRemoved_addCondTrash(1:(nTrashPerCond+1):end) = currentCondsRemoved;
            for i = 1:nStandardCondTrash 
                % We use currentCondsRemoved to intersperse, so that we remove a trash
                % condition associated with a removed condition, but retain
                % a trash condition associated with a retained condition:
                currentCondsRemoved_addCondTrash((1+i):(nTrashPerCond+1):end) = currentCondsRemoved; 
            end
            currentCondsRemoved = currentCondsRemoved_addCondTrash;
        end
        
        if nStandardRunTrash > 0
            currentCondsRemoved_addRunTrash = [];
            for r=1:nRuns
                startCol = 1 + (r-1)*condsPerRun_wCondTrash;
                endCol = r*condsPerRun_wCondTrash;
                % If all run entries are 1 (run removed), this will fail.
                runEntries = currentCondsRemoved(startCol:endCol);
                runRetained = find(~runEntries); % find a 0 entry in this run (a retained condition)
                if runRetained
                    currentCondsRemoved_addRunTrash = horzcat(currentCondsRemoved_addRunTrash,currentCondsRemoved(startCol:endCol),zeros(1,nRunTrash));
                else
                    currentCondsRemoved_addRunTrash = horzcat(currentCondsRemoved_addRunTrash,currentCondsRemoved(startCol:endCol),ones(1,nRunTrash));
                end
            end
            currentCondsRemoved = currentCondsRemoved_addRunTrash;
        end
    
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
    
    % DO CUSTOM CONTRAST NAMES NEED TO BE CREATED TOO?? 
    
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