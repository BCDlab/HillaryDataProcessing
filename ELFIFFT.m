function [] = ELFIFFT(channels)
    % Function used to perform Fourier Transforms on EEG data
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost

    if isempty(channels)
        disp('Channels are empty, defaulting to 75');
        channels = [75];
    else
        channels = channels';
    end

    % Prompt the user if they want to concatenate
    concatenateAcrossTrials = questdlg('Concatenate across trials?', '', 'Yes', 'No', 'Yes');

    % Prompt the user for the condition
    conditionArray = {'LabelPre', 'LabelPost', 'NoisePre', 'NoisePost'};
    [selectionIndex, leftBlank] = listdlg('PromptString', 'Select a file:',...
                    'SelectionMode', 'single', 'ListString', conditionArray);
    condition = conditionArray{selectionIndex};

    % Prompt the user for the path to the .set files and find all of that
    % directory's .set files. Also store the number of subjects
    directory = uigetdir(pwd);
    pattern = fullfile(directory, '*.set');
    allSetFiles = dir(pattern);
    setFiles = applyConditionFilter(allSetFiles, condition);

    % Exclude the following subjects from the calculations
    setFiles = removeExcludedSubjects(setFiles, {'3', '15'});

    % If concatenating, concatenate all then run fourieeg on concatenated data
    if strcmp(concatenateAcrossTrials, 'Yes')
        for subjectIndex = 1 : size(setFiles)
            currentEEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
            if subjectIndex == 1
                mergedEEG = currentEEG;
            else
                mergedEEG = EEG_combine(mergedEEG, currentEEG);
            end
        end

        [CombinedYMs, f] = fourieeg(mergedEEG, channels,[],0,10);

    % Else combine all ym's as you go along
    else
        for subjectIndex = 1 : size(setFiles)
            EEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
            [ym, f] = fourieeg(EEG, channels, [], 0, 10);
            CombinedSingleChannelFiles(subjectIndex, :) = ym;
        end

        CombinedYMs = CombinedSingleChannelFiles;
    end

    % Flip bool to view all individual channels, useful for selecting channels
    if true
        avgResponse = mean(CombinedYMs,1);
        f = f';
        % CombinedFrequencies = (CombinedFrequencies);
    else
        avgResponse = mean(cell2mat(CombinedYMs),1);
        f = cell2mat(f');
    end

    % TODO: Look into if we should be plotting "power" 
    % (amplitude squared) or just amplitude
    % avgResponse = avgResponse';
    % for i = 1 : size(avgResponse)
    %     avgResponse(i) = sqrt(avgResponse(i));
    %     disp('sqrt');
    % end
    % avgResponse = avgResponse';

    % Prompt the user about how they want to plot the data
    plotByFreqBin = questdlg('Plot S/N for each freq bin?', '', 'Yes', 'No', 'Yes');

    if strcmp(plotByFreqBin, 'Yes')
        sizeOfF = size(f);
        baseSN = zeros(sizeOfF - 11);
        oddSN = zeros(sizeOfF - 11);
        newF = zeros(sizeOfF - 11);
        for freqIndex = 6 : sizeOfF - 6
            baseSignal = avgResponse(freqIndex);
            baseNoise = [avgResponse(freqIndex - 5:freqIndex - 1), avgResponse(freqIndex + 1:freqIndex + 6)];
            baseNoiseMean = mean(baseNoise);
            baseRatio = baseSignal / baseNoiseMean;
            baseSNR = mean(baseRatio);
            newF(freqIndex - 5, 1) = f(freqIndex - 5);
            baseSN(freqIndex - 5, 1) = baseSNR;
        end

        maxNum = -1;
        freqAtMax = -1;
        for i = 1 : size(newF)
            if baseSN(i) > maxNum
                maxNum = baseSN(i);
                freqAtMax = newF(i);
            end
        end        

        for i = 1 : size(newF)
            disp(newF(i));
        end

        disp(' ');
        disp('Max S/N: ');
        disp(maxNum);
        disp('Freq at which Max S/N occurs: ');
        disp(freqAtMax);

        % Plot the S/N ratio against the frequency
        plot(newF, baseSN, 'b');
        xlim([1 7]);
        ylim auto
        ylabel('S/N Ratio')
    else
        % Calulate the Signal/Noise ratio for the base
        baseSignal = avgResponse(100);
        bNoise = [avgResponse(95:99), avgResponse(101:105)];
        baseNoise = mean(bNoise);
        baseRatio = baseSignal/baseNoise;
        baseSNR = mean(baseRatio);

        % Calulate the Signal/Noise ratio for the oddball
        oddSignal = avgResponse(21); % Bin 21 is 1.22
        oNoise = [avgResponse(16:20), avgResponse(22:26)];
        oddNoise = mean(oNoise);
        oddRatio = oddSignal/oddNoise;
        oddSNR = mean(oddRatio);

        % Display the Signal/Noise ratio
        disp(' ');
        disp('Base S/N: ');
        disp(baseSNR);
        disp('Odd S/N');
        disp(oddSNR);

        % Plot the output of the Fourier Transform against the frequency
        plot(f, avgResponse, 'b');
        xlim([1 7]);
        ylim auto
        xlabel('Frequency (Hz)')
        ylabel('Y(f)')

        % Make an annotated text box for the Signal/Noise ratio
        dim = [.6 .7 .25 .1];
        str = ['Base S/N: ', num2str(baseSNR), sprintf('\n Odd S/N: '), num2str(oddSNR)];
        annotation('textbox', dim, 'String', str);
    end
end


% function that concatenates two EEG trials
% credit: Thomas Ferree, UT Southwestern Medical Center, 2007
% url: http://sccn.ucsd.edu/pipermail/eeglablist/2008/002074.html
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
