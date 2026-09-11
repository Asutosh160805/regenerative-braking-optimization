%% RUN_ALL_CYCLES  Compare regenerative braking across driving cycles
clear; clc; close all;

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'parameters'));
addpath(fullfile(root, 'data'));
addpath(fullfile(root, 'simulation'));
addpath(fullfile(root, 'analysis'));

p = vehicle_params();
cycles = driving_cycles();
control_modes = {'optimized', 'fixed_split', 'no_regen'};
mode_labels = {'Optimized Regen', 'Fixed 60% Regen', 'Friction Only (Baseline)'};
all_results = cell(numel(cycles), numel(control_modes));

fprintf('\n=== Regenerative Braking Optimization — Cycle Comparison ===\n\n');
fprintf('%-18s %-22s %12s %12s %12s\n', 'Cycle', 'Control', 'KE Lost', 'Recovered', 'Efficiency');
fprintf('%s\n', repmat('-', 1, 78));

for ic = 1:numel(cycles)
    for im = 1:numel(control_modes)
        p_run = p;
        p_run.control_mode = control_modes{im};
        all_results{ic, im} = regenerative_braking_sim(cycles(ic), p_run);
        r = all_results{ic, im}.metrics;
        fprintf('%-18s %-22s %9.1f kJ %9.1f kJ %10.1f%%\n', ...
            cycles(ic).name, mode_labels{im}, r.total_ke_lost_kJ, ...
            r.energy_recovered_kJ, r.regen_efficiency_pct);
    end
    fprintf('\n');
end

results_dir = fullfile(root, 'results');
if ~exist(results_dir, 'dir'), mkdir(results_dir); end
save(fullfile(results_dir, 'comparison_results.mat'), ...
    'all_results', 'cycles', 'control_modes', 'mode_labels', 'p');
compare_cycles(all_results, cycles, mode_labels);
fprintf('Results saved to: %s\n', fullfile(results_dir, 'comparison_results.mat'));
