%% ELFI ssvep data processing
% Created 8/20/2015

% Read in set file & process data so it's ready to read into FFT script

% Raw data and Event Info must have already been imported, and the file
% must be saved as a .set file: ELFI_#_age (e.g., ELFI_2_9)

%% Prompt information

prompt = {'Subject','Condition'};
defaults = {'1','LabelPre'};
answer = inputdlg(prompt,'Condition',1,defaults);

[subject, condition] = deal(answer{:});

%% Initial processing steps
%EEG = pop_loadset('filename','ELFI_222_9.set','filepath','/Volumes/Data/ELFI/SsvepDataProcessing/9mos/');
EEG = pop_loadset('filename',strcat('ELFI_',num2str(subject),'_9.set'));
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
eeglab redraw

% Add channel locations
EEG = pop_editset(EEG, 'setname', strcat('ELFI_',num2str(subject),'_9_chan'));

% Create Event List
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
EEG = pop_editset(EEG, 'setname', strcat('ELFI_',num2str(subject),'_9_chan_elist'));
eeglab redraw

% Bandpass filter from 0.1-30 Hz
EEG  = pop_basicfilter( EEG,  1:129 , 'Cutoff', [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2, 'RemoveDC', 'on' ); 
EEG = pop_editset(EEG, 'setname', strcat('ELFI_',num2str(subject),'_9_chan_elist_filt'));
eeglab redraw
%% Assign bins via BINLISTER

BinList = uigetfile('*.txt'); % Select the correct BinList file based on the condition 

EEG  = pop_binlister( EEG , 'BDF', BinList, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
EEG = pop_editset(EEG, 'setname', strcat('ELFI_',num2str(subject),'_9_chan_elist_filt_bins'));
eeglab redraw

% Create bin-based epochs
EEG = pop_epochbin( EEG , [-1000.0  12000.0],  'pre'); 
EEG = pop_editset(EEG, 'setname', strcat('ELFI_',num2str(subject),'_9_chan_elist_filt_bins_be'));
eeglab redraw

% Save dataset as .set file: Name as ELFI_#_age_condition (e.g.,
% ELFI_2_9_LabelPre)

%folder = uigetdir;
%EEG = pop_saveset( EEG, 'filename',strcat('ELFI_',num2str(subject),'_9_',condition,'.set','filepath',folder));
EEG = pop_saveset( EEG, 'filename',strcat('ELFI_',num2str(subject),'_9_',condition,'.set'));



