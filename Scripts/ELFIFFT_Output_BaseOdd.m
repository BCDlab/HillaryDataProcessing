function [] = ELFIFFT_Output_BaseOdd(channels)
    % Function used to perform Fourier Transforms on EEG data then output the results of each
    % condition into a .csv file.
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost.
    % The .set files must also have their accompanying .fdt files.

    % make sure that the Utilities folder is on the path
    adjustPath();

    [channels, conditionArray, directory, setFiles, nParticipants, concatenateAcrossTrials, plotBySNvFreq, powerOrAmplitude] = promptUserForInputData(channels, 0, 0);

    sizeOfConditionArray = size(conditionArray);
    disp(sizeOfConditionArray);
    disp(nParticipants);
    disp(nParticipants + 1);
    outputArray = cell(nParticipants + 1, sizeOfConditionArray(2) + 1);

    disp(outputArray);
    return;

    % If concatenating, concatenate all then run fourieeg on concatenated data
    if strcmp(concatenateAcrossTrials, 'Yes')
        for subjectIndex = 1 : size(setFiles)
            currentEEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
            if subjectIndex == 1
                mergedEEG = currentEEG;
            else
                mergedEEG = EEG_Combine(mergedEEG, currentEEG);
            end
        end

        [CombinedYMs, f] = fourieeg(mergedEEG, channels,[],0,10);

    % Else combine all ym's during iteration
    else
        for subjectIndex = 1 : size(setFiles)
            EEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
            [ym, f] = fourieeg(EEG, channels, [], 0, 10);
            CombinedSingleChannelFiles(subjectIndex, :) = ym;
        end

        CombinedYMs = CombinedSingleChannelFiles;
    end

    avgResponse = mean(CombinedYMs,1);

    % TODO: Look into if we should be plotting "power" 
    % (amplitude squared) or just amplitude
    if strcmp(powerOrAmplitude, 'Power')
        avgResponse = amplitudeToPower(avgResponse);
    end

    % the starting (x, y) coordinate pair of the annotated text box
    annotationStartPosition = [.4 .7];

    % flush the plot window
    clf('reset');

    if strcmp(plotBySNvFreq, 'Yes')
        % get the signal/noise values across the entire freqency range
        [SN, newF] = getSN_SNVf(avgResponse, f);

        % find data on the maximum signal/noise
        maxNum = -1;
        freqAtMax = -1;
        for i = 1 : size(newF)
            if SN(i) > maxNum
                maxNum = SN(i);
                freqAtMax = newF(i);
            end
        end

        disp(' ');
        disp('Max S/N: ');
        disp(maxNum);
        disp('Freq at which Max S/N occurs: ');
        disp(freqAtMax);

        % Plot the S/N ratio against the frequency
        plot(newF, SN, 'b');
        xlim([1 7]);
        ylim auto;
        ylabel('S/N Ratio');

        % Make an annotated text box for the max Signal/Noise ratio
        dim = [annotationStartPosition(1) annotationStartPosition(2) .3 .1];
        str = ['Max S/N: ', num2str(maxNum), sprintf('\nOccurs at freq: '), num2str(freqAtMax)];
        annotation('textbox', dim, 'String', str);
    else
        % calculate the signal/noise ratios
        [baseSNR, oddSNR] = getSN_ymVf(avgResponse, f);

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
        dim = [annotationStartPosition(1) annotationStartPosition(2) .25 .1];
        str = ['Base S/N: ', num2str(baseSNR), sprintf('\n Odd S/N: '), num2str(oddSNR)];
        annotation('textbox', dim, 'String', str);
    end
end
