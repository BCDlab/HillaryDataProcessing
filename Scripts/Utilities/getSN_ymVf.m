function [baseSN, oddSN, baseNoise, oddNoise] = getSN_ymVf(ym, f, singleBinSNR, binRangeOffset, binRangeWidth)
	% Function takes in the ym and f output by fourieeg and
	% returns the base signal/noise and odd signal/noise
	% ratios for that data
	% 
	% The base and odd bins are fixed at the 99th bin
    % and a somwhere between 20 and 21, interpolated
    % linearly, respectively.
    %

    % Base bin and signal
    baseBin = 99;
    baseSignal = ym(baseBin);

    % Linearly interpolate the signal at the odd bin (1.19)
    fakeOddBin = 20;
    oddSignal = ym(20) + ((ym(21) - ym(20)) * ((1.19 - f(20)) / (f(21) - f(20))));

    if baseBin + binRangeWidth > numel(ym) || fakeOddBin + binRangeWidth > numel(ym)
        error('Index exceeds range of YM. Please enter a smaller bin range.');
    end

    if (strcmp(singleBinSNR, 'No'))
        baseArray = zeros(1, binRangeWidth);
        for index = 1 : binRangeWidth
            baseArray(1, index) = ym(baseBin + index + binRangeOffset);
        end

        baseNoise = mean(baseArray);
        baseSN = baseSignal / baseNoise;

        oddArray = zeros(1, binRangeWidth);
        for index = 1 : binRangeWidth
            oddArray(1, index) = ym(fakeOddBin + index + binRangeOffset);
        end

        oddNoise = mean(oddArray);
        oddSN = oddSignal / oddNoise;
    else
        % Calulate the Signal/Noise ratio for the base
        bNoise = [ym(99 - 1 - binRangeOffset), ym(99 + 1 + binRangeOffset)];
        baseNoise = mean(bNoise);
        baseRatio = baseSignal / baseNoise;
        baseSN = mean(baseRatio);

        % Calulate the Signal/Noise ratio for the oddball
        oNoise = [ym(20) - 1 - binRangeOffset, ym(26) + 1 + binRangeOffset];
        oddNoise = mean(oNoise);
        oddRatio = oddSignal / oddNoise;
        oddSN = mean(oddRatio);
    end
end
