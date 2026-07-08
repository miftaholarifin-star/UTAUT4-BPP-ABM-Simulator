;; ===============================================================
;; UTAUT4-BPP-ABM Simulator
;; Blockchain Adoption Model for Power Plant Asset Management
;; Author : MIFTAHOL ARIFIN (NIM 23936004)
;; Version: 1.0 (2026)
;; License: Copyright Reserved — Registered with DJKI Indonesia
;; ===============================================================

extensions [ csv table nw profiler ]

globals [
  ;; Empirical path coefficients (SEM-PLS, n=236)
  beta-PE-BI    beta-EE-BI    beta-TDPS-BI
  beta-RCA-BI   beta-ORE-BI   beta-FC-UB
  beta-BI-UB

  ;; Aggregate metrics
  adoption-rate    mean-BI    mean-UB
  adopters-count   tipping-point-tick
  network-clustering

  ;; Output management
  csv-filename    scenario-active
]

breed [ operators operator     ]
breed [ supervisors supervisor ]
breed [ managers manager       ]
breed [ executives executive   ]

turtles-own [
  ;; Exogenous constructs (UTAUT4-BPP)
  PE EE SI FC TDPS RCA ORE TAI

  ;; Endogenous variables
  BI UB

  ;; Dynamic status
  agent-id         adoption-tick
  influence-strength  history-BI
  policy-exposure
]

;; ===============================================================
;; SETUP PROCEDURES
;; ===============================================================

to setup
  clear-all
  random-seed random-seed-input
  load-empirical-coefficients
  initialize-globals
  create-population
  build-small-world-network
  apply-scenario scenario-mode
  setup-output-files
  reset-ticks
end

to load-empirical-coefficients
  set beta-PE-BI    0.214
  set beta-EE-BI    0.187
  set beta-TDPS-BI  0.232
  set beta-RCA-BI   0.169
  set beta-ORE-BI   0.198
  set beta-FC-UB    0.276
  set beta-BI-UB    0.412
end

to initialize-globals
  set tipping-point-tick -1
  set adopters-count 0
  set adoption-rate 0
  set scenario-active scenario-mode
end

to create-population
  let n-op  round (num-agents * 0.60)
  let n-sup round (num-agents * 0.25)
  let n-mgr round (num-agents * 0.12)
  let n-exe num-agents - n-op - n-sup - n-mgr

  create-operators   n-op  [ init-agent 1.0 ]
  create-supervisors n-sup [ init-agent 1.4 ]
  create-managers    n-mgr [ init-agent 1.8 ]
  create-executives  n-exe [ init-agent 2.2 ]
end

to init-agent [ infl ]
  setxy random-xcor random-ycor
  set shape "person"
  set color red
  set agent-id who
  set influence-strength infl
  set adoption-tick -1
  set UB 0
  set history-BI []
  set policy-exposure false

  ;; Initialize constructs from empirical normal distributions
  set PE   clamp-likert (random-normal 3.82 0.74)
  set EE   clamp-likert (random-normal 3.51 0.81)
  set SI   clamp-likert (random-normal 3.43 0.79)
  set FC   clamp-likert (random-normal 3.28 0.86)
  set TDPS clamp-likert (random-normal 3.67 0.72)
  set RCA  clamp-likert (random-normal 3.19 0.88)
  set ORE  clamp-likert (random-normal 3.45 0.77)
  set TAI  clamp-likert (random-normal 2.71 0.83)
  set BI 0
end

to build-small-world-network
  let agents-list sort turtles
  let n length agents-list
  let k mean-degree-k

  ;; Step 1: Create ring lattice
  foreach agents-list [ a ->
    let idx position a agents-list
    foreach (range 1 (k / 2 + 1)) [ d ->
      let nb item ((idx + d) mod n) agents-list
      ask a [ create-link-with nb ]
    ]
  ]

  ;; Step 2: Rewire with probability p
  ask links [
    if random-float 1 < network-rewiring-p [
      let from-end end1
      let new-target one-of turtles with [ self != from-end ]
      die
      ask from-end [ create-link-with new-target ]
    ]
  ]
end

;; ===============================================================
;; MAIN LOOP
;; ===============================================================

to go
  if ticks >= max-ticks [
    finalize-simulation
    stop
  ]

  ask turtles [ update-social-pressure ]
  ask turtles [ compute-behavioral-intention ]
  ask turtles [ decide-adoption ]
  ask turtles [ update-history ]

  update-aggregate-metrics
  detect-tipping-point
  apply-policy-intervention scenario-mode
  if report-csv [ write-csv-row ]
  tick
end

