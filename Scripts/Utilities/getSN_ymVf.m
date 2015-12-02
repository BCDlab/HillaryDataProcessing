function [baseSN, oddSN] = getSN_ymVf(ym, f, singleBinSNR, binRangeOffset)
	% Function takes in the ym and f output by fourieeg and
	% returns the base signal/noise and odd signal/noise
	% ratios for that data
	% 
	% The base and odd bins are fixed at the 99th
	% and 19th bins.
    %
    % NOTE: I will probably take out one of these conditions in the near future,
    %       they are just being left for backwards compatibility

    if (strcmp(singleBinSNR, 'No'))
        % I can't believe I have to do this like this, but MATLAB is extremely weak as far as 
        % subscript indices, so I'm sorry for the numbered named variables.

    	% Calulate the Signal/Noise ratio for the base
        first = 94 - binRangeOffset;
        second = 98 - binRangeOffset;
        third = 100 + binRangeOffset;
        fourth = 104 + binRangeOffset;
        try
            bNoise = [ym(first : second), ym(third : fourth)];
            baseNoise = mean(bNoise);
        catch excetpion
            error('Your bin range offset exceeds the size of the bin array (base value). Please use a smaller bin offset.');
        end

        baseSignal = ym(99);
        baseRatio = baseSignal/baseNoise;
        baseSN = mean(baseRatio);

        % Calulate the Signal/Noise ratio for the oddball
        first = 14 - binRangeOffset;
        second = 18 - binRangeOffset;
        third = 20 + binRangeOffset;
        fourth = 24 + binRangeOffset;
        try
            oNoise = [ym(first : second), ym(third : fourth)];
            oddNoise = mean(oNoise);
        catch excetpion
            error('Your bin range offset exceeds the size of the bin array (base value). Please use a smaller bin offset.');
        end

        oddSignal = ym(19);
        oddRatio = oddSignal/oddNoise;
        oddSN = mean(oddRatio);
    else
        % Calulate the Signal/Noise ratio for the base
        baseSignal = ym(99);
        bNoise = [ym(92), ym(106)];
        baseNoise = mean(bNoise);
        baseRatio = baseSignal/baseNoise;
        baseSN = mean(baseRatio);

        % Calulate the Signal/Noise ratio for the oddball
        oddSignal = ym(19); % Bin 21 is 1.22
        oNoise = [ym(12), ym(26)];
        oddNoise = mean(oNoise);
        oddRatio = oddSignal/oddNoise;
        oddSN = mean(oddRatio);
    end
end