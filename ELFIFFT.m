function [] = ELIFFT()
    % Prompt the user for the condition and channels with default values
    prompt = {'Condition','Channels'};
    defaults = {'LabelPre','75', ''};
    promptResponse = inputdlg(prompt,'Condition',1,defaults);
    [condition, channels] = deal(promptResponse{:});
    
    channels = str2num(channels);

    %TODO: Exclude Subjects
    % The subjects to be excluded from the calculations
    %     excludedSubjects = {'5', '11'};

    % Prompt the user for the path to the .set files and find all of that
    % directory's .set files. Also store the number of subjects
    directory = uigetdir(pwd);
    pattern = fullfile(directory,'*.set');
    allFilesInDirectory = dir(pattern);
    setFiles = removeDotUnderscores(allFilesInDirectory);
    %     setFiles = removeExcludedSubjects(setFiles, excludedSubjects);

    % Find the average
    for subjectIndex = 1 : size(setFiles)
        EEG = pop_loadset('filename', setFiles{subjectIndex}{1}, 'filepath', directory);
        EEG = epoch2continuous(EEG);
        [ym, f] = fourieeg(EEG,channels,[],0,7);
        CombinedFiles(subjectIndex,:) = ym;
    end

    AveResponse = mean(CombinedFiles,1);

    BaseSignal = AveResponse(57);
    bnoise = [AveResponse(37:46),AveResponse(47:57)];
    BaseNoise = mean(bnoise);
    BaseRatio = BaseSignal/BaseNoise;
    BaseSNR = mean(BaseRatio);

    OddSignal = AveResponse(21); % Bin 21 is 1.22
    onoise = [AveResponse(11:20),AveResponse(22:31)];
    OddNoise = mean(onoise);
    OddRatio = OddSignal/OddNoise;
    OddSNR = mean(OddRatio);

    disp(BaseSNR);
    disp(OddSNR);

    plot(f,AveResponse);
    % axis([1 7 0 35]); % Change the last number to adjust y-scale
    xlim([1 7]);
    ylim auto
    xlabel('Frequency (Hz)')
    ylabel('Y(f)')
end

%TODO: Fix this
% Function used to remove subjects that the experimenter has specified to
% exclude
% function finalSubjects = removeExcludedSubjects(allSubjects, excludedSubjects)
%     excludedSize = size(excludedSubjects);
%     finalSubjectIndex = 1;
%     for excludedIndex = 1 : excludedSize(2)
%         allSize = size(allSubjects);
%         for allIndex = 1 : allSize(1)
%             currentExcludedSize = size(excludedSubjects{excludedIndex});
%             if ~strcmp(strcat('ELFI_', excludedSubjects{excludedIndex}, '_'), allSubjects{allIndex}{1}(1:(6 + currentExcludedSize(2))))
%                 finalSubjects{finalSubjectIndex} = allSubjects{allIndex}{1};
%                 finalSubjectIndex = finalSubjectIndex + 1;
%             end
%         end
%     end
% end

% Function called to remove files that start with ._
% Depends on countEmptyCells()
function fileNames = removeDotUnderscores(setFiles)
    setFilesWithoutDotUnderscores = cell(size(setFiles));
    newArrayIndex = 1;
    for index = 1 : size(setFiles)
        if ~strcmp(setFiles(index).name(1:2), '._')
            setFilesWithoutDotUnderscores{newArrayIndex} = setFiles(index).name;
            newArrayIndex = newArrayIndex + 1;
        end
    end
    
    emptyCellCount = countEmptyCells(setFilesWithoutDotUnderscores);
    fileNames = cell(size(setFilesWithoutDotUnderscores) - emptyCellCount);
    fileNameIndex = 1;
    for index = 1 : size(setFilesWithoutDotUnderscores)
        if ~isempty(setFilesWithoutDotUnderscores{index})
            fileNames{fileNameIndex} = setFilesWithoutDotUnderscores(index);
            fileNameIndex = fileNameIndex + 1;
        end
    end
    
    fileNames = fileNames';
end

% Returns the number of empty cells in the cell array
function numberOfEmptyCells = countEmptyCells(cellArray)
    numberOfEmptyCells = 0;
    for index = 1 : size(cellArray)
        if isempty(cellArray{index})
            numberOfEmptyCells = numberOfEmptyCells + 1;
        end
    end
end
