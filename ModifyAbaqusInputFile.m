function ModifyAbaqusInputFile
    % Replace with your input file path
    inputFilePath = 'C:\temp\job1.inp';

    % Read file contents
    fileContents = fileread(inputFilePath);
    
    % Find positions of *Material, name=Material-1 and *Elastic
    materialStartIdx = strfind(fileContents, '*Material, name=Material-1');
    elasticStartIdx = strfind(fileContents(materialStartIdx:end), '*Elastic') + materialStartIdx - 1;
    
    % Find first newline after *Elastic, indicating start of values
    newlineIdx = find(fileContents(elasticStartIdx:end) == newline, 1, 'first') + elasticStartIdx - 1;
    
    % Find end of value line (next newline)
    newlineEndIdx = find(fileContents(newlineIdx+1:end) == newline, 1, 'first') + newlineIdx;
    
    % Construct new value string without adding extra newlines
    newYongModulusStr = sprintf('%.1f', modulus);
    newPoissonRatioStr = sprintf('%.1f', poisson);
    newValuesStr = sprintf('%s, %s', newYongModulusStr, newPoissonRatioStr); % Note no \n added here
    
    % Replace value line without introducing extra newlines
    modifiedContents = [fileContents(1:newlineIdx), newValuesStr, fileContents(newlineEndIdx:end)];
    
    % Save modified file
    fileId = fopen(inputFilePath, 'w');
    if fileId == -1
        error('Unable to open file for writing: %s', inputFilePath);
    end
    fwrite(fileId, modifiedContents);
    fclose(fileId);

    % Display message indicating updated modulus and poisson ratio
    disp(['Modulus and Poisson Ratio for Material-1 have been updated to: Modulus = ', newYongModulusStr, ', Poisson Ratio = ', newPoissonRatioStr]);
end