function [] = ELIFFT()
    % Prompt the user for the condition
    conditionArray = {'LabelPre', 'LabelPost', 'NoisePre', 'NoisePost'};
    [selectionIndex, leftBlank] = listdlg('PromptString','Select a file:',...
                    'SelectionMode','single', 'ListString',conditionArray);
    condition = conditionArray{selectionIndex};
    
    % Prompt the user for the channels
    prompt = {'Channels'};
    defaults = {'75'};
    promptResponse = inputdlg(prompt,'',1,defaults);
    [channels] = deal(promptResponse{:});
    channels = str2num(channels);

    % Prompt the user for the path to the .set files and find all of that
    % directory's .set files. Also store the number of subjects
    directory = uigetdir(pwd);
    pattern = fullfile(directory,'*.set');
    allSetFiles = dir(pattern);
    setFiles = applyConditionFilter(allSetFiles, condition);

    % Find the average
    for subjectIndex = 1 : size(setFiles)
        EEG = pop_loadset('filename', setFiles(subjectIndex).name, 'filepath', directory);
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
    xlim([1 7]);
    ylim auto
    xlabel('Frequency (Hz)')
    ylabel('Y(f)')
end

% function that removes all .set files that are not of the specified condition
function filteredFiles = applyConditionFilter(unfilteredFiles, condition)
    filteredArraySize = 0;
    for i = 1 : size(unfilteredFiles)
        if ~isempty(strfind(unfilteredFiles(i).name, condition))
            filteredArraySize = filteredArraySize + 1;
            matchingIndices(:, filteredArraySize) = i;
        end
    end

    if filteredArraySize == 0
        error(['Could not find any set files matching the condition: ', condition]);
    end
    
    for i = 1 : filteredArraySize
        filteredFiles(:, i) = unfilteredFiles(matchingIndices(i));
    end

    % transpose the vector
    filteredFiles = filteredFiles';
    return;
end
