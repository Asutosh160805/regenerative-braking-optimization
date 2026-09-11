%% Paste into Simulink MATLAB Function block: Regen_Controller
function [F_net, P_regen_kW] = Regen_Controller(v_ref, v)
    persistent p torque_state
    if isempty(p)
        p = vehicle_params();
        torque_state = 0;
    end
    dt = p.dt_s; m = p.mass_kg;
    F_resist = 0.5*p.air_density*p.drag_coeff*p.frontal_area_m2*v^2 + p.rolling_res_coeff*m*p.g;
    a_req = max(min((v_ref - v)/dt, p.max_decel_mps2), -p.max_decel_mps2);
    F_req = m * a_req + F_resist;
    if F_req < 0
        F_brake = -F_req;
        rw = p.wheel_radius_m;
        F_regen_max = p.motor_max_torque_Nm * p.regen_torque_fraction * p.gear_ratio * p.drivetrain_efficiency / rw;
        if v > p.regen_cutoff_speed_mps
            F_pwr = p.max_charge_power_kW*1000 / (max(v,0.1)*p.motor_efficiency*p.inverter_efficiency);
            F_regen_max = min(F_regen_max, F_pwr);
        else
            F_regen_max = 0;
        end
        F_target = min(F_brake, F_regen_max);
        alpha = dt / (p.regen_ramp_time_s + dt);
        F_regen = alpha*F_target + (1-alpha)*torque_state;
        torque_state = F_regen;
        F_fric = max(F_brake - F_regen, 0);
        P_regen_kW = F_regen*v*p.motor_efficiency*p.inverter_efficiency/1000;
        F_net = -(F_regen + F_fric) - F_resist;
    else
        % Use parametrized motor force calculation instead of magic number
        F_traction_max = (p.motor_max_torque_Nm * p.gear_ratio * p.drivetrain_efficiency) / p.wheel_radius_m;
        F_power_max = (p.motor_max_power_kW * 1000) / max(v, 0.5);
        F_motor_max = min(F_traction_max, F_power_max) * p.motor_efficiency * p.inverter_efficiency;
        F_net = min(F_req, F_motor_max) - F_resist;
        P_regen_kW = 0;
        torque_state = torque_state * 0.9;
    end
end
