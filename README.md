# Institutional Emergence Model:
# An agent-based model of the evolution of institutional rules - Honours Project

This repo contains variations of an agent-based model used to evaluate the evolution of institutional rules in a common-pool resource sharing scenario.
The model is useful for observing conditions in which agents will or will not deplete a shared resource when acting out of self-interest and when the agents will establish institutions.
A variation of the model titled InstitutionalEmergenceNonCompliance.nLogo explores how the affects of non-compliance in agents will affect the resource and agents.

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

## CREDITS AND REFERENCES

Based off of the model in 'Managing the commons: a simple model of the mergence of institutions through collective action.' International Journal of the Commons, 10(1):200-219. Ghorbani, A. and Bravo, G. (2016)
