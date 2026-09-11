function cycles = driving_cycles()
%DRIVING_CYCLES  Standard and custom speed profiles for comparison studies.

    cycles = struct('name', {}, 'description', {}, 'time_s', {}, 'speed_mps', {});

    cycles(end+1) = make_cycle('UDDS', ...
        'Urban stop-and-go; frequent acceleration/braking events.', udds_profile());
    cycles(end+1) = make_cycle('NEDC', ...
        'Mixed urban + extra-urban; moderate braking frequency.', nedc_profile());
    cycles(end+1) = make_cycle('WLTP', ...
        'Worldwide harmonized cycle; dynamic speed changes.', wltp_simplified_profile());
    cycles(end+1) = make_cycle('HWFET', ...
        'Highway cruise; low braking — baseline for regen opportunity.', hwfet_profile());
    cycles(end+1) = make_cycle('Aggressive_City', ...
        'Short intervals, hard deceleration — stresses regen controller.', aggressive_city_profile());
end

function c = make_cycle(name, description, profile)
    c.name = name;
    c.description = description;
    c.time_s = profile(:,1);
    c.speed_mps = profile(:,2) / 3.6;
end

function p = udds_profile()
    t = (0:1:1369)';
    v = zeros(size(t));
    pattern = [0 0; 10 15; 20 15; 30 0; 45 20; 60 20; 75 0; 90 25; 110 25; 125 0; ...
               140 30; 160 30; 175 0; 190 20; 210 20; 225 0; 240 35; 260 35; 280 0; ...
               300 40; 330 40; 350 0; 370 25; 390 25; 410 0; 430 30; 460 30; 480 0; ...
               500 20; 520 20; 540 0; 560 15; 580 15; 600 0; 620 25; 650 25; 670 0; ...
               690 30; 720 30; 740 0; 760 20; 780 20; 800 0; 820 35; 850 35; 870 0; ...
               890 25; 910 25; 930 0; 950 20; 970 20; 990 0; 1010 15; 1030 15; 1050 0; ...
               1070 25; 1100 25; 1120 0; 1140 30; 1170 30; 1190 0; 1210 20; 1230 20; 1250 0; ...
               1270 25; 1300 25; 1320 0; 1340 15; 1360 15; 1369 0];
    for k = 1:size(pattern,1)-1
        idx = t >= pattern(k,1) & t <= pattern(k+1,1);
        v(idx) = pattern(k,2);
    end
    p = [t, v];
end

function p = nedc_profile()
    t = (0:1:1180)';
    v = zeros(size(t));
    pattern = [0 0; 20 15; 40 15; 60 0; 80 20; 100 20; 120 0; 140 25; 160 25; 180 0; ...
               200 30; 230 30; 250 0; 270 20; 290 20; 310 0; 330 15; 350 15; 370 0; ...
               400 50; 450 50; 500 70; 550 70; 600 50; 650 50; 700 70; 750 70; 800 50; ...
               850 50; 900 70; 950 70; 1000 50; 1050 50; 1100 70; 1150 70; 1180 0];
    for k = 1:size(pattern,1)-1
        idx = t >= pattern(k,1) & t <= pattern(k+1,1);
        v(idx) = pattern(k,2);
    end
    p = [t, v];
end

function p = wltp_simplified_profile()
    t = (0:1:1800)';
    v = 10 + 25*sin(2*pi*t/300) + 15*sin(2*pi*t/120);
    v(v < 0) = 0;
    
    % Fix: Use proper indexing to match array sizes
    idx1 = t > 600 & t < 650;
    if sum(idx1) > 0
        v_start = v(find(t==600,1));
        if isempty(v_start), v_start = v(find(idx1,1)); end
        v(idx1) = linspace(v_start, 0, sum(idx1))';
    end
    
    idx2 = t >= 650 & t < 700;
    v(idx2) = 0;
    
    idx3 = t >= 1200 & t < 1250;
    if sum(idx3) > 0
        v(idx3) = max(v(idx3) - linspace(0, 30, sum(idx3))', 0);
    end
    
    p = [t, v * 3.6];
end

function p = hwfet_profile()
    t = (0:1:765)';
    v = zeros(size(t));
    v(t >= 50 & t <= 700) = 30 * 3.6;
    v(t < 50) = linspace(0, 30*3.6, 51)';
    v(t > 700) = linspace(30*3.6, 0, 66)';
    p = [t, v];
end

function p = aggressive_city_profile()
    t = (0:1:600)';
    v = zeros(size(t));
    for k = 0:14
        t0 = k * 40;
        v(t >= t0 & t < t0+10) = linspace(0, 50, 11)';
        v(t >= t0+10 & t < t0+25) = 50;
        v(t >= t0+25 & t < t0+35) = linspace(50, 0, 11)';
        v(t >= t0+35 & t < t0+40) = 0;
    end
    p = [t, v];
end
