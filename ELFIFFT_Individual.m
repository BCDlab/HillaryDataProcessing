function [] = ELFIFFT_Individual(channels)
    % Function used to perform Fourier Transforms on EEG data
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost

    if isempty(channels)
        disp('Channels are empty, defaulting to 75');
        channels = 75;
    else
        channels = channels';
    end

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

    % Prompt the user if they want to concatenate
    concatenateAcrossTrials = questdlg('Concatenate across trials?', '', 'Yes', 'No', 'Yes');

    % Prompt the user about how they want to plot the data
    plotByFreqBin = questdlg('Plot S/N for each freq bin?', '', 'Yes', 'No', 'Yes');    

    for subjectIndex = 1 : size(setFiles)
        % flush the plot window
        clf('reset');

        EEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
        [ym, f] = fourieeg(EEG, channels, [], 0, 10);

        % TODO: Look into if we should be plotting "power" 
        % (amplitude squared) or just amplitude
        % ym = ym';
        % for i = 1 : size(ym)
        %     ym(i) = sqrt(ym(i));
        % end
        % ym = ym';

        if strcmp(plotByFreqBin, 'Yes')
            sizeOfF = size(f');
            baseSN = zeros(sizeOfF(1, 1) - 10, 1);
            newF = zeros(sizeOfF(1, 1) - 10, 1);

            for freqIndex = 6 : sizeOfF - 5
                noiseRange = [ym(freqIndex - 5:freqIndex - 1), ym(freqIndex + 1:freqIndex + 5)];
                baseSNR = ym(freqIndex) / mean(noiseRange);
                newF(freqIndex - 5, 1) = f(freqIndex);
                baseSN(freqIndex - 5, 1) = baseSNR;
            end

            maxNum = -1;
            maxNumFreq = -1;
            maxI = -1;
            for i = 1 : size(baseSN)
                if maxNum < baseSN(i)
                    maxNum = baseSN(i);
                    maxNumFreq = newF(i);
                    maxI = i;
                end
            end

            disp(' ');
            disp('Bin 99 S/N: ');
            disp(baseSN(94));
            disp('Max S/N: ');
            disp(maxNum);
            disp('Max S/N occurs at: ');
            disp(maxNumFreq);

            % Plot the S/N ratio against the frequency
            plot(newF, baseSN, 'b');
            xlim([1 7]);
            ylim auto;
            ylabel('S/N Ratio');
            xlabel('Freqency');

            % Make an annotated text box for the max Signal/Noise ratio
            dim = [.29 .67 .32 .15];
            str = ['Bin 99 S/N: ' num2str(baseSN(94)) sprintf('\nMax S/N: ') ...
                    num2str(maxNum) sprintf('\nMax S/N Occurs at: ') num2str(maxNumFreq)];
            annotation('textbox', dim, 'String', str);

            sizeOfSetFileName = size(setFiles{subjectIndex});
            sizeOfSetFileName = sizeOfSetFileName(1, 2);

            % save the plot
            fileName = ['Plots/PerBin/' setFiles{subjectIndex}(1:sizeOfSetFileName - 4) '_SNPerBin'];
            print(fileName, '-dpng');
        else
            % Calulate the Signal/Noise ratio for the base
            baseSignal = ym(99);
            bNoise = [ym(94:98), ym(100:104)];
            baseNoise = mean(bNoise);
            baseRatio = baseSignal/baseNoise;
            baseSNR = mean(baseRatio);

            % Calulate the Signal/Noise ratio for the oddball
            oddSignal = ym(19); % Bin 21 is 1.22
            oNoise = [ym(14:18), ym(20:24)];
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
            plot(f, ym, 'b');
            xlim([1 7]);
            ylim auto
            xlabel('Frequency (Hz)')
            ylabel('Y(f)')

            % Make an annotated text box for the Signal/Noise ratio
            dim = [.4 .7 .25 .1];
            str = ['Base S/N: ', num2str(baseSNR), sprintf('\n Odd S/N: '), num2str(oddSNR)];
            annotation('textbox', dim, 'String', str);

            sizeOfSetFileName = size(setFiles{subjectIndex});
            sizeOfSetFileName = sizeOfSetFileName(1, 2);

            % save the plot  setFiles{subjectIndex}(1:sizeOfSetFileName - 4)
            fileName = ['Plots/SingleBin/' num2str(subjectIndex) '_SNSingleBin'];
            print(fileName, '-dpng');
        end
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
