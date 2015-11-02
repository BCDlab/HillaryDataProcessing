function [channels, condition, directory, setFiles, concatenateAcrossTrials, plotBySNvFreq, powerOrAmplitude] = promptUserForInputData(channels)
	% Function that handles prompting the user for input data common
	% across several data processing scripts

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
    directory = uigetdir('../Data');
    pattern = fullfile(directory, '*.set');
    allSetFiles = dir(pattern);
    setFiles = applyConditionFilter(allSetFiles, condition);

    % Exclude the following subjects from the calculations
    setFiles = removeExcludedSubjects(setFiles, {'3', '15'});

    if isempty(setFiles)
        error('No .set files found matching your input parameters');
    end

    % Prompt the user if they want to concatenate
    concatenateAcrossTrials = questdlg('Concatenate across trials?', '', 'Yes', 'No', 'Yes');

    % Prompt the user about how they want to plot the data
    plotBySNvFreq = questdlg('Plot S/N for each freq bin?', '', 'Yes', 'No', 'Yes');

    % Prompt the user if they want to plot power or amplitude
    powerOrAmplitude = questdlg('Plot Power or Amplitude?', '', 'Amplitude', 'Power', 'Amplitude');
end