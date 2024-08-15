function FEMOptimisation ()
    % Set initial parameter ranges
    modulus_range = [10, 150]; % Replace with your ranges
    poisson_range = [0.1, 0.4]; % Replace with your ranges
    
    % Set initial RMSE threshold and other optimization parameters
    min_rmse = Inf;
    tolerance = 1e-4; % Tolerance
    maxIterations = 500; % Maximum number of iterations
    iterations = 0; % Current iteration count

    % Initialize best result
    best_x = [];
    best_fval = Inf;

    while true
        iterations = iterations + 1; % Update iteration count
        disp(['Current Iteration: ', num2str(iterations)]); % Display current iteration
        
        % Set random number generator state, ensuring randomness of initial points each run
        rng('shuffle');

        % Set up global search object
        problem = createOptimProblem('fmincon','objective',...
            @(x) objectiveFunction(x),...
            'x0',[rand()*(modulus_range(2)-modulus_range(1)) + modulus_range(1),...
                  rand()*(poisson_range(2)-poisson_range(1)) + poisson_range(1)],...
            'lb',[modulus_range(1), poisson_range(1)],...
            'ub',[modulus_range(2), poisson_range(2)]);

        gs = GlobalSearch;

        % Execute global optimization
        [x,fval] = run(gs,problem);

        % If current result is better, update best result
        if fval < best_fval
            best_x = x;
            best_fval = fval;
        end
        
        % Check termination condition
        if fval < min_rmse
            min_rmse = fval;
        elseif iterations >= maxIterations || abs(fval - min_rmse) < tolerance % Add termination condition
            break; % Exit loop if max iterations reached or RMSE improvement is less than tolerance
        end
    end

    % Display optimal results
    disp(['Optimal Modulus: ', num2str(best_x(1))]);
    disp(['Optimal Poisson Ratio: ', num2str(best_x(2))]);
    disp(['Optimal RMSE: ', num2str(best_fval)]);
end

function rmse = objectiveFunction(x)
    % Parse parameters
    modulus = x(1);
    poisson = x(2);

    % Step 1: Modify elastic modulus and Poisson ratio in the Abaqus input file
    run ('ModifyAbaqusInputFile');
    
    % Step 2: Execute RunAbaqusCAE.m, waiting for completion
    run('RunAbaqusCAE.m'); % Ensure RunAbaqusCAE.m script properly invokes Abaqus and waits for completion
    
    % Step 3: Process output using Python script called by Abaqus
    status = system('abaqus cae noGUI="C:\Users\Documents\Extract LE from nodes.py"');
    if status ~= 0
        error('Failed to execute Abaqus script.');
    end
    
    % Step 4: Further process Abaqus results to generat the first principal stains 'EMax'
    run('E123toEMax.m'); 
    
    % Step 5: Execute MATLAB script for RMSE calculation
    run('RMSEFEMDVC.m'); % Calculates and saves RMSE value to a text file
    
    % Read RMSE result
    fid = fopen('D:\RMSE.txt', 'r');
    if fid == -1
        error('Unable to open RMSE.txt file.');
    end
    rmse = fscanf(fid, '%f');
    fclose(fid);

    % Save result data to file
    SaveOptimizationResults(modulus, poisson, rmse);
end

function SaveOptimizationResults(modulus, poisson, rmse)
    % Specify file save path
    resultsFilePath = 'D:\OptimizationResults.txt'; % Replace with your desired result save path

    % Open file in append mode
    fid = fopen(resultsFilePath, 'a');
    if fid == -1
        error(['Unable to open ', resultsFilePath, ' file.']);
    end
    
    % Write data
    fprintf(fid, '%f, %f, %f\n', modulus, poisson, rmse);
    
    % Close file
    fclose(fid);
end
