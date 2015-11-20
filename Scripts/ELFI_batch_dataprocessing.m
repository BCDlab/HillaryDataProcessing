function [] = ELFI_batch_dataprocessing()
	% Function reads .set files in batch and prepares their data
	% for FFT analysis in other scripts
	%
    % Notes:
    % 
    % Raw data and Event Info must have already been imported, and the file
    % must be saved as a .set file: ELFI_#_age (e.g., ELFI_2_9)
    % 
    % The project must have the following directory structure, but it will only
    % check if it exists, not create it on its own (otherwise it would result
    % in file not found errors):
    %
    %                         |----Scripts
    %                         |
    %   HillaryDataProcessing |
    %                         |         |----6mos
    %                         |----Data |----9mos
    %                                   |----Other
    %

    if ~checkDirectoryStructure
    	error('Directory structure is not complete, please see notes in source on running script.');
    end


    contitionArray = {'LabelPre', 'LabelPost', 'NoisePre', 'NoisePost'};
    setFilePattern = 'ELFI_\d*_[0 6 9].set';

    % Get the age of the batch of participants to be processed
    ageArray = {'6mos', '9mos', 'Other'};
    [selectionIndex, leftBlank] = listdlg('PromptString', 'Select an age:', 'SelectionMode', 'single', 'ListString', ageArray);
    age = ageArray{selectionIndex};
    pathToFiles = ['../Data/' age '/'];

    pattern = fullfile(pathToFiles, '*.set');
    allSetFiles = dir(pattern);
    setFiles = filterSetFiles(allSetFiles, setFilePattern);
end

function filteredSetFiles = filterSetFiles(setFiles, pattern)
	% Function that takes in a list of every set file in a directory and filters
	% according to the regex pattern supplied

	dimFiles = size(setFiles);
	nFiles = dimFiles(1, 1);

	nFilteredFiles = 0;
	for fileIndex = 1 : nFiles
		if regexp(setFiles(fileIndex, 1).name, pattern)
			nFilteredFiles = nFilteredFiles + 1;
		end
	end

	filteredSetFiles = cell(nFilteredFiles, 1);
	filterIndex = 1;
	for fileIndex = 1 : nFiles
		if regexp(setFiles(fileIndex, 1).name, pattern)
			filteredSetFiles{filterIndex} = setFiles(fileIndex).name;
			filterIndex = filterIndex + 1;
		end
	end	
end

function structureOK = checkDirectoryStructure()
	% Function checks that the directory structure is okay and
	% returns true if it is, false otherwise

	structureOK = true;
	if ~exist('../Data')
        structureOK = false;
        return;
    end
    if ~exist('../Data/6mos')
        structureOK = false;
        return;
    end
    if ~exist('../Data/9mos')
        structureOK = false;
        return;
    end
    if ~exist('../Data/Other')
        structureOK = false;
        return;
    end
end