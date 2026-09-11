function results = regenerative_braking_sim(cycle, p, varargin)
%REGENERATIVE_BRAKING_SIM  Forward simulation of EV with regen braking.

    opts = parse_opts(varargin{:});
    if ~isempty(opts.ControlMode)
        p.control_mode = opts.ControlMode;
    end

    t = cycle.time_s(:);
    v_ref = cycle.speed_mps(:);
    N = numel(t);

    v = zeros(N,1);
    soc = zeros(N,1);
    F_motor = zeros(N,1);
    F_regen = zeros(N,1);
    F_friction = zeros(N,1);
    P_regen_kW = zeros(N,1);
    E_ke_lost_J = zeros(N,1);
    E_batt_J = zeros(N,1);

    v(1) = max(v_ref(1), 0);
    soc(1) = p.soc_initial;
    regen_torque_state = 0;
    m = p.mass_kg;

    for k = 2:N
        vk = v(k-1);
        dt_k = max(t(k) - t(k-1), p.dt_s);

        F_aero = 0.5 * p.air_density * p.drag_coeff * p.frontal_area_m2 * vk^2;
        F_roll = p.rolling_res_coeff * m * p.g;
        F_resist = F_aero + F_roll;

        v_target = v_ref(k);
        a_req = (v_target - vk) / dt_k;
        a_req = max(min(a_req, p.max_decel_mps2), -p.max_decel_mps2);
        F_req = m * a_req + F_resist * sign(max(vk, 0.01));

        if F_req < 0
            F_brake_req = -F_req;
            [F_regen(k), F_friction(k), P_regen_kW(k), regen_torque_state] = ...
                regen_controller(F_brake_req, vk, soc(k-1), p, regen_torque_state, dt_k);
            F_motor(k) = -F_regen(k);
        else
            F_traction_max = motor_force_max(vk, p);
            F_motor(k) = min(F_req, F_traction_max);
            F_regen(k) = 0;
            F_friction(k) = 0;
            P_regen_kW(k) = 0;
            regen_torque_state = regen_torque_state * 0.9;
        end

        if vk > v_target && vk > 0.1
            E_ke_lost_J(k) = max(0.5 * m * (vk^2 - max(v_target,0)^2), 0);
        end

        if P_regen_kW(k) > 0
            % Energy conservation: only add energy if SOC has headroom
            if soc(k-1) >= p.soc_max
                E_batt_J(k) = 0;
                soc(k) = soc(k-1);
            else
                % Calculate max energy that can be stored
                max_storable_J = (p.soc_max - soc(k-1)) * p.battery_capacity_kWh * 3.6e6;
                E_in = P_regen_kW(k) * 1000 * dt_k * p.battery_charge_eff;
                E_in = min(E_in, max_storable_J);
                E_batt_J(k) = E_in;
                soc(k) = soc(k-1) + E_in / (p.battery_capacity_kWh * 3.6e6);
            end
        else
            soc(k) = soc(k-1);
        end

        % Use max(v, 0.1) to avoid zero-velocity friction dissipation issues
        F_net = F_motor(k) - F_resist * sign(max(vk, 0.01)) - F_friction(k);
        v(k) = max(vk + (F_net / m) * dt_k, 0);
    end

    total_ke_lost_J = sum(E_ke_lost_J);
    total_recovered_J = sum(E_batt_J);
    total_friction_J = sum(F_friction .* max(v, 0.1) * p.dt_s);

    if total_ke_lost_J > 0
        eta_regen = 100 * total_recovered_J / total_ke_lost_J;
    else
        eta_regen = 0;
    end

    % Handle case where no regen events occur (avoid NaN)
    regen_power_positive = P_regen_kW(P_regen_kW > 0);
    if ~isempty(regen_power_positive)
        avg_regen_power = mean(regen_power_positive);
    else
        avg_regen_power = 0;
    end

    results.cycle_name = cycle.name;
    results.control_mode = p.control_mode;
    results.time_s = t;
    results.speed_mps = v;
    results.speed_ref_mps = v_ref;
    results.soc = soc;
    results.F_regen_N = F_regen;
    results.F_friction_N = F_friction;
    results.P_regen_kW = P_regen_kW;
    results.metrics.total_ke_lost_kJ = total_ke_lost_J / 1000;
    results.metrics.energy_recovered_kJ = total_recovered_J / 1000;
    results.metrics.energy_friction_kJ = total_friction_J / 1000;
    results.metrics.regen_efficiency_pct = eta_regen;
    results.metrics.braking_events = sum(diff([0; F_regen + F_friction]) > 100);
    results.metrics.avg_regen_power_kW = avg_regen_power;
    results.metrics.soc_delta_pct = 100 * (soc(end) - soc(1));
end

function [F_regen, F_friction, P_regen_kW, torque_state] = regen_controller( ...
        F_brake_req, v, soc, p, torque_state, dt)

    rw = p.wheel_radius_m;
    gr = p.gear_ratio;

    if strcmpi(p.control_mode, 'no_regen')
        F_regen = 0;
        F_friction = F_brake_req;
        P_regen_kW = 0;
        torque_state = 0;
        return;
    end

    T_max = p.motor_max_torque_Nm * p.regen_torque_fraction;
    F_motor_max = (T_max * gr * p.drivetrain_efficiency) / rw;

    if v > p.regen_cutoff_speed_mps
        P_max_W = p.max_charge_power_kW * 1000 / (p.inverter_efficiency * p.motor_efficiency);
        F_power_max = P_max_W / max(v, 0.1);
    else
        F_power_max = 0;
    end

    if soc >= p.soc_max
        F_regen_cap = 0;
    else
        F_regen_cap = min(F_motor_max, F_power_max);
    end

    switch lower(p.control_mode)
        case 'fixed_split'
            F_regen_target = p.fixed_regen_fraction * F_brake_req;
        otherwise
            F_regen_target = min(F_brake_req, F_regen_cap);
    end

    F_regen_target = min(F_regen_target, F_regen_cap);
    alpha = dt / (p.regen_ramp_time_s + dt);
    F_regen = F_regen_target * alpha + torque_state * (1 - alpha);
    torque_state = F_regen;
    F_regen = min(F_regen, F_brake_req);
    F_friction = max(F_brake_req - F_regen, 0);

    P_mech_W = F_regen * v;
    P_regen_kW = P_mech_W * p.drivetrain_efficiency * p.motor_efficiency * ...
        p.inverter_efficiency / 1000;
    P_regen_kW = min(P_regen_kW, p.max_charge_power_kW);
end

function F_max = motor_force_max(v, p)
    rw = p.wheel_radius_m;
    gr = p.gear_ratio;
    F_torque = (p.motor_max_torque_Nm * gr * p.drivetrain_efficiency) / rw;
    F_power = (p.motor_max_power_kW * 1000) / max(v, 0.5);
    F_max = min(F_torque, F_power) * p.motor_efficiency * p.inverter_efficiency;
end

function opts = parse_opts(varargin)
    opts.ControlMode = '';
    for i = 1:2:numel(varargin)
        if strcmp(varargin{i}, 'ControlMode')
            opts.ControlMode = varargin{i+1};
        end
    end
end
