function [SN, newF] = getSN_SNVf(ym, f)
	% Function takes in the ym and f output by fourieeg and
	% finds the signal/noise ratio at each freqency bin.

	sizeOfF = size(f');
    SN = zeros(sizeOfF(1, 1) - 10, 1);
    newF = zeros(sizeOfF(1, 1) - 10, 1);

    for freqIndex = 6 : sizeOfF - 5
        noiseRange = [ym(freqIndex - 5:freqIndex - 1), ym(freqIndex + 1:freqIndex + 5)];
        currentSN = ym(freqIndex) / mean(noiseRange);
        newF(freqIndex - 5, 1) = f(freqIndex);
        SN(freqIndex - 5, 1) = currentSN;
    end
end