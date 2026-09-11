# Regenerative Braking Optimization (MATLAB / Simulink)

Electric vehicle regenerative braking simulation comparing energy recovery across standard driving cycles (UDDS, NEDC, WLTP, HWFET, Aggressive City).

## Requirements

- **MATLAB R2020b+** (base MATLAB for scripts)
- **Simulink** (optional — only for `build_regenerative_braking_model.m`)

## Quick Start (on a machine with MATLAB)

```matlab
% Clone the repo, then in MATLAB:
cd('regenerative-braking-optimization')
addpath(genpath(pwd))

% Run full comparison (no Simulink needed)
run_all_cycles

% Optional: build Simulink model
build_regenerative_braking_model()
run_simulink_cycle
```

## Outputs

After `run_all_cycles`:
- Console table of efficiency per cycle
- `results/efficiency_comparison.png`
- `results/energy_breakdown.png`
- `results/udds_trace.png`
- `results/comparison_results.mat`

## Project Structure

```
├── PRESENTATION_THEORY.md   ← Theory slides / speaker notes
├── parameters/vehicle_params.m
├── data/driving_cycles.m
├── simulation/
│   ├── regenerative_braking_sim.m
│   ├── run_all_cycles.m
│   └── run_simulink_cycle.m
├── analysis/compare_cycles.m
└── models/
    ├── build_regenerative_braking_model.m
    └── controller_code.m
```

## Presentation

See [PRESENTATION_THEORY.md](PRESENTATION_THEORY.md) for physics, control strategy, and slide outline.
