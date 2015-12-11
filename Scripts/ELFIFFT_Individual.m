function [] = ELFIFFT_Individual(channels)
    % Function used to perform Fourier Transforms on a single participant's EEG data.
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost.
    % If using adult data, specify any value other than '6' or '9' for the age.
    % The .set files must also have their accompanying .fdt files.
    %
    % This script requires and will automatically create the following directory structure:
    %
    %                                            |-----6month  
    %                                    |----SN |-----9month
    %                                    |       |-----Other
    %   HillaryDataProcessing |----Plots |
    %                                    |       |-----6month
    %                                    |----YM |-----9month
    %                                            |-----Other
    %

    % make sure that the Utilities folder is on the path
    adjustPath();

    % if needed, create the directory structure
    createDirectoryStructure();

    % Prompt the user for input parameters
    [channels, condition, directory, setFiles, nParticipants, concatenateAcrossTrials,...
        plotBySNvFreq, powerOrAmplitude, singleBinSNR, binRangeOffset]...
        = promptUserForInputData(channels);

    sixNine = getSixOrNineMonths(setFiles{1});

    if sixNine == 6
        SixOrNineMonths = '6months/';
    elseif sixNine == 9
        SixOrNineMonths = '9months/';
    else
        % dump them all into one folder (ex: adult data)
        SixOrNineMonths = 'Other/';
    end

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
        if strcmp(powerOrAmplitude, 'Amplitude')
            ym = powerToAmplitude(ym);
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
            disp('Max S/N: ');
            disp(maxNum);
            disp('Max S/N occurs at: ');
            disp(maxNumFreq);
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
            xlabel('Freqency');

            % Make an annotated text box for the max Signal/Noise ratio
            textBoxDimensions = [annotationStartPosition(1) annotationStartPosition(2) .25 .1];
            textBoxString = ['Base S/N: ', num2str(SN(94)), sprintf('\nOdd S/N: '), num2str(SN(14))];
            annotation('textbox', textBoxDimensions, 'String', textBoxString);

            % save the plot
            sizeOfSetFileName = size(setFiles{subjectIndex});
            sizeOfSetFileName = sizeOfSetFileName(1, 2);
            fileName = [plotsDirectory 'SN/' SixOrNineMonths setFiles{subjectIndex}(1:sizeOfSetFileName - 4)];
            print(fileName, '-dpng');
        else
            [baseSNR, oddSNR] = getSN_ymVf(ym, f, singleBinSNR, binRangeOffset);

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
            fileName = [plotsDirectory 'YM/' SixOrNineMonths setFiles{subjectIndex}(1:sizeOfSetFileName - 4)];
            print(fileName, '-dpng');
        end
    end
end

function [] = createDirectoryStructure()
    % Function checks if all needed directorys are created and creates them if not

    message = 'Creating directory: ';
    if exist('../Plots') == 0
        disp(strcat(message, 'Plots/'));
        mkdir('../Plots');
    end
    if exist('../Plots/SN') == 0
        disp(strcat(message, 'Plots/SN'));
        mkdir('../Plots/SN');
    end
    if exist('../Plots/SN/6months') == 0
        disp(strcat(message, 'Plots/SN/6months'));
        mkdir('../Plots/SN/6months');
    end
    if exist('../Plots/SN/9months') == 0
        disp(strcat(message, 'Plots/SN/9months'));
        mkdir('../Plots/SN/9months');
    end
    if exist('../Plots/SN/Other') == 0
        disp(strcat(message, 'Plots/SN/Other'));
        mkdir('../Plots/SN/Other');
    end
    if exist('../Plots/YM') == 0
        disp(strcat(message, 'Plots/YM'));
        mkdir('../Plots/YM');
    end
    if exist('../Plots/YM/6months') == 0
        disp(strcat(message, 'Plots/YM/6months'));
        mkdir('../Plots/YM/6months');
    end
    if exist('../Plots/YM/9months') == 0
        disp(strcat(message, 'Plots/YM/9months'));
        mkdir('../Plots/YM/9months');
    end
    if exist('../Plots/YM/Other') == 0
        disp(strcat(message, 'Plots/YM/Other'));
        mkdir('../Plots/YM/Other');
    end
end