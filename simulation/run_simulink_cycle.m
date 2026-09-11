%% RUN_SIMULINK_CYCLE  Simulate one driving cycle in Simulink
clear; clc;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(root));

if ~license('test', 'Simulink')
    error('Simulink required. Use run_all_cycles for MATLAB-only simulation.');
end

p = vehicle_params();
cycles = driving_cycles();
cycle = cycles(1);
assignin('base', 'vehicle_p', p);
assignin('base', 'cycle_speed', [cycle.time_s, cycle.speed_mps]);

model = 'RegenerativeBrakingEV';
if ~exist(fullfile(root, 'models', [model '.slx']), 'file')
    build_regenerative_braking_model();
end
set_param(model, 'StopTime', num2str(cycle.time_s(end)));
sim(model);
fprintf('Simulink run complete: %s\n', cycle.name);
