function [] = drawNonInterpolatedLines(SN, f)
	% Function draws lines from the x-axis to the SN points for all points

	dimF = size(f);
	sizeF = dimF(1);
	for freqIndex = 1 : sizeF
		X = [f(freqIndex) f(freqIndex)];
		Y = [0 SN(freqIndex)];
		line(X, Y);
	end

	% draw a horizontal line at 1 for reference
	line([0 7], [1 1]);
end