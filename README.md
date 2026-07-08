# UTAUT4-BPP-ABM Simulator

> Agent-Based Modeling Simulator for Blockchain Adoption in Power Plant Asset Management

[![License: Copyright Reserved](https://img.shields.io/badge/License-Copyright%20Reserved-red.svg)]()
[![NetLogo 6.4](https://img.shields.io/badge/NetLogo-6.4-brightgreen.svg)](https://ccl.northwestern.edu/netlogo/)
[![Version 1.0](https://img.shields.io/badge/Version-1.0-blue.svg)]()

## 📋 Description

**UTAUT4-BPP-ABM Simulator** is a computational simulation application built using NetLogo 6.4 that models the dynamics of blockchain technology adoption in coal-fired power plant (PLTU) asset management. The simulator implements the **UTAUT4-BPP model** — an extension of UTAUT2 with four novel constructs specific to the blockchain-power plant domain: TDPS (Trust in Distributed Provenance Systems), RCA (Resource and Capability Adequacy), ORE (Organizational Readiness Ecosystem), and TAI (Technology Anxiety and Inertia).

The simulator runs **240 heterogeneous agents** representing four organizational strata (operators, supervisors, managers, executives) interacting within a **Watts-Strogatz small-world network**. Path coefficients are calibrated from an empirical SEM-PLS analysis of 236 survey respondents from PLTU Adipala, Tanjung Jati B, and Suralaya.

## 🎯 Key Features

- ✅ Empirically grounded via SEM-PLS path coefficient integration
- ✅ 6 built-in policy intervention scenarios (S1–S6)
- ✅ Real-time visualization: world view + 4 dynamic plots
- ✅ Automatic CSV export for statistical analysis
- ✅ BehaviorSpace compatible for batch experiments
- ✅ Reproducible via configurable random seed

## 📸 Application Screenshots

### Main Interface
The NetLogo IDE with UTAUT4-BPP-ABM Simulator loaded and ready to run:

![Full IDE Setup](docs/screenshots/01_full_ide_setup.png)

### World View — Mid Simulation (tick=60)
Real-time visualization showing 59.2% agents have adopted (green nodes):

![World View](docs/screenshots/02_world_mid.png)

### Real-Time Plots Panel
Four dynamic plots tracking adoption dynamics across scenarios:

![Plots Panel](docs/screenshots/03_plots.png)

### Source Code — Code Tab
NetLogo source code with syntax highlighting:

![Code Tab](docs/screenshots/04_code_tab.png)

### BehaviorSpace Experiment Setup
Automated experiment configuration for 6 scenarios × 30 replications:

![BehaviorSpace](docs/screenshots/05_behaviorspace.png)

---
## 🛠️ Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | Windows 10 / macOS 10.14 / Ubuntu 20.04 | Windows 11 / macOS 13+ / Ubuntu 22.04 |
| Processor | Intel Core i3 / AMD Ryzen 3 | Intel Core i7 / AMD Ryzen 7 |
| RAM | 4 GB | 16 GB |
| Storage | 500 MB free | 2 GB SSD |
| Software | NetLogo 6.4 + Java Runtime | NetLogo 6.4 (Java bundled) |

## 🚀 Installation & Quick Start

### Step 1: Install NetLogo

Download NetLogo 6.4 from the official website:
👉 https://ccl.northwestern.edu/netlogo/download.shtml

### Step 2: Clone or Download This Repository

```bash
git clone https://github.com/miftahol-arifin/UTAUT4-BPP-ABM-Simulator.git
```

Or click the green **Code** button → **Download ZIP** → extract to your working directory.

### Step 3: Open the Simulator

1. Launch NetLogo IDE
2. `File → Open` → navigate to `src/` folder
3. Select `UTAUT4-BPP-ABM.nlogo`

### Step 4: Run a Simulation

1. Set parameters via sliders (default values are pre-configured)
2. Choose scenario from `scenario-mode` dropdown (S1–S6)
3. Click **setup** to initialize 240 agents
4. Click **go** to run the simulation
5. Watch the world view and plots update in real-time
6. CSV output auto-saves to `outputs/csv/`

## 📁 Repository Structure

```
UTAUT4-BPP-ABM-Simulator/
│
├── src/
│   └── UTAUT4-BPP-ABM.nlogo         # Main source code
│
├── data/
│   ├── empirical-coefficients.csv    # SEM-PLS coefficients
│   ├── initial-distributions.csv     # Construct distributions
│   └── survey-data.csv               # Survey data (n=236)
│
├── experiments/
│   ├── behaviorspace-config.xml
│   ├── scenario-parameters.csv
│   └── replication-seeds.txt
│
├── outputs/
│   ├── csv/                          # Simulation output data
│   ├── plots/                        # Visualizations
│   └── logs/                         # Execution logs
│
├── docs/
│   ├── manual-book.pdf               # Full user manual
│   ├── odd-protocol.pdf              # ODD Protocol
│   └── screenshots/                  # Interface screenshots
│
├── analysis/
│   ├── convergence-analysis.py       # Convergence tests
│   ├── scenario-comparison.R         # Comparative analysis
│   └── plot-generator.py             # Visualization scripts
│
├── README.md                          # This file
├── LICENSE                            # Copyright notice
└── CITATION.cff                       # Citation metadata
```

## 🧪 Scenarios

| Code | Scenario | Intervention | Adoption Rate at t=120 |
|------|----------|--------------|------------------------|
| S1 | Baseline | None | 73.1% |
| S2 | Training | EE +0.8 (30% of ops/sups at t=12) | 81.2% |
| S3 | Infrastructure | FC +1.0 (all agents at t=18) | 84.3% |
| S4 | Trust Campaign | TDPS +0.9 (all agents at t=6) | 81.9% |
| S5 | Top-down Mandate | ORE +1.2 & executive influence ×1.5 at t=3 | 85.7% |
| S6 | Combined (Holistic) | All above, calibrated timing | 91.1% |

## 📊 Path Coefficients (SEM-PLS, n=236)

| Path | β | p-value | Status |
|------|---|---------|--------|
| PE → BI | 0.214 | 0.001 | ✅ Accepted |
| EE → BI | 0.187 | 0.003 | ✅ Accepted |
| TDPS → BI | 0.232 | 0.000 | ✅ Accepted |
| RCA → BI | 0.169 | 0.008 | ✅ Accepted |
| ORE → BI | 0.198 | 0.002 | ✅ Accepted |
| FC → UB | 0.276 | 0.000 | ✅ Accepted |
| BI → UB | 0.412 | 0.000 | ✅ Accepted |

## 📖 Documentation

- 📘 [Full Manual Book (PDF)](docs/manual-book.pdf)
- 📗 [ODD Protocol Specification](docs/odd-protocol.pdf)
- 📕 [Model Description Paper](docs/model-description.pdf)

## 🎓 Citation

If you use this simulator in your research, please cite:

```bibtex
@software{arifin2026utaut4bpp,
  author  = {Arifin, Miftahol},
  title   = {UTAUT4-BPP-ABM Simulator: Agent-Based Modeling for
             Blockchain Adoption in Power Plant Asset Management},
  version = {1.0},
  year    = {2026},
  url     = {https://github.com/miftahol-arifin/UTAUT4-BPP-ABM-Simulator},
  note    = {Copyright Reserved — DJKI Hak Cipta Terdaftar}
}
```

## 👤 Author

**MIFTAHOL ARIFIN** (NIM. 23936004)
Doctoral Candidate, Program Doktor Rekayasa Industri
Fakultas Teknologi Industri
Universitas Islam Indonesia, Yogyakarta

**Supervisory Team:**
- Promotor: Prof. Dr. Elisa Kusrini
- Ko-Promotor 1: Dr. Winda Nur Cahyo
- Ko-Promotor 2: Dr. Imam Djati Widodo

## ⚖️ License & Copyright

Copyright © 2026 MIFTAHOL ARIFIN. All rights reserved.

This software is registered with the **Direktorat Jenderal Kekayaan Intelektual (DJKI) Republik Indonesia** as a Program Komputer under Hak Cipta protection.

- ✅ Free for academic research and non-commercial educational use with proper citation
- ❌ Commercial use requires written permission from the copyright holder
- ❌ Redistribution or modification without authorization is prohibited

## 🐛 Bug Reports & Contact

- 📧 Email: miftahol.arifin@students.uii.ac.id
- 🐙 GitHub Issues: [Report a bug](https://github.com/miftahol-arifin/UTAUT4-BPP-ABM-Simulator/issues)
- 🏛️ Sentra KI Telkom University: [@hki_telu](https://instagram.com/hki_telu) / 0812-2300-2545

---

**Status:** ✅ Active Development
**Version:** 1.0 (Released 2026)
**Last Updated:** May 2026
