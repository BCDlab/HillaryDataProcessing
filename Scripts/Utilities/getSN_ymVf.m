function [baseSN, oddSN] = getSN_ymVf(ym, f, singleBinSNR, binRangeOffset, binRangeWidth)
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

    if (strcmp(singleBinSNR, 'No'))
        % I can't believe I have to do this like this, but MATLAB is extremely weak with
        % subscript indices, so I'm sorry for the numbered named variables.

    	% Calulate the Signal/Noise ratio for the base
        leftCenter  = baseBin - binRangeOffset;
        rightCenter = baseBin + binRangeOffset;

        first = leftCenter - binRangeWidth;
        second = leftCenter;
        third = rightCenter;
        fourth = rightCenter + binRangeOffset;

        % Quick sanity check, make sure that the base isn't included in the range
        if (first < baseBin && second > baseBin) || (third < baseBin && fourth > baseBin)
            error('Your base signal is included in your signal to noise ratio.');
        end

        try
            bNoise = [ym(first : second), ym(third : fourth)];
            baseNoise = mean(bNoise);
        catch excetpion
            error('Your bin range offset exceeds the size of the bin array (base value). Please use a smaller bin offset.');
        end

        baseRatio = baseSignal / baseNoise;
        baseSN = mean(baseRatio);

        % Calulate the Signal/Noise ratio for the oddball
        leftCenter  = fakeOddBin - binRangeOffset;
        rightCenter = fakeOddBin + binRangeOffset;

        first = leftCenter - binRangeWidth;
        second = leftCenter;
        third = rightCenter;
        fourth = rightCenter + binRangeOffset;
        try
            % If using only the right side of the odd signal bin gets approved, flip true to false
            if true
                oNoise = [ym(first : second), ym(third : fourth)];
            else
                oNoise = [ym(third : fourth)];
            end
            oddNoise = mean(oNoise);
        catch excetpion
            error('Your bin range offset exceeds the size of the bin array (base value). Please use a smaller bin offset.');
        end

        oddRatio = oddSignal / oddNoise;
        oddSN = mean(oddRatio);
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