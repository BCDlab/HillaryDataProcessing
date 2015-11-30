function [] = ELFIFFT(channels)
    % Function used to perform Fourier Transforms on EEG data across multiple participants.
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost.
    % The .set files must also have their accompanying .fdt files.
    %
    % Potential Channes:
    % right (76 83) 84 90
    % left  (70 71) 65 66

    % make sure that the Utilities folder is on the path
    adjustPath();

    % Prompt the user for input parameters
    [channels, condition, directory, setFiles, nParticipants, concatenateAcrossTrials, plotBySNvFreq, powerOrAmplitude, singleBinSNR]...
        = promptUserForInputData(channels);

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

        [CombinedYMs, f] = fourieegWindowed(mergedEEG, channels,[],0,10);

    % Else combine all ym's during iteration
    else
        for subjectIndex = 1 : size(setFiles)
            EEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
            [ym, f] = fourieegWindowed(EEG, channels, [], 0, 10);
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
        bin = -1;
        for i = 1 : size(newF)
            if SN(i) > maxNum
                maxNum = SN(i);
                freqAtMax = newF(i);
                bin = i;
            end
        end

        disp(' ');
        disp('Max S/N: ');
        disp(maxNum);
        disp('Freq at which Max S/N occurs: ');
        disp(freqAtMax);
        disp('Base SN: ');
        disp(SN(94));
        disp('Odd SN: ');
        disp(SN(14));

        % Plot the S/N ratio against the frequency
        scatter(newF, SN, 'b', '.');
        drawNonInterpolatedLines(SN, newF);
        xlim([1 7]);
        ylim auto;
        ylabel('S/N Ratio');

        % Make an annotated text box for the max Signal/Noise ratio
        dim = [annotationStartPosition(1) annotationStartPosition(2) .25 .1];
        str = ['Base S/N: ', num2str(SN(94)), sprintf('\nOdd S/N: '), num2str(SN(14))];
        annotation('textbox', dim, 'String', str);
    else
        % calculate the signal/noise ratios
        [baseSNR, oddSNR] = getSN_ymVf(avgResponse, f, singleBinSNR);

        % Display the Signal/Noise ratio
        disp(' ');
        disp('Base S/N: ');
        disp(baseSNR);
        disp('Odd S/N');
        disp(oddSNR);

        disp(f(92));
        disp(f(106));

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
