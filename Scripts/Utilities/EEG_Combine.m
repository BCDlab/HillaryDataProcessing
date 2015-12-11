function EEG = EEG_combine(EEG1, EEG2)
	% function that concatenates two EEG trials
	% credit: Thomas Ferree, UT Southwestern Medical Center, 2007
	% url: http://sccn.ucsd.edu/pipermail/eeglablist/2008/002074.html

    % error catching
    if EEG1.pnts ~= EEG2.pnts
        error('Number of time points must be equal.');
    end
    if EEG1.nbchan ~= EEG2.nbchan
        error('Number of channels must be equal.');
    end
    if EEG1.xmin ~= EEG2.xmin
        error('Starting times must be equal.');
    end

    display(['Combining ' EEG1.setname ' and ' EEG2.setname '.']);

    EEG = EEG1;
    EEG.trials = EEG1.trials + EEG2.trials;
    EEG.data = zeros(EEG.nbchan,EEG.pnts,EEG.trials);
    EEG.data(:,:,1:EEG1.trials) = EEG1.data;
    EEG.data(:,:,EEG1.trials+1:EEG.trials) = EEG2.data;
end
