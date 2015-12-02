function [channels, condition, directory, setFiles, nParticipants, concatenateAcrossTrials, plotBySNvFreq, powerOrAmplitude, singleBinSNR, binRangeOffset] = promptUserForInputData(channels, promptConditions, promptConcat, promptSNvFreq)
	% Function that handles prompting the user for input data common
	% across several data processing scripts.
    %
    % Note: second and third input parameters are optional and default to 1

    if nargin == 1
        promptConditions = 1;
        promptSNvFreq = 1;
        promptConcat = 1;
    elseif nargin == 2
        promptConcat = 1;
        promptSNvFreq = 1;
    elseif nargin == 3
        promptSNvFreq = 1;
    end

    excludedSubjects = {'3', '15'};

	if isempty(channels)
        disp('Channels are empty, defaulting to 75');
        channels = 75;
    else
        channels = channels';
    end

    % Prompt the user for the path to the .set files and find all of that
    % directory's .set files. Also store the number of subjects
    directory = uigetdir('../Data');
    pattern = fullfile(directory, '*.set');
    allSetFiles = dir(pattern);

    % Prompt the user for the condition if requested, else pick one and all return all conditions as well
    % as all set files
    conditionArray = {'LabelPre', 'LabelPost', 'NoisePre', 'NoisePost'};
    if promptConditions
        [selectionIndex, leftBlank] = listdlg('PromptString', 'Select a file:',...
                        'SelectionMode', 'single', 'ListString', conditionArray);
        condition = conditionArray{selectionIndex};
        setFiles = applyConditionFilter(allSetFiles, condition);
        nParticipants = size(setFiles);
        nParticipants = nParticipants(1, 1);
    else
        condition = conditionArray;
        tempSetFiles = applyConditionFilter(allSetFiles, condition{1});
        sizeTempFiles = size(tempSetFiles);
        sizeExcludedSubjects = size(excludedSubjects);
        nParticipants = sizeTempFiles(1) - sizeExcludedSubjects(1);
        setFiles = allSetFiles;
    end

    % Exclude the following subjects from the calculations
    setFiles = removeExcludedSubjects(setFiles, excludedSubjects);

    if isempty(setFiles)
        error('No .set files found matching your input parameters');
    end

    % Prompt the user if they want to concatenate
    if promptConcat == 1
        concatenateAcrossTrials = questdlg('Concatenate across trials?', '', 'Yes', 'No', 'Yes');
    else
        concatenateAcrossTrials = 'No';
    end

    % Prompt the user about how they want to plot the data
    if promptSNvFreq
        plotBySNvFreq = questdlg('Plot S/N for each freq bin?', '', 'Yes', 'No', 'Yes');
    else
        plotBySNvFreq = '';
    end

    % Prompt the user if they want to plot power or amplitude
    powerOrAmplitude = questdlg('Plot Power or Amplitude?', '', 'Amplitude', 'Power', 'Amplitude');

    if strcmp(plotBySNvFreq, 'No')
        % Prompt the user if they want to use a single bin for the SNR
        singleBinSNR = questdlg('Use a single bin for SNR calculations?', '', 'Yes', 'No', 'Yes');
    else
        singleBinSNR = '';
    end

    if strcmp(singleBinSNR, 'No')
        % Prompt the user if they want to use immediately adjacent bins to calculate S/N
        binRangeOffset = inputdlg('Enter the bin offset for SNR calculations:');
        binRangeOffset = str2num(binRangeOffset{1});
    else
        binRangeOffset = 0;
    end

end