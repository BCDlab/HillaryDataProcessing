function sixOrNine = getSixOrNineMonths(filename)
	% Function takes a file name and retrives whether or not the file name
	% corresponds to a 6 month participant, 9 month participant, or other
	% (ex: adult).

	underscoreCount = 0;
	charIndex = 1;
	while underscoreCount ~= 2
		currentChar = filename(charIndex);
		if strcmp(currentChar, '_')
			underscoreCount = underscoreCount + 1;
		end

		charIndex = charIndex + 1;
	end

	ch = filename(charIndex);
	if strcmp(ch, '6')
		sixOrNine = 6;
	elseif strcmp(ch, '9')
		sixOrNine = 9;
	else
		sixOrNine = 0;
	end
end