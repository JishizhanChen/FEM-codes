function RunAbaqusCAE()
    % Define Abaqus job name and input file path
    jobName = 'Job1';
    inputFilePath = 'C:\temp\job1.inp'; % For example: 'C:\path\to\your\file.inp'
    logFilePath = 'C:\Users\Documents\matlab.simlog'; % Log file path

    % Assume modulus and poisson are known here, this part may need to be adjusted based on your situation
    % For example, you could read from a global variable, or have it calculated before this script starts
    % modifyAbaqusInputFile(inputFilePath, modulus, poisson);

    % Start Abaqus analysis
    commandStr = sprintf('abaqus job=%s input="%s" cpus=16 ask_delete=OFF interactive', jobName, inputFilePath);
    system(commandStr);

    % Create MATLAB GUI window
    hFig = figure('Name', 'Abaqus Analysis Monitoring', 'NumberTitle', 'off');
    hText = uicontrol('Style', 'text', 'String', 'Monitoring Abaqus analysis...', ...
                      'HorizontalAlignment', 'center', 'Units', 'normalized', ...
                      'Position', [0.1, 0.5, 0.8, 0.4]);

    % Create and configure timer
    t = timer('TimerFcn', {@checkAbaqusLog, hText, logFilePath}, ...
              'Period', 10, 'ExecutionMode', 'fixedSpacing', 'BusyMode', 'drop');

    % Start the timer
    start(t);

    % When the window is closed, stop and delete the timer
    set(hFig, 'CloseRequestFcn', {@stopTimer, t});
end

function checkAbaqusLog(~, ~, hText, logFilePath)
    % Check if the Abaqus log file exists
    if exist(logFilePath, 'file')
        % Read the log file
        logData = fileread(logFilePath);
        
        % Check if the log data contains a specific completion identifier
        % This needs to be adjusted according to the actual situation
        if contains(logData, 'Specific identifier that the analysis has completed')
            set(hText, 'String', 'Abaqus analysis completed');
            stop(timerfind); % Stop the timer
        else
            set(hText, 'String', 'Abaqus analysis is running...');
        end
    else
        set(hText, 'String', 'Abaqus log file not found');
    end
end

function stopTimer(src, ~, t)
    % Stop and delete the timer
    stop(t);
    delete(t);
    delete(src);
end