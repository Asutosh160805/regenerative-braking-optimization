# Regenerative Braking Optimization — Presentation Theory

## 1. Introduction

**Problem:** Friction brakes waste kinetic energy as heat.  
**Solution:** Regenerative braking uses the motor as a generator to charge the battery.  
**Benefit:** 10–30% range improvement in city driving.

## 2. Kinetic Energy

\[
KE = \frac{1}{2} m v^2
\]

Example: 1500 kg at 50 km/h → ~145 kJ available during braking.

## 3. Vehicle Dynamics

\[
m \frac{dv}{dt} = F_{motor} - F_{brake} - F_{resist}
\]

- Drag: \( F_{drag} = \frac{1}{2} \rho C_d A v^2 \)
- Rolling: \( F_{roll} = C_{rr} m g \)
- Total brake: \( F_{brake} = F_{regen} + F_{friction} \)

## 4. Regenerative Power

\[
P_{battery} = F_{regen} \cdot v \cdot \eta_{drivetrain} \cdot \eta_{motor} \cdot \eta_{inverter}
\]

Typical chain efficiency ≈ 80–85%.

## 5. Optimized Blending Controller

\[
F_{regen} = \min(F_{brake,req}, F_{motor,max}, F_{power,max})
\]
\[
F_{friction} = F_{brake,req} - F_{regen}
\]

Limits: motor torque, battery charge power, SOC max, low-speed cutoff.

## 6. Efficiency Metric

\[
\eta_{regen} = \frac{E_{recovered}}{E_{KE,lost}} \times 100\%
\]

| Cycle | Expected η |
|-------|------------|
| UDDS (urban) | 55–70% |
| NEDC / WLTP | 40–60% |
| HWFET (highway) | 5–15% |
| Aggressive City | 60–75% |

## 7. Key Insight

Highway efficiency is low because there is **little braking**, not because regen fails. Urban cycles benefit most.

## 8. Simulink Model

```
Speed Ref → Regen Controller → F=ma → Velocity → Battery SOC
```

## 9. Suggested Slides

1. Title  2. Motivation  3. KE & dynamics  4. Block diagram  
5. Motor as generator  6. Control strategy  7. Driving cycles  
8. Simulink model  9. Methodology  10. Bar chart results  
11. Time traces  12. Conclusion
