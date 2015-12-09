function [] = ELFIFFT_AllChannels()
	% Function used to perform Fourier Transforms on EEG data across multiple participants
	% and display each channel individually on one graph.
    % 
    % Note: input data must match the form: ELFI_<participant#>_<age>_<condition>.set
    % Where condition is LabelPre, LabelPost, NoisePre, or NoisePost.
    % The .set files must also have their accompanying .fdt files.
    %

    % make sure that the Utilities folder is on the path
    adjustPath();

    nChannels = 124;
    channels = makeChannelArray(nChannels);

    % Prompt the user for input parameters
    [channels, condition, directory, setFiles, nParticipants, concatenateAcrossTrials,...
        plotBySNvFreq, powerOrAmplitude, singleBinSNR, binRangeOffset]...
        = promptUserForInputData(channels, 1, 1, 0);

    nSetFiles = size(setFiles);
    nSetFiles = nSetFiles(1, 1);

    % Create arrays to hold the output yms, output fs, and the input EEG data
    % to save time in iteration
    ymArray = cell(nChannels, 1);
    fArray =  cell(nChannels, 1);
    EEGArray = cell(nSetFiles, 1);

    % Iterate and get all EEG data
    for participantIndex = 1 : nSetFiles
    	EEGArray{participantIndex} = pop_loadset('filename', setFiles{participantIndex}, 'filepath', directory);
    end

    % flush the plot window
    clf('reset');
    xlim([1 7]);
    ylim auto
    xlabel('Frequency (Hz)')
    ylabel('Y(f)')

    % Iterate through each channel and get the ym and f data of each
    for channelIndex = 1 : nChannels
        for subjectIndex = 1 : nSetFiles
            [ym, f] = fourieegWindowed(EEGArray{subjectIndex}, channels, [], 0, 10);
            ymCombined(subjectIndex, :) = ym;
        end

        ymAverage = mean(ymCombined,1);

	    % TODO: Look into if we should be plotting "power" 
	    % (amplitude squared) or just amplitude
	    if strcmp(powerOrAmplitude, 'Amplitude')
	        ymAverage = powerToAmplitude(ymAverage);
	    end

	    ymArray{channelIndex} = ymAverage;
	    fArray{channelIndex} = f;

	    % Plot the output of the Fourier Transform against the frequency
        plot(fArray{channelIndex}, ymArray{channelIndex}, 'b');
        hold on;
    end

    % xlim([1 7]);
    % ylim auto
    % xlabel('Frequency (Hz)')
    % ylabel('Y(f)')

    % % Plot each ym vs f on the same graph
    % for channelIndex = 1 : nChannels
    % 	% Plot the output of the Fourier Transform against the frequency
    %     plot(fArray{channelIndex}, ymArray{channelIndex}, 'b');
    %     hold on;
    % end
end

function channelArray = makeChannelArray(nChannels)
    % Function makes an array with numbers 1 through nChannels
    channelArray = zeros(nChannels, 1);
    for index = 1 : nChannels
        channelArray(index, 1) = index;
    end
end