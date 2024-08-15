% Set the number of decimal places for the output results to 10
format longG;

% Read the extracted text file
inputFilePath = 'D:/LE.txt';
outputFilePath = 'D:/EMax.txt'; % Specified path

% Create an empty structure array to store nodes and corresponding strain data
data = struct('NodeLabel', {}, 'Strains', {});

% Read the file and parse each line of data
fid = fopen(inputFilePath, 'r');
fgetl(fid); % Skip file header
line = fgetl(fid);
while ischar(line)
    C = strsplit(line, ',');
    nodeLabel = str2double(C{1});
    strains = cellfun(@str2double, C(2:end));
    data(end+1).NodeLabel = nodeLabel;
    data(end).Strains = strains;
    line = fgetl(fid);
end
fclose(fid);

% Calculate the maximum principal strain for each node
maxPrincipalStrains = zeros(length(data), 1);
for i = 1:length(data)
    strains = data(i).Strains;
    E11 = strains(1);
    E22 = strains(2);
    E33 = strains(3);
    E12 = strains(4);
    E13 = strains(5);
    E23 = strains(6);
    
    principal_strains = [
        (E11 + E22 + E33) / 3 + sqrt((E11 - E22)^2 + (E22 - E33)^2 + (E11 - E33)^2 + 6 * (E12^2 + E13^2 + E23^2)) / 3,
        (E11 + E22 + E33) / 3 - sqrt((E11 - E22)^2 + (E22 - E33)^2 + (E11 - E33)^2 + 6 * (E12^2 + E13^2 + E23^2)) / 3,
        (E11 + E22 + E33) / 3 - sqrt((E11 - E22)^2 + (E22 - E33)^2 + (E11 - E33)^2 + 6 * (E12^2 + E13^2 + E23^2)) / 3
    ];
    maxPrincipalStrains(i) = max(principal_strains);
end

% Write the maximum principal strain of each node to a text file at the specified path
fid = fopen(outputFilePath, 'w');
for i = 1:length(data)
    fprintf(fid, '%d, %.10f\n', data(i).NodeLabel, maxPrincipalStrains(i));
end
fclose(fid);

disp(['Results written to: ', outputFilePath]); % Output to console