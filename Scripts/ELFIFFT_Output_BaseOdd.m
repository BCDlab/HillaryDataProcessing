function [] = ELFIFFT_Output_BaseOdd(channels)
    % Function used to perform Fourier Transforms on EEG data then output the results of each
    % condition into a .csv file.
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost.
    % The .set files must also have their accompanying .fdt files.

    % make sure that the Utilities folder is on the path
    adjustPath();

    % Prompt the user for input parameters
    [channels, conditionArray, directory, setFiles, nParticipants, concatenateAcrossTrials, plotBySNvFreq, powerOrAmplitude]...
        = promptUserForInputData(channels, 0, 0, 0);

    % Create a blank cell array with the proper dimensions to output the table into
    sizeOfConditionArray = size(conditionArray);
    nConditions = 2 * sizeOfConditionArray(2);
    nRows = nParticipants + 1;
    nCols = nConditions + 1;
    outputArray = cell(nRows, nCols);

    % Insert the column headers into outputArray
    outputArray = makeHeaderRow(outputArray);

    for conditionIndex = 1 : nConditions
        currSetFiles = findAllSetFilesWithCondition(setFiles, conditionArray{conditionIndex});
        sizeOfCurrSetFiles = size(currSetFiles);
        nCurrSetFiles = sizeOfCurrSetFiles(1, 2);
        for setFileIndex = 1 : nCurrSetFiles
            currParticipantNumber = getParticipantNumber(currSetFiles{setFileIndex});
            return;
        end
    end

    for subjectIndex = 1 : size(setFiles)
        for conditionIndex = 1 : nConditions
            % currentSetFiles = 
            EEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
            [ym, f] = fourieeg(EEG, channels, [], 0, 10);

            % TODO: Look into if we should be plotting "power" 
            % (amplitude squared) or just amplitude
            if strcmp(powerOrAmplitude, 'Power')
                ym = amplitudeToPower(ym);
            end


        end
    end
end

function out = findAllSetFilesWithCondition(setFiles, condition)
    sizeOfSetFiles = size(setFiles);
    nSetFiles = sizeOfSetFiles(1);
    outIndex = 1;
    out = {};
    for setFileIndex = 1 : nSetFiles
        if strfind(setFiles{setFileIndex}, condition)
            out = [out setFiles{setFileIndex}];
            outIndex = outIndex + 1;
        end
    end
end

function participantNumber = getParticipantNumber(setFileName)
    participantStr = '';
    currChar = setFileName(1);
    charIndex = 1;
    while ~strcmp(currChar, '_')
        charIndex = charIndex + 1;
        currChar = setFileName(charIndex);
    end

    charIndex = charIndex + 1;
    currChar = setFileName(charIndex);

    while ~strcmp(currChar, '_')
        participantStr = [participantStr currChar];
        charIndex = charIndex + 1;
        currChar = setFileName(charIndex);
    end

    participantNumber = str2num(participantStr);
end

function outputArray = makeHeaderRow(outputArray)
    outputArray{1, 1} = 'Participant';
    outputArray{1, 2} = 'LabelPreBase';
    outputArray{1, 3} = 'LabelPreOdd';
    outputArray{1, 4} = 'LabelPostBase';
    outputArray{1, 5} = 'LabelPostOdd';
    outputArray{1, 6} = 'NoisePreBase';
    outputArray{1, 7} = 'NoisePreOdd';
    outputArray{1, 8} = 'NoisePostBase';
    outputArray{1, 9} = 'NoisePostOdd';
end