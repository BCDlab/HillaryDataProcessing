function [] = ELFIFFT_Output_BaseOdd(channels)
    % Function used to perform Fourier Transforms on EEG data then output the results of each
    % condition into a .csv file.
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost.
    % The .set files must also have their accompanying .fdt files.
    %
    % NOTE: THIS FUNCTION IS NOT FINISHED YET

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
            currentSetFiles = findAllSetFilesWithCondition(conditionArray(conditionIndex));
            for setFileIndex = 1 : size(currentSetFiles)
                EEG = pop_loadset('filename', currentSetFiles{setFileIndex}, 'filepath', directory);
                [ym, f] = fourieeg(EEG, channels, [], 0, 10);
            end

            % TODO: Look into if we should be plotting "power" 
            % (amplitude squared) or just amplitude
            if strcmp(powerOrAmplitude, 'Power')
                ym = amplitudeToPower(ym);
            end


        end
    end
end

function outputArray = makeHeaderRow(outputArray)
    % Function that makes the header row in the output array

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