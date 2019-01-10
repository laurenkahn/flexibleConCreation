startSub=1;
endSub=26; 
numRuns = 5; % Adjust as nec
standardCondsPerRun = 8;
leadingZeros = 1; % Set this to 0 if you don't want leading 0s in your sub numbers (e.g. sub-004)
addTrash = 0; % Change this to 1 if you want to add variable # of extra trash regressors per run, per sub

DIR.conInput = '~/Desktop/flexibleConCreation/conInfo';
DIR.conOutput = '~/Desktop/flexibleConCreation/customCons/';

studyFolder = '/Volumes/research/sanlab/Studies/Incentive/';
outputMatName = 'contrastMatrix';
fxSuffix= '_ppi_addl_20141101'; % Change this to specify which model these contrasts are for

% Specify filenames for contrast input
defaultConMatFile = [DIR.conInput filesep 'contrastWeights' fxSuffix '.txt'];
condsRemovedFile = [DIR.conInput filesep 'condsRemoved' fxSuffix '.txt'];
contrastNamesFile = [DIR.conInput filesep 'contrastNames' fxSuffix '.txt'];

% Import sub x cond matrix specifying removed conditions 
condsRemoved = dlmread(condsRemovedFile,'\t'); 

if addTrash
    % Import sub x run matrix specifying how many trash regressors to add per run 
    condsAddedByRun = dlmread(condsAddedByRunFile,'\t'); 
end

% Import default contrast matrix
defaultConMat = dlmread(defaultConMatFile,'\t');
numContrasts = size(defaultConMat,1);

% Generate cell array of contrast names
contrastNames = cell(1,numContrasts);
fid=fopen(contrastNamesFile);
for c=1:numContrasts
    contrastNames{c} = fgets(fid);
end
fclose(fid);

for s=startSub:endSub
    
    % Extract current sub's removed conditions
    currentCondsRemoved = condsRemoved(s,:);
    
    % Adjust defaultConMat by removing columns with missing conditions
    reducedConMat = defaultConMat(:,~currentCondsRemoved);
    
    if addTrash = 1;
        % Initialize final contrast matrix for this sub
        finalConMat = [];
        
        % Starting from reducedConMat, add extra regressors (trash, motion,
        % etc) as necessary
        for r = 1:numRuns
            
            % Determine how many columns remain in run r:
            startCol = 1 + (r-1)*standardCondsPerRun;
            endCol = r*standardCondsPerRun;
            currentRunCondCount = sum(~currentCondsRemoved(startCol:endCol));
            
            % Grab portion of reducedConMat for run r
            currentRunWeights = reducedConMat(:,(startCol:endCol);
            % Append zero regressors for this run to the currentRunWeights
            addedZeroWeights = zeros(numContrasts,condsAddedByRun(s,r));
            expandedRunWeights = horzcat(currentRunWeights,addedZeroWeights);
            % Add this run to the final contrast matrix
            
            finalConMat = horzcat(finalConMat,expandedRunWeights);
        end
    else
        finalConMat = reducedConMat;
    end
    
    % Create cell array with one contrast per cell
    contrastCellArray = mat2cell(finalConMat,ones(1,numContrasts),size(finalConMat,2));
    
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
    save([DIR.conOutput filesep outputMatName '_sub-' placeholder num2str(s) fxSuffix '.mat'],'finalConMat','contrastCellArray','contrastNames')
end