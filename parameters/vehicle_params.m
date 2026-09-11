function p = vehicle_params()
%VEHICLE_PARAMS  Electric vehicle and regenerative braking parameters.

    p.mass_kg           = 1500;
    p.wheel_radius_m    = 0.32;
    p.drag_coeff        = 0.28;
    p.frontal_area_m2   = 2.2;
    p.air_density       = 1.225;
    p.rolling_res_coeff = 0.012;
    p.g                 = 9.81;

    p.motor_max_torque_Nm   = 320;
    p.motor_max_power_kW      = 80;
    p.motor_efficiency        = 0.92;
    p.inverter_efficiency     = 0.96;
    p.gear_ratio              = 9.0;
    p.drivetrain_efficiency   = 0.95;

    p.regen_torque_fraction   = 0.85;
    p.regen_cutoff_speed_mps  = 0.5;
    p.regen_ramp_time_s       = 0.15;

    p.battery_capacity_kWh    = 60;
    p.battery_voltage_nom_V   = 360;
    p.soc_initial             = 0.55;
    p.soc_min                 = 0.10;
    p.soc_max                 = 0.95;
    p.battery_charge_eff      = 0.98;
    p.max_charge_power_kW     = 50;

    p.max_decel_mps2          = 8.0;
    p.friction_brake_delay_s  = 0.05;

    p.control_mode = 'optimized';
    p.fixed_regen_fraction    = 0.60;

    p.dt_s = 0.01;
end