;; ===============================================================
;; UTAUT4-BPP CORE FUNCTIONS
;; ===============================================================

to compute-behavioral-intention
  let neighbor-mean-BI 0
  if any? link-neighbors [
    set neighbor-mean-BI mean [ BI ] of link-neighbors
  ]

  let raw-BI (
        beta-PE-BI   * (PE   / 5)
      + beta-EE-BI   * (EE   / 5)
      + beta-TDPS-BI * (TDPS / 5)
      + beta-RCA-BI  * (RCA  / 5)
      + beta-ORE-BI  * (ORE  / 5)
      + social-weight * neighbor-mean-BI
  )

  set BI sigmoid raw-BI 1.8
  set history-BI lput BI history-BI
  if length history-BI > 6 [
    set history-BI but-first history-BI
  ]
end

to decide-adoption
  if UB = 1 [ stop ]

  let smoothed-BI mean history-BI
  let prob-adopt (
        beta-BI-UB * smoothed-BI
      + beta-FC-UB * (FC / 5)
  )

  if (prob-adopt >= adoption-threshold) and
     (random-float 1 < prob-adopt) [
    set UB 1
    set adoption-tick ticks
    set color green
    set size 1.5
  ]
end

to update-social-pressure
  if any? link-neighbors [
    let w-BI mean [ BI * influence-strength ] of link-neighbors
    let w-TAI mean [ TAI * influence-strength ] of link-neighbors

    set SI (1 - social-weight) * SI + social-weight * w-BI * 5
    set SI clamp-likert SI

    set TAI 0.95 * TAI + 0.05 * w-TAI
    set TAI clamp-likert TAI
  ]
end

to update-history
  ;; Handled inside compute-behavioral-intention
end

;; ===============================================================
;; POLICY SCENARIO MODULE
;; ===============================================================

to apply-scenario [ scn ]
  set scenario-active scn
end

to apply-policy-intervention [ scn ]
  if scn = "S2" and ticks = 12 [ intervention-training ]
  if scn = "S3" and ticks = 18 [ intervention-infrastructure ]
  if scn = "S4" and ticks = 6  [ intervention-trust ]
  if scn = "S5" and ticks = 3  [ intervention-mandate ]
  if scn = "S6" [
    if ticks = 3  [ intervention-mandate ]
    if ticks = 6  [ intervention-trust ]
    if ticks = 12 [ intervention-training ]
    if ticks = 18 [ intervention-infrastructure ]
  ]
end

to intervention-training
  let target-pop turtles with [
    (breed = operators) or (breed = supervisors)
  ]
  ask n-of (round (count target-pop * 0.3)) target-pop [
    set EE clamp-likert (EE + 0.8)
    set policy-exposure true
  ]
end

to intervention-infrastructure
  ask turtles [ set FC clamp-likert (FC + 1.0) ]
end

to intervention-trust
  ask turtles [ set TDPS clamp-likert (TDPS + 0.9) ]
end

to intervention-mandate
  ask turtles [ set ORE clamp-likert (ORE + 1.2) ]
  ask executives [ set influence-strength influence-strength * 1.5 ]
end

;; ===============================================================
;; HELPER FUNCTIONS
;; ===============================================================

to-report sigmoid [ x slope ]
  report 1 / (1 + exp (- slope * (x - 0.5)))
end

to-report clamp-likert [ x ]
  report max list 1 (min list 5 x)
end

to update-aggregate-metrics
  set adopters-count count turtles with [ UB = 1 ]
  set adoption-rate adopters-count / count turtles
  set mean-BI mean [ BI ] of turtles
  set mean-UB mean [ UB ] of turtles
end

to detect-tipping-point
  if (tipping-point-tick = -1) and (adoption-rate >= 0.16) [
    set tipping-point-tick ticks
  ]
end

;; ===============================================================
;; OUTPUT MODULE
;; ===============================================================

to setup-output-files
  set csv-filename (word "output_" scenario-mode "_" random-seed-input ".csv")
  if file-exists? csv-filename [ file-delete csv-filename ]
  file-open csv-filename
  file-print "tick,adoption-rate,mean-BI,mean-UB,adopters,scenario"
  file-close
end

to write-csv-row
  file-open csv-filename
  file-print (word ticks "," adoption-rate "," mean-BI ","
                   mean-UB "," adopters-count "," scenario-active)
  file-close
end

to finalize-simulation
  print (word "=== Simulation Completed ===")
  print (word "Scenario: "          scenario-active)
  print (word "Adoption rate: "     precision adoption-rate 4)
  print (word "Tipping point tick: " tipping-point-tick)
  print (word "Mean BI final: "     precision mean-BI 4)
  print (word "Mean UB final: "     precision mean-UB 4)
