function [] = ELFIFFT_Output_CSV(channels)
    % Function used to perform Fourier Transforms on EEG data then output the results of each
    % condition into a .csv file.
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost.
    % The .set files must also have their accompanying .fdt files.
    % 
    % This script requires and will automatically create the following directory structure:
    %
    %   HillaryDataProcessing |----Output
    %

    % Make sure that the Utilities folder is on the path
    adjustPath();

    % Make sure the output directory has been created
    createDirectoryStructure();

    % Prompt the user for their version of Excel
    excelYear = inputdlg({'Enter your Excel year'}, 'Excel Prompt', 1, {'2007'});

    % Prompt the user for input parameters
    [channels, conditionArray, directory, setFiles, nParticipants, concatenateAcrossTrials,...
        plotBySNvFreq, powerOrAmplitude, singleBinSNR, binRangeOffset, binRangeWidth]...
        = promptUserForInputData(channels, 0, 1, 0);

    % Create a blank cell array with the proper dimensions to output the table into
    sizeOfConditionArray = size(conditionArray);
    nConditions = sizeOfConditionArray(2);
    nRows = nParticipants + 1;
    nCols = (nConditions * 2) + 1;
    outputArray = cell(nRows - 1, nCols); % TODO: Look into why nRows isn't right

    % Insert the column headers into outputArray
    outputArray = makeHeaderRow(outputArray);

    outputArray = insertParticipantNumbers(outputArray, setFiles, conditionArray);

    % If concatenating, concatenate all then run fourieeg on concatenated data
    if strcmp(concatenateAcrossTrials, 'Yes')
        disp('Concatenation not yet implemented. Exiting.');
        return;
    else
        for conditionIndex = 1 : nConditions
            currCondition = conditionArray{conditionIndex};
            currSetFiles = findAllSetFilesWithCondition(setFiles, currCondition);
            sizeOfCurrSetFiles = size(currSetFiles);
            nCurrSetFiles = sizeOfCurrSetFiles(1, 2);
            for setFileIndex = 1 : nCurrSetFiles
                currentSetFile = currSetFiles{setFileIndex};
                currParticipantNum = getParticipantNumber(currentSetFile);

                EEG = pop_loadset('filename', currSetFiles{setFileIndex}, 'filepath', directory);
                [ym, f] = fourieegWindowed(EEG, channels, [], 0, 10);

                % TODO: Look into if we should be plotting "power" 
                % (amplitude squared) or just amplitude
                if strcmp(powerOrAmplitude, 'Amplitude')
                    ym = powerToAmplitude(ym);
                end

                [base, odd] = getBaseAndOdd(ym);
                [baseSN, oddSN, baseNoise, oddNoise] = getSN_ymVf(ym, f, 'Yes', binRangeOffset, binRangeWidth);% 0 because the bin range offset is zero (changed to 5 for offset), 5 because the bin range width is 5

                outputArray = insertAllIntoOutputArray(outputArray, currParticipantNum, currCondition, base, baseSN, baseNoise, odd, oddSN, oddNoise);
            end
        end
    end

    cell2csv('ELFIFFT_Output_BaseOdd.csv', outputArray, ',', excelYear{1}, '.');
    movefile('ELFIFFT_Output_BaseOdd.csv', '../Output/ELFIFFT_Output_BaseOdd.csv');
    disp(' ');
    disp('Data processing completed successfully!');
    disp('CSV file saved to /HillaryDataprocessing/Output/');
end

function [] = createDirectoryStructure()
    % Checks to make sure that the /Data directory exists, and makes it if it doesn't

    if exist('../Output') == 0
        disp('Creating directory: /Output');
        mkdir('../Output');
    end
end

function outputArray = insertAllIntoOutputArray(outputArray, participantNum, condition, base, baseSN, baseNoise, odd, oddSN, oddNoise)
    % Function that inserts all data into the outputArray appropriately - used to keep the code neat
    outputArray = insertValueIntoOutputArray(outputArray, participantNum, [condition 'Base'], base);
    outputArray = insertValueIntoOutputArray(outputArray, participantNum, [condition 'BaseSN'], baseSN);
    outputArray = insertValueIntoOutputArray(outputArray, participantNum, [condition 'BaseNoise'], baseNoise);
    outputArray = insertValueIntoOutputArray(outputArray, participantNum, [condition 'Odd'], odd);
    outputArray = insertValueIntoOutputArray(outputArray, participantNum, [condition 'OddSN'], oddSN);
    outputArray = insertValueIntoOutputArray(outputArray, participantNum, [condition 'OddNoise'], oddNoise);
end

function outputArray = insertValueIntoOutputArray(outputArray, participantNum, condition, value)
    % Function used to fill a cell in the outputArray based on the current participant and condition
    
    sizeOfOutputArray = size(outputArray);
    row = -1;
    col = -1;

    % find the correct row, error if not found
    for index = 1 : sizeOfOutputArray(1, 1)
        if strcmp(outputArray{index, 1}, num2str(participantNum))
            row = index;
        end
    end

    if row == -1
        error(['No row in output array with participant number: ' num2str(participantNum)]);
    end

    % find the correct column, error if not found
    for index = 1 : sizeOfOutputArray(1, 2)
        if strcmp(outputArray{1, index}, condition)
            col = index;
        end
    end

    if col == -1
        error(['No column in output array with condition: ' condition]);
    end

    outputArray{row, col} = value;
end

function outputArray = insertParticipantNumbers(outputArray, setFiles, conditionArray)
    % Function creates the first column with participant numbers in the outputArray

    currSetFiles = findAllSetFilesWithCondition(setFiles, conditionArray{1});
    sizeOfCurrSetFiles = size(currSetFiles);
    nCurrSetFiles = sizeOfCurrSetFiles(1, 2);
    for setFileIndex = 1 : nCurrSetFiles
        currParticipantNumber = getParticipantNumber(currSetFiles{setFileIndex});
        outputArray{setFileIndex + 1, 1} = num2str(currParticipantNumber);
    end
end

function outputArray = makeHeaderRow(outputArray)
    % Function that makes the header row in the output array

    outputArray{1, 1} = 'Participant';
    outputArray{1, 2} = 'LabelPreBase';
    outputArray{1, 3} = 'LabelPreOdd';
    outputArray{1, 4} = 'LabelPreBaseSN';
    outputArray{1, 5} = 'LabelPreOddSN';
    outputArray{1, 6} = 'LabelPreBaseNoise';
    outputArray{1, 7} = 'LabelPreOddNoise';
    outputArray{1, 8} = 'LabelPostBase';
    outputArray{1, 9} = 'LabelPostOdd';
    outputArray{1, 10} = 'LabelPostBaseSN';
    outputArray{1, 11} = 'LabelPostOddSN';
    outputArray{1, 12} = 'LabelPostBaseNoise';
    outputArray{1, 13} = 'LabelPostOddNoise';
    outputArray{1, 14} = 'NoisePreBase';
    outputArray{1, 15} = 'NoisePreOdd';
    outputArray{1, 16} = 'NoisePreBaseSN';
    outputArray{1, 17} = 'NoisePreOddSN';
    outputArray{1, 18} = 'NoisePreBaseNoise';
    outputArray{1, 19} = 'NoisePreOddNoise';
    outputArray{1, 20} = 'NoisePostBase';
    outputArray{1, 21} = 'NoisePostOdd';
    outputArray{1, 22} = 'NoisePostBaseSN';
    outputArray{1, 23} = 'NoisePostOddSN';
    outputArray{1, 24} = 'NoisePostBaseNoise';
    outputArray{1, 25} = 'NoisePostOddNoise';
end
