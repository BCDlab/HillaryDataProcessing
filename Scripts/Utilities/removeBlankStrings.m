function out = removeBlankStrings(in, numberOfNonMatches)
    % Function used to remove all cells that are blank from the passed array
    out = cell(1, floor(numberOfNonMatches));
    outIndex = 1;
    for index = 1 : size(in)
        if ~strcmp(in(index).name, '')
            out{outIndex} = in(index).name;
            outIndex = outIndex + 1;
        end
    end

    % remove blank cells if there are any left over for some reason
    out = out(~cellfun('isempty', out));
end