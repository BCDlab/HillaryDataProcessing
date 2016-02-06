function [concatYM, concatF, concatBaseBin, concatFakeOddBin] = getConcatenatedBaseOdd(EEG, channels)
	% Function used to take an EEG's data and retrieve the base and fake (not yet interpolated) odd bin indices
	% after running epoch2continuous. Does relatively thorough error checking.

	concatBaseBin = -1;
	concatFakeOddBin = -1;
	concatBaseValue = -1;
	concatFakeOddValue = -1;


	originalBaseBin = 99;
	originalFakeOddBin = 20;

	[originalYM, originalF] = fourieegWindowed(EEG, channels, [], 0, 10);

	originalBaseValue = originalYM(originalBaseBin);
	originalFakeOddValue = originalYM(originalFakeOddBin);

	concatEEG = epoch2continuous(EEG);

	[concatYM, concatF] = fourieegWindowed(concatEEG, channels, [], 0, 10);

	for index = 1 : numel(concatYM)

		disp([num2str(originalBaseValue) ' : ' num2str(concatYM(index)) ' : ' num2str(originalFakeOddValue)])

		if concatYM(index) == originalBaseValue
			concatBaseBin = index;
			concatBaseValue = concatYM(index);
			disp('BASE FOUND!!!!!!!!!!!'); % remove later, just makes it easier to debug
		end

		if concatYM(index) == originalFakeOddValue
			concatFakeOddBin = index;
			concatFakeOddValue = concatYM(index);
			disp('ODD FOUND!!!!!!!!!!!!'); % remove later, just makes it easier to debug
		end
	end

	% Quick sanity checks to make sure that the bins were able to be found and that the original
	% base and odd values are equal.
	if originalBaseValue ~= concatBaseValue
		error(['The value at the Base bin changed as a result of the concatenation. This is likely a problem with' ...
			'the data set, please try reprocessing it. The value was ' num2str(originalBaseValue) ' before concatination and is ' ...
			num2str(concatBaseValue) ' after.']);
	end

	if originalBaseBin == concatBaseBin
		warning(['The Base bin index has not changed as a result of concatenating the data set. This is not necessarily' ...
			' an indication that something is wrong, it may warrant further investigation, however.'])
	end

	if originalFakeOddValue ~= concatFakeOddValue
		error(['The value at the Odd bin (fake bin, no interpolation) changed as a result of the concatenation. This is ' ...
			'likely a problem with the data set, please try reprocessing it.']);
	end

	if originalFakeOddBin == concatFakeOddBin
		warning(['The fake (non-interpolated) Odd bin index has not changed as a result of concatenating the data set. '...
			'This is not necessarily an indication that something is wrong, it may warrant further investigation, however.'])
	end
end