end

;; ===============================================================
;; END OF SOURCE CODE — UTAUT4-BPP-ABM Simulator v1.0
;; Copyright (c) 2026 MIFTAHOL ARIFIN. All rights reserved.
;; ===============================================================
@#$#@#$#@
GRAPHICS-WINDOW
430
10
867
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
15
15
95
55
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
100
15
180
55
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
185
15
265
55
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
70
265
103
num-agents
num-agents
100
500
240.0
10
1
NIL
HORIZONTAL

SLIDER
15
110
265
143
max-ticks
max-ticks
60
240
120.0
10
1
NIL
HORIZONTAL

SLIDER
15
150
265
183
network-rewiring-p
network-rewiring-p
0
1
0.1
0.05
1
NIL
HORIZONTAL

SLIDER
15
190
265
223
mean-degree-k
mean-degree-k
2
12
6.0
1
1
NIL
HORIZONTAL

SLIDER
15
230
265
263
adoption-threshold
adoption-threshold
0.3
0.9
0.55
0.05
1
NIL
HORIZONTAL

SLIDER
15
270
265
303
social-weight
social-weight
0
1
0.3
0.05
1
NIL
HORIZONTAL

CHOOSER
15
310
265
355
scenario-mode
scenario-mode
"S1" "S2" "S3" "S4" "S5" "S6"
0

INPUTBOX
15
360
120
420
random-seed-input
42.0
1
0
Number

SWITCH
130
360
265
393
report-csv
report-csv
0
1
-1000

SWITCH
130
400
265
433
enable-policy
enable-policy
1
1
-1000

MONITOR
15
445
95
490
ticks
ticks
0
1
11

MONITOR
100
445
195
490
adopters
adopters-count
0
1
11

MONITOR
200
445
310
490
adoption rate
adoption-rate
3
1
11

MONITOR
315
445
420
490
mean BI
mean-BI
3
1
11

MONITOR
15
495
120
540
mean UB
mean-UB
3
1
11

MONITOR
130
495
270
540
tipping point tick
tipping-point-tick
0
1
11

MONITOR
280
495
420
540
scenario
scenario-active
17
1
11

PLOT
880
10
1310
230
Adoption Rate over Time
ticks
adoption-rate
0.0
120.0
0.0
1.0
true
false
"" ""
PENS
"adoption" 1.0 0 -13840069 true "" "plot adoption-rate"

PLOT
880
240
1310
460
Mean BI vs Mean UB
ticks
value
0.0
120.0
0.0
1.0
true
true
"" ""
PENS
"mean-BI" 1.0 0 -817084 true "" "plot mean-BI"
"mean-UB" 1.0 0 -13840069 true "" "plot mean-UB"

PLOT
430
460
860
680
Adoption by Breed
ticks
rate
0.0
120.0
0.0
1.0
true
true
"" ""
PENS
"operators"   1.0 0 -13345367 true "" "if any? operators [ plot count operators with [UB = 1] / count operators ]"
"supervisors" 1.0 0 -2674135  true "" "if any? supervisors [ plot count supervisors with [UB = 1] / count supervisors ]"
"managers"    1.0 0 -10899396 true "" "if any? managers [ plot count managers with [UB = 1] / count managers ]"
"executives"  1.0 0 -817084   true "" "if any? executives [ plot count executives with [UB = 1] / count executives ]"

PLOT
880
470
1310
680
Network Clustering
ticks
coefficient
0.0
120.0
0.0
0.6
true
false
"" ""
PENS
"clustering" 1.0 0 -6459832 true "" "plot network-clustering"

@#$#@#$#@
## UTAUT4-BPP-ABM Simulator

Agent-Based Modeling Simulator for Blockchain Adoption in Power Plant Asset Management.

### Author
MIFTAHOL ARIFIN (NIM 23936004)
Universitas Islam Indonesia

### Version
1.0 (2026)

### Description
This simulator models blockchain technology adoption dynamics in coal-fired power plant asset management using the UTAUT4-BPP extended model. Path coefficients are empirically calibrated from SEM-PLS analysis of 236 survey respondents from PLTU Adipala, Tanjung Jati B, and Suralaya.

### How to Use
1. Set parameters via sliders
2. Choose scenario (S1-S6) from dropdown
3. Click SETUP to initialize 240 agents
4. Click GO to run simulation
5. Watch real-time visualization and CSV export

### Copyright Notice
Copyright (c) 2026 MIFTAHOL ARIFIN. All rights reserved.
Registered as Program Komputer with DJKI Republik Indonesia.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

circle
false
0
Circle -7500403 true true 0 0 300

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
