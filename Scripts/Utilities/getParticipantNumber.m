function participantNumber = getParticipantNumber(setFileName)
    participantStr = '';
    currChar = setFileName(1);
    charIndex = 1;
    while ~strcmp(currChar, '_')
        charIndex = charIndex + 1;
        currChar = setFileName(charIndex);
    end

    charIndex = charIndex + 1;
    currChar = setFileName(charIndex);

    while ~strcmp(currChar, '_')
        participantStr = [participantStr currChar];
        charIndex = charIndex + 1;
        currChar = setFileName(charIndex);
    end

    participantNumber = str2num(participantStr);
end