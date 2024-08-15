% Part 1: Convert FEM txt file to xlsx format, adding headers
% Set the path for the FEM txt file and the target xlsx file
femTxtPath = 'D:\EMax.txt';
femXlsxPath = 'D:\FEMEMax.xlsx';

% Read the FEM txt file, specify comma as delimiter, and directly add column names
opts = detectImportOptions(femTxtPath, 'Delimiter', ',', 'ReadVariableNames', false);
opts.VariableNames = {'ID', 'Strain'}; % Set column names directly in the import options
femData = readtable(femTxtPath, opts);

% Write the data into an xlsx file
writetable(femData, femXlsxPath);

disp(['FEM data has been converted and saved to ', femXlsxPath]);

% Part 2: Compare the RMSE of first principal strain between DVC and FEM xlsx files and output to a specified path
% Set the path for the DVC xlsx file and the output file
dvcXlsxPath = 'D:\DVCEmax.xlsx'; % Path to the DVC EMax xlsx file (needs to prepare in advance)
outputPath = 'D:\RMSE.txt'; % Output file path

% Read the xlsx data for FEM and DVC
% Note: Use the previously saved FEM data xlsx file
femData = readtable(femXlsxPath);
dvcData = readtable(dvcXlsxPath);

% Calculate RMSE
% Assuming 'Strain' is the column name for stress values
rmse = sqrt(mean((dvcData.Strain - femData.Strain).^2));

% Output the result to a document
fileID = fopen(outputPath, 'w');
fprintf(fileID, '%f\n', rmse);
fclose(fileID);

disp(['RMSE calculation completed. Results are saved in ', outputPath]);