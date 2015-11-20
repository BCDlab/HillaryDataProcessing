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

    % Check that the directory structure is set up, error if it is not
    if ~checkDirectoryStructure
    	error('Directory structure is not complete, please see notes in source on running script.');
    end

    adjustPath();

    % Some important infomration to be used later
    contitionArray = {'LabelPre', 'LabelPost', 'NoisePre', 'NoisePost'};
    setFilePattern = 'ELFI_\d*_[0 6 9].set';

    % Get the age of the batch of participants to be processed
    ageArray = {'6mos', '9mos', 'Other'};
    [selectionIndex, leftBlank] = listdlg('PromptString', 'Select an age:', 'SelectionMode', 'single', 'ListString', ageArray);
    age = ageArray{selectionIndex};
    pathToFiles = ['../Data/' age '/'];

    % Get the set files from the appropriate directory
    pattern = fullfile(pathToFiles, '*.set');
    allSetFiles = dir(pattern);
    setFiles = filterSetFiles(allSetFiles, setFilePattern);

    % Get the number of .set files
    dimSetFiles = size(setFiles);
    nSetFiles = dimSetFiles(1, 1);

    % Load EEGLab constants
    eeglab;

    for setFileIndex = 1 : nSetFiles
    	% Get and display some information on the current participant
    	currentSetFile = setFiles{setFileIndex};
    	participantNumber = getParticipantNumber(currentSetFile);
    	disp(['Current Participant is: ' currentSetFile]);
    	binList = uigetdir('*.txt');

    	% Perform data analysis operations
    	EEG = pop_loadset('filename', currentSetFile);
    	EEG = pop_editset(EEG, 'setname', [pathToFiles 'ELFI_' num2str(participantNumber) '_' age '_chan']);
    	EEG = pop_creabasiceventlist(EEG, 'AlphanumericCleaning', 'on', 'BoundaryNumeric', {-99}, 'BoundaryString', {'boundary'});
    	EEG = pop_editset(EEG, 'setname', [pathToFiles 'ELFI_' num2str(subject) '_' age '_chan_elist']);
    	EEG = pop_basicfilter(EEG, 1:129, 'Cutoff', [0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order', 2, 'RemoveDC', 'on');
    	EEG = pop_editset(EEG, 'setname', [pathToFiles 'ELFI_' num2str(subject) '_' age '_chan_elist_filt']);

	%     EEG = pop_loadset('filename', filename);
	% %     [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0 );
	%     % eeglab redraw;
	%     % Add channel locations
	%     EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_9_chan'));

	%     % Create Event List
	%     EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
	%     EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_9_chan_elist'));
	%     % eeglab redraw;

	%     % Bandpass filter from 0.1-30 Hz
	%     EEG  = pop_basicfilter( EEG,  1:129 , 'Cutoff', [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2, 'RemoveDC', 'on' ); 
	%     EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_9_chan_elist_filt'));
	%     % eeglab redraw;
	%     %% Assign bins via BINLISTER

	%     BinList = uigetfile('*.txt'); % Select the correct BinList file based on the condition 

	%     EEG  = pop_binlister( EEG , 'BDF', BinList, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
	%     EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_9_chan_elist_filt_bins'));
	%     % eeglab redraw;

	%     % Create bin-based epochs
	%     EEG = pop_epochbin( EEG , [-100.0  10000.0],  'pre'); 
	%     EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_9_chan_elist_filt_bins_be'));
	%     % eeglab redraw;

	%     % Save dataset as .set file: Name as ELFI_#_age_condition (e.g.,
	%     % ELFI_2_9_LabelPre)

	%     %folder = uigetdir;
	%     %EEG = pop_saveset( EEG, 'filename',strcat('ELFI_',num2str(subject),'_9_',condition,'.set','filepath',folder));
	%     EEG = pop_saveset( EEG, 'filename',strcat(pathToFiles, 'ELFI_',num2str(subject),'_9_',condition,'.set'));

    end
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
