function out = findAllSetFilesWithCondition(setFiles, condition)
    % Function finds all .set files with the given condition from the list of all .set files
    
    sizeOfSetFiles = size(setFiles);
    nSetFiles = sizeOfSetFiles(1);
    outIndex = 1;
    out = {};
    for setFileIndex = 1 : nSetFiles
        if strfind(setFiles{setFileIndex}, condition)
            out = [out setFiles{setFileIndex}];
            outIndex = outIndex + 1;
        end
    end
end