extensions [nw]
breed [comps comp] ;creat computer breed
globals [
  ConditionList
  ResourceEnergy
  InstitutionalChange?
  InstitutionExists?
  InstitutionCondition
  InstitutionAction
]                                                      ; global variables used throughout code

comps-own [
  energy
  action
  condition
  institutionA
  institutionC
  lowEnergy?
  strategy                                            ; strategy is set in form [action, condition]
  institutionS
]                                                      ; variables belonging to a computer

to setup
  clear-all
  reset-ticks
  create-comps NumberOfAgents
  ask comps [
    setxy random-xcor random-ycor
  ]
  set ResourceEnergy CarryingCapacity
  set InstitutionExists? false
  ask comps [ set action select-action ]
  ask comps [ set condition select-condition ]         ; agents select strategy
  ask comps [ set strategy (list action condition) ]
  create-neighbours ; create links
  set InstitutionalChange? false
end

to go
  if (check-end = true) [
    type "ResourceEnergy: " show ResourceEnergy
    type "Average Agent Energy" show mean [energy] of comps
    type "Institution present?" show InstitutionExists?
    type "ticks end: " show ticks
    stop
  ]                                                    ; check if energy = 0 or ticks = 2000
  lose-energy
  grow-resource                                        ; resource grows
  ifelse InstitutionExists? = true [
    ask comps [
      consume-resource-institution
    ]
  ][
    ask comps [
      consume-resource
    ]
  ]
  ask comps [ evaluate-strategy ]
  rewire-links
  check-energy
  check-institutional-change
  if InstitutionalChange? = true [
    establish-new-institution
    set InstitutionalChange? false
  ]
  tick
end

to-report select-action
  let randomNum 2 + random 18
  let negativeEnergy -5
  ifelse (random-float 1 < 0.05)[
    report -5
  ][
    report 2 + random 18
  ]
end

to-report select-condition
  set ConditionList (list 3 2 20 250 0 1)
  report one-of ConditionList
end

to create-neighbours
  ask comps [
    create-links-to min-n-of 2 other turtles [ distance myself ]
  ]
end

to rewire-links
  ask comps [
    if (random-float 1 < 0.05)[
      ask my-out-links [die]
      setxy random-xcor random-ycor
      create-links-to min-n-of 2 other turtles [ distance myself ]
    ]
  ]
end

to lose-energy
  ask comps [ set energy (energy - EnergyConsumption)]      ;agents lose energy according to selected parameters
end

to grow-resource
  let ResourceGain 0
  if(ResourceEnergy <= 0) [stop]
  set ResourceGain (((GrowthRate * ResourceEnergy) * (1 - (ResourceEnergy / CarryingCapacity))))        ;change in resource according to formula
  set ResourceEnergy (ResourceEnergy + ResourceGain)                                                    ; set resource to new resource quantity
end


to-report check-end ;
  ifelse (ResourceEnergy <= 0 and ticks > 0) or (ticks > 1999) [
    report true
  ][
    report false
  ]
end

to consume-resource
;  ask comps [
      (ifelse                                                ;all agents consume
      condition = 0 [
        if (energy <= 0) [                                   ; when energy <= 0 consume
          set energy (energy + action)
          if action != -5 [
            set ResourceEnergy ResourceEnergy - action
          ]
        ]
      ]
      condition = 1 [                                        ; always consume
        set energy (energy + action)
        if action != -5 [
          set ResourceEnergy ResourceEnergy - action
        ]
      ][
        if((ticks mod condition)= 0) [                       ; consume on condition
          set energy (energy + action)
          if action != -5 [
            set ResourceEnergy ResourceEnergy - action
          ]
        ]
    ])
;    ]
end

to consume-resource-institution
;  ask comps [
      (ifelse                                                ;all agents consume
      InstitutionCondition = 0 [
        if (energy <= 0) [                                   ; when energy <= 0 consume
          ;type " setting energy to " show energy + action
          set energy (energy + InstitutionAction)
          set ResourceEnergy ResourceEnergy - InstitutionAction
        ]
      ]
      InstitutionCondition = 1 [                                        ; always consume
        set energy (energy + InstitutionAction)
        set ResourceEnergy ResourceEnergy - InstitutionAction
      ][
        if((ticks mod InstitutionCondition)= 0) [                       ; consume on condition
          set energy (energy + InstitutionAction)
          set ResourceEnergy ResourceEnergy - InstitutionAction
        ]
    ])
;    ]
end

to check-energy
  ask comps [
    ifelse (energy < 0)[
      set lowEnergy? true
    ][
      set lowEnergy? false
    ]
  ]
end

to evaluate-strategy
  let bestAction action
  let bestCondition condition
  let bestNeighbourEnergy energy
  let origin self
  let neighbor self
  if (energy < 0) [
    ifelse (random-float 1 < InnovationRate)[   ;random innovation
      set action select-action
      set condition select-condition
      set strategy (list action condition)
    ][
      ask out-link-neighbors  [
         if energy > bestNeighbourEnergy [
          set neighbor self
          set bestNeighbourEnergy energy
          set bestAction action
          set bestCondition condition
        ]
      ]
      set action bestAction
      set condition bestCondition
      set strategy (list action condition)
    ]
  ]
end

to check-institutional-change
  if (ticks mod InstitutionalEmergenceTime) =  0  and ticks > 0 [
    if (((count comps with [energy < 0]) / 100 )> ThresholdForChange)[                          ;if threshold for change met
      set InstitutionalChange? true
    ]
  ]
end

to establish-new-institution
  let frequent modes [strategy] of comps
  set InstitutionAction item 0 item 0 frequent
  set InstitutionCondition item 1 item 0 frequent
;  ask comps [
;    set institutionA
;    set institutionC
;    set institutionS frequent
;  ]
  set InstitutionExists? true
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
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
0
0
1
ticks
30.0

SLIDER
20
86
192
119
NumberOfAgents
NumberOfAgents
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
21
31
87
64
NIL
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
115
30
178
63
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
20
130
192
163
CarryingCapacity
CarryingCapacity
5000
20000
15000.0
1000
1
NIL
HORIZONTAL

SLIDER
22
172
194
205
GrowthRate
GrowthRate
0.1
0.5
0.5
0.2
1
NIL
HORIZONTAL

CHOOSER
22
216
173
261
EnergyConsumption
EnergyConsumption
1 5 10 12 15 17 20
5

SLIDER
21
268
193
301
InnovationRate
InnovationRate
0.05
0.1
0.1
0.05
1
NIL
HORIZONTAL

MONITOR
22
311
93
356
Resource
ResourceEnergy
2
1
11

MONITOR
107
311
164
356
Tick
ticks
1
1
11

CHOOSER
10
365
206
410
InstitutionalEmergenceTime
InstitutionalEmergenceTime
50 100 200 500 1000
0

CHOOSER
23
419
179
464
ThresholdForChange
ThresholdForChange
0.4 0.6 0.8 1
0

PLOT
685
37
1049
322
Agent Energy at each tick
Time (ticks)
Agent Energy
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ask comps [ \ncreate-temporary-plot-pen (word who)\nset-plot-pen-color color\nplotxy ticks energy\n]"

PLOT
685
359
1056
564
Resource Energy at each tick
NIL
NIL
0.0
10.0
0.0
5000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy ticks ResourceEnergy"

@#$#@#$#@
## WHAT IS IT?

This model is an agent-based model showing the evolution of institutions.

## HOW IT WORKS

Each agent in the model is initialised randomly with a strategy to consume the resource and links to their two closest neighbours. If an agent is unhappy with it's energy, it can copy the strategy of it's neighbour. At institutional emergence time, if the threshold for change (proportion of unhappy agents) is met then an institution will be established using the most frequently occuring strategy in the population. Agents must then follow these institutional rules until the end of the simulation but will be given the option to change the institution at each institutional emergence time.

## HOW TO USE IT

To run the model: Press setup and go.
NumberOfAgents: Number of agents in the population.
CarryingCapacity: Initial resource energy
GrowthRate: How quickly the resource regrows
EnergyConsumption: How much energy the agents lose on each tick
Resource: Energy in the resource at any given time
Tick: Tick in the simulation (out of 2000)
InstitutionalEmergenceTime: What tick will an instituion be created if the threshold for change is met
ThresholdForChange: Proportion of agents that must be unhappy to establish an institution

## THINGS TO NOTICE

- Average agent energy
- Energy at the end of a simulation
- How often the resource depletes
- Which strategy is chosen for an institution
- Observe the patterns in agent energy shown in plots

## THINGS TO TRY

Try playing around with:
- Energy Consumption
- Innovation Rate
- Carrying Capacity
- Population
and observe their effects on the resource and agent energy.

## EXTENDING THE MODEL

An extension of this model would include agent non-compliance and sanctioning of non-compliant agents.

## RELATED MODELS

IPD model.

## CREDITS AND REFERENCES

Based off of the model in 'Managing the commons: a simple model of the mergence of institutions through collective action.' International Journal of the Commons, 10(1):200-219. Ghorbani, A. and Bravo, G. (2016)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
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
