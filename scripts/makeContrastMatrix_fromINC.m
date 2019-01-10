numSubs=26; % Adjust as nec
numRuns = 5; % Adjust as nec
minCondPerRun = 8; % This will change with different fx models; 4 for corrStop, corrGo, failedStop, cue
motionThresh = 1.5;
studyFolder = '/Volumes/research/sanlab/Studies/Incentive/';
outputMatName = 'contrastMatrix';
fxSuffix= '_ppi_addl_20141101'; % Change this to '_noCues', '', '_wSusRegs', etc
if numSubs<10
    placeholder='00';
elseif numSubs<100
    placeholder='0';
else placeholder='';
end

trashPerRun = dlmread([studyFolder 'compiledResults/upToINC' placeholder num2str(numSubs) '/trashCount.txt'],'\t');
spikesPerRun = dlmread([studyFolder '/motion/spikeCount_' num2str(motionThresh) 'mm.txt'],'\t');

% Generate default contrast matrix
defaultContrastMatrix = dlmread([studyFolder 'info/contrastWeights' fxSuffix '.txt'],'\t');
numContrasts = size(defaultContrastMatrix,1);

% Generate cell array of contrast names
contrastNames = cell(1,numContrasts);
fid=fopen([studyFolder 'info/contrastNames' fxSuffix '.txt']);
for c=1:numContrasts
    contrastNames{c} = fgets(fid);
end
fclose(fid);

%%%% MAKE BASIC CONTRAST MATRIX

for s=1:numSubs
    
    % Initialize contrast matrix, assuming no extra trash or motion
    % regressors
    contrastMatrix = defaultContrastMatrix;
    
    % Calculate how many additional conds per run
    additionalConds = nan(1,numRuns);
    for r=1:numRuns
        
        % Adjust for trash
        if ~(isnan(trashPerRun(s,r)))
            additionalConds(r) = 1;
        else
            additionalConds(r) = 0;
        end
        
        % Adjust for motion
        additionalConds(r) = additionalConds(r) + spikesPerRun(s,r);
    end
    
    
    % Adjust contrastMatrix for additional conds calculated above
    adjustedContrastMatrix = [];
    for r = 1:numRuns
        currentRunWeights = contrastMatrix(:,(1+(r-1)*minCondPerRun):(r*minCondPerRun));
        % Add zero regressors for this run to the currentRun
        additionalZeroWeights = zeros(numContrasts,additionalConds(r));
        adjustedRunWeights = horzcat(currentRunWeights,additionalZeroWeights);
        % Add this run to the adjusted contrast matrix
        adjustedContrastMatrix = horzcat(adjustedContrastMatrix,adjustedRunWeights);
    end
    
    contrastCellArray = mat2cell(adjustedContrastMatrix,ones(1,numContrasts),size(adjustedContrastMatrix,2));
    
    % Save individual subject's contrastMatrix and contrastNames
    if s<10
        placeholder = '00';
    elseif s<100
        placeholder = '0';
    else placeholder = '';
    end
    save(['/Volumes/research/sanlab/Studies/Incentive/subjects/INC' placeholder num2str(s) '/fx/regressors/' outputMatName fxSuffix '.mat'],'adjustedContrastMatrix','contrastCellArray','contrastNames')
end