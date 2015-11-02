function [baseSN, oddSN] = getSN_ymVf(ym, f)
	% Function takes in the ym and f output by fourieeg and
	% returns the base signal/noise and odd signal/noise
	% ratios for that data
	% 
	% The base and odd bins are fixed at the 99th
	% and 19th bins.

	% Calulate the Signal/Noise ratio for the base
    baseSignal = ym(99);
    bNoise = [ym(94:98), ym(100:104)];
    baseNoise = mean(bNoise);
    baseRatio = baseSignal/baseNoise;
    baseSN = mean(baseRatio);

    % Calulate the Signal/Noise ratio for the oddball
    oddSignal = ym(19); % Bin 21 is 1.22
    oNoise = [ym(14:18), ym(20:24)];
    oddNoise = mean(oNoise);
    oddRatio = oddSignal/oddNoise;
    oddSN = mean(oddRatio);
end