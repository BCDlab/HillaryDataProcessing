function [] = adjustPath()
	% Function that checks if the Utilities subfolder is on the path
	% and adds it to the path if it is not

	pathCell = regexp(path, pathsep, 'split');
    if ispc  % Windows is not case-sensitive
      onPath = any(strcmpi('Utilities', pathCell));
    else
      onPath = any(strcmp('Utilities', pathCell));
    end

    % If Utilities folder is not on the path, add it
    if ~onPath
    	addpath('Utilities');
    end
end