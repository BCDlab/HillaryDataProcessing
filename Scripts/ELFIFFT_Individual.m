function [] = ELFIFFT_Individual(channels)
    % Function used to perform Fourier Transforms on a single participant's EEG data
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost.
    % The .set files must also have their accompanying .fdt files

    % make sure that the Utilities folder is on the path
    adjustPath();
    
    % Prompt the user for input parameters
    [channels, condition, directory, setFiles, concatenateAcrossTrials, plotBySNvFreq, powerOrAmplitude] = promptUserForInputData(channels);

    % the starting (x, y) coordinate pair of the annotated text box
    annotationStartPosition = [.29 .67];

    % The path to the Plots folder
    plotsDirectory = '../Plots/';

    for subjectIndex = 1 : size(setFiles)

        % flush the plot window
        clf('reset');

        % obtain the EEG data and perform a fourier transform on it
        EEG = pop_loadset('filename', setFiles{subjectIndex}, 'filepath', directory);
        [ym, f] = fourieeg(EEG, channels, [], 0, 10);

        % TODO: Look into if we should be plotting power (amplitude squared) or just amplitude
        % for now, just prompt user
        if strcmp(powerOrAmplitude, 'Power')
            ym = amplitudeToPower(ym);
        end

        % if we are plotting SN vs freq
        if strcmp(plotBySNvFreq, 'Yes')
            [SN, newF] = getSN_SNVf(ym, f);

            maxNum = -1;
            maxNumFreq = -1;
            maxI = -1;
            for i = 1 : size(SN)
                if maxNum < SN(i)
                    maxNum = SN(i);
                    maxNumFreq = newF(i);
                    maxI = i;
                end
            end

            disp(' ');
            disp('Bin 99 S/N: ');
            disp(SN(94));
            disp('Max S/N: ');
            disp(maxNum);
            disp('Max S/N occurs at: ');
            disp(maxNumFreq);

            % Plot the S/N ratio against the frequency
            plot(newF, SN, 'b');
            xlim([1 7]);
            ylim auto;
            ylabel('S/N Ratio');
            xlabel('Freqency');

            % Make an annotated text box for the max Signal/Noise ratio
            textBoxDimensions = [annotationStartPosition(1) annotationStartPosition(2) .31 .14];
            textBoxString = ['Bin 99 S/N: ' num2str(SN(94)) sprintf('\nMax S/N: ') ...
                    num2str(maxNum) sprintf('\nMax S/N Occurs at: ') num2str(maxNumFreq)];
            annotation('textbox', textBoxDimensions, 'String', textBoxString);

            % save the plot
            sizeOfSetFileName = size(setFiles{subjectIndex});
            sizeOfSetFileName = sizeOfSetFileName(1, 2);
            fileName = [plotsDirectory 'PerBin/' setFiles{subjectIndex}(1:sizeOfSetFileName - 4) '_SNPerBin'];
            print(fileName, '-dpng');
        else
            [baseSNR, oddSNR] = getSN_ymVf(ym, f);

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
            dim = [annotationStartPosition(1) annotationStartPosition(2) .22 .09];
            str = ['Base S/N: ', num2str(baseSNR), sprintf('\n Odd S/N: '), num2str(oddSNR)];
            annotation('textbox', dim, 'String', str);

            % save the plot
            sizeOfSetFileName = size(setFiles{subjectIndex});
            sizeOfSetFileName = sizeOfSetFileName(1, 2);
            fileName = [plotsDirectory 'SingleBin/' num2str(subjectIndex) '_SNSingleBin'];
            print(fileName, '-dpng');
        end
    end
end
