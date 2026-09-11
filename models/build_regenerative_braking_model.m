function model_name = build_regenerative_braking_model()
    if ~license('test', 'Simulink')
        error('Simulink license not available. Use run_all_cycles instead.');
    end

    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(root, 'parameters'));
    addpath(fullfile(root, 'data'));
    p = vehicle_params();
    assignin('base', 'vehicle_p', p);

    model_name = 'RegenerativeBrakingEV';
    slx_path = fullfile(root, 'models', [model_name '.slx']);
    if bdIsLoaded(model_name), close_system(model_name, 0); end
    if exist(slx_path, 'file'), delete(slx_path); end

    new_system(model_name);
    open_system(model_name);
    set_param(model_name, 'Solver', 'ode4', 'FixedStep', num2str(p.dt_s), 'StopTime', '1369');

    add_block('simulink/Sources/From Workspace', [model_name '/Speed_Ref'], ...
        'VariableName', 'cycle_speed', 'Position', [30 80 120 110]);
    add_block('simulink/User-Defined Functions/MATLAB Function', ...
        [model_name '/Regen_Controller'], 'Position', [200 60 340 140]);
    add_block('simulink/Continuous/Integrator', [model_name '/Velocity'], ...
        'InitialCondition', '0', 'Position', [480 85 520 115]);
    add_block('simulink/Math Operations/Gain', [model_name '/Gain_1_m'], ...
        'Gain', num2str(1/p.mass_kg), 'Position', [400 85 440 115]);
    add_block('simulink/Math Operations/Sum', [model_name '/Force_Sum'], ...
        'Inputs', '++-', 'Position', [340 85 370 115]);
    add_block('simulink/Sinks/Scope', [model_name '/Scope_Speed'], 'Position', [580 70 610 100]);
    add_block('simulink/Sinks/Scope', [model_name '/Scope_Power'], 'Position', [580 130 610 160]);
    add_block('simulink/Sinks/To Workspace', [model_name '/Log_v'], ...
        'VariableName', 'sim_v', 'SaveFormat', 'Array', 'Position', [580 200 660 230]);

    add_line(model_name, 'Speed_Ref/1', 'Regen_Controller/1', 'autorouting', 'on');
    add_line(model_name, 'Regen_Controller/1', 'Force_Sum/1', 'autorouting', 'on');
    add_line(model_name, 'Regen_Controller/2', 'Force_Sum/2', 'autorouting', 'on');
    add_line(model_name, 'Force_Sum/1', 'Gain_1_m/1', 'autorouting', 'on');
    add_line(model_name, 'Gain_1_m/1', 'Velocity/1', 'autorouting', 'on');
    add_line(model_name, 'Velocity/1', 'Scope_Speed/1', 'autorouting', 'on');
    add_line(model_name, 'Velocity/1', 'Log_v/1', 'autorouting', 'on');
    add_line(model_name, 'Regen_Controller/2', 'Scope_Power/1', 'autorouting', 'on');

    save_system(model_name, slx_path);
    fprintf('Model saved: %s\nPaste controller_code.m into Regen_Controller block.\n', slx_path);
end
