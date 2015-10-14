function [] = ELFIFFT(channels)
    if isempty(channels)
        channels = [75];
    else
        channels = channels';
    end

    concatenateAcrossTrials = questdlg('Concatenate across trials?','','Yes', 'No', 'Yes');

    % Prompt the user for the condition
    conditionArray = {'LabelPre', 'LabelPost', 'NoisePre', 'NoisePost'};
    [selectionIndex, leftBlank] = listdlg('PromptString','Select a file:',...
                    'SelectionMode','single', 'ListString',conditionArray);
    condition = conditionArray{selectionIndex};

    % Prompt the user for the path to the .set files and find all of that
    % directory's .set files. Also store the number of subjects
    directory = uigetdir(pwd);
    pattern = fullfile(directory,'*.set');
    allSetFiles = dir(pattern);
    setFiles = applyConditionFilter(allSetFiles, condition);

    % Exclude the following subjects from the calculations
    setFiles = removeExcludedSubjects(setFiles, {''});

    if strcmp(concatenateAcrossTrials, 'Yes')
        for channelIndex = 1 : size(channels)
            for subjectIndex = 1 : size(setFiles)
                currentEEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
                if subjectIndex == 1
                    mergedEEG = currentEEG;
                else
                    mergedEEG = EEG_combine(mergedEEG, currentEEG);
                end
            end

            [ym, f] = fourieeg(mergedEEG,channels(channelIndex),[],0,10);

            CombinedSingleChannelFiles(subjectIndex,:) = ym;
            CombinedFrequencies{:,channelIndex} = f;
            CombinedFiles{:,channelIndex} = CombinedSingleChannelFiles;
        end
    else
        for channelIndex = 1 : size(channels)
            for subjectIndex = 1 : size(setFiles)
                EEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
                [ym, f] = fourieeg(EEG,channels(channelIndex),[],0,10);
                CombinedSingleChannelFiles(subjectIndex,:) = ym;
            end

            CombinedFrequencies{:,channelIndex} = f;
            CombinedFiles{:,channelIndex} = CombinedSingleChannelFiles;
        end
    end

    % flip bool to view all individual channels
    if true 
        AveResponse = mean(cell2mat(CombinedFiles'),1);
        CombinedFrequencies = cell2mat(CombinedFrequencies');
    else
        AveResponse = mean(cell2mat(CombinedFiles),1);
        CombinedFrequencies = cell2mat(CombinedFrequencies);
    end

    BaseSignal = AveResponse(100);
    bnoise = [AveResponse(95:99),AveResponse(101:105)];
    BaseNoise = mean(bnoise);
    BaseRatio = BaseSignal/BaseNoise;
    BaseSNR = mean(BaseRatio);

    OddSignal = AveResponse(21); % Bin 21 is 1.22
    onoise = [AveResponse(16:20),AveResponse(22:26)];
    OddNoise = mean(onoise);
    OddRatio = OddSignal/OddNoise;
    OddSNR = mean(OddRatio);

    disp(' ');
    disp('Base S/N: ');
    disp(BaseSNR);
    disp('Odd S/N');
    disp(OddSNR);

    plot(CombinedFrequencies, AveResponse, 'b');
    dim = [.6 .7 .25 .1];
    str = ['Base S/N: ', num2str(BaseSNR), sprintf('\n Odd S/N: '), num2str(OddSNR)];
    annotation('textbox',dim,'String',str);
    xlim([1 7]);
    ylim auto
    xlabel('Frequency (Hz)')
    ylabel('Y(f)')
end


% function that concatenates two EEG trials
% credit: Thomas Ferree, UT Southwestern Medical Center, 2007
% http://sccn.ucsd.edu/pipermail/eeglablist/2008/002074.html
function EEG = EEG_combine(EEG1, EEG2)
    % error catching
    if EEG1.pnts ~= EEG2.pnts
        error('Number of time points must be equal.');
    end
    if EEG1.nbchan ~= EEG2.nbchan
        error('Number of channels must be equal.');
    end
    if EEG1.xmin ~= EEG2.xmin
        error('Starting times must be equal.');
    end

    display(['Combining ' EEG1.setname ' and ' EEG2.setname '.']);

    EEG = EEG1;
    EEG.trials = EEG1.trials + EEG2.trials;
    EEG.data = zeros(EEG.nbchan,EEG.pnts,EEG.trials);
    EEG.data(:,:,1:EEG1.trials) = EEG1.data;
    EEG.data(:,:,EEG1.trials+1:EEG.trials) = EEG2.data;
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


% Function used to remove subjects that the experimenter has specified to exclude
function finalSubjects = removeExcludedSubjects(allSubjects, excludedSubjects)
    numberOfNonMatches = 0;
    numberOfExcludedSubjects = size(excludedSubjects');
    numberOfExcludedSubjects = numberOfExcludedSubjects(1);
    for excludeIndex = 1 : numberOfExcludedSubjects
        currentExcludedSubject = strcat('ELFI_', excludedSubjects{excludeIndex}, '_');
        for allIndex = 1 : size(allSubjects)
            if strfind(allSubjects(allIndex).name, currentExcludedSubject)
                allSubjects(allIndex).name = '';
            else
                numberOfNonMatches = numberOfNonMatches + 1;
            end
        end
    end

    finalSubjects = removeBlankStrings(allSubjects, numberOfNonMatches ./ numberOfExcludedSubjects)';
end


% Function used to remove all cells that are blank from the passed array
function out = removeBlankStrings(in, numberOfNonMatches)
    out = cell(1, numberOfNonMatches);
    outIndex = 1;
    for index = 1 : size(in)
        if ~strcmp(in(index).name, '')
            out{outIndex} = in(index).name;
            outIndex = outIndex + 1;
        end
    end

    % remove blank cells if there are any left over for some reason
    out = out(~cellfun('isempty', out));
end
