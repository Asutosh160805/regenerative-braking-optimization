function compare_cycles(all_results, cycles, mode_labels)
    nCycles = numel(cycles);
    nModes = numel(mode_labels);
    rp = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'results');
    if ~exist(rp, 'dir'), mkdir(rp); end

    eff_matrix = zeros(nCycles, nModes);
    for ic = 1:nCycles
        for im = 1:nModes
            eff_matrix(ic, im) = all_results{ic, im}.metrics.regen_efficiency_pct;
        end
    end

    fig1 = figure('Name', 'Regen Efficiency', 'Color', 'w', 'Position', [100 100 900 500]);
    cycle_names = {cycles.name};
    bar(eff_matrix);
    set(gca, 'XTickLabel', cycle_names, 'FontSize', 11);
    ylabel('Regenerative Efficiency (%)');
    title('Braking Energy Recovery Efficiency Across Driving Cycles');
    legend(mode_labels, 'Location', 'northwest');
    grid on; ylim([0 100]);
    saveas(fig1, fullfile(rp, 'efficiency_comparison.png'));

    recovered = zeros(nCycles, 1);
    friction = zeros(nCycles, 1);
    for ic = 1:nCycles
        recovered(ic) = all_results{ic, 1}.metrics.energy_recovered_kJ;
        friction(ic) = all_results{ic, 1}.metrics.energy_friction_kJ;
    end

    fig2 = figure('Name', 'Energy Breakdown', 'Color', 'w', 'Position', [120 80 900 500]);
    bar([recovered, friction], 'stacked');
    set(gca, 'XTickLabel', cycle_names, 'FontSize', 11);
    ylabel('Energy during Braking (kJ)');
    title('Recovered vs Friction-Dissipated Energy (Optimized Control)');
    legend({'Recovered to Battery', 'Lost as Heat (Friction)'}, 'Location', 'northwest');
    grid on;
    saveas(fig2, fullfile(rp, 'energy_breakdown.png'));

    udds_idx = find(strcmp({cycles.name}, 'UDDS'), 1);
    if isempty(udds_idx), udds_idx = 1; end
    r = all_results{udds_idx, 1};

    fig3 = figure('Name', 'UDDS Trace', 'Color', 'w', 'Position', [140 60 900 600]);
    subplot(3,1,1);
    plot(r.time_s, r.speed_ref_mps*3.6, 'k--'); hold on;
    plot(r.time_s, r.speed_mps*3.6, 'b', 'LineWidth', 1.2);
    ylabel('Speed (km/h)'); legend('Reference', 'Actual'); grid on;
    title(sprintf('%s — Optimized Regenerative Braking', r.cycle_name));
    subplot(3,1,2);
    plot(r.time_s, r.P_regen_kW, 'g', 'LineWidth', 1.2);
    ylabel('Regen Power (kW)'); grid on;
    subplot(3,1,3);
    plot(r.time_s, r.soc*100, 'm', 'LineWidth', 1.2);
    ylabel('SOC (%)'); xlabel('Time (s)'); grid on;
    saveas(fig3, fullfile(rp, 'udds_trace.png'));
end
