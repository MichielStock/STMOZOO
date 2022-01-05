## BeesAlgorithm

This documentation contains information about the functions implemented in the BeesAlgorithm module by Tristan and Kirsten.
The Artificial Bee Colonization (ABC) algorithm is a swarm-based metaheuristic for solving numerical optimization problems.
Apart from this algorithm and its required functions, also some test functions are provided to experiment with.

### Concept
##### General
The ABC algorithm is inspired by the **foraging behaviour of honey bees**. Honey bees collect nectar from flower patches as a food source for the colony. Bees are sent to explore different flower patches and they communicate the quality of these food sources through waggle dances. Good sites are continually exploited, while bees are sent out in search of additional promising sites.

##### Metaphor

As a methaphor for the foraging behaviour of bees, the ABC algorithm relies on three main components:

- **Food sources**, which can be considered as potential solutions of the optimization problem.

- **Employed foragers**. They exploit a food source, return to the colony to share their information with a certain probability, perform a waggle dance and recruit other bees, and then continue to forage at the food source.  

- **Unemployed foragers**. This category consists of two types of bees. On the one hand, the **onlooker bees** watch the waggle dances to become a recruit and start searching for a food source. On the other hand, the **scout bees** start searching for interesting flower patches around the nest spontaneously.


The fitness of a solution or food source is inversely related with the value of the objective function in this solution. Thus, a higher fitness corresponds to a lower objective value. In the optimization process, we want to **maximize fitness** and **minimize the objective function** to find the minimizer of a continous function. 


The following phases in the ABC algorithm can be distinguished:

**1) Employed bee phase**\
Employed bees try to identify better food source than the one they were associated previously. A new solution is generated using a partner solution. Thereafter, greedy selection is performed, meaning that a new solution only  will be accepted if it is better than the current solution. Every bee in the swarm will explore one food source. All solutions get an opportunity to generate a new solution in the employed bee phase.

**2) Onlooker bee phase**\
In the onlooker bee phase, a food source is selected for further exploitation with a probability related to the nectar amount, i.e. a solution with higher fitness will have a higher probability to be chosen. Fitter solutions may undergo multiple onlooker bee explorations. As in the employed bee phase, new solutions are generated using a partner solution and greedy selection is performed. In contrast to the employed bee phase, not every food source will be explored, since every onlooker bee will explore a certain food source with a certain probability (depending on nectar amount).

During the two phases above, a trial counter is registered for every food source. Each time a food source fails to generate a solution with higher fitness, the trial counter is elevated by 1 unit.

The solution with highest fitness so far is kept apart in memory during the entire process and updated as better food sources are discovered.

**3) Scout bee phase**\
If the value of the trial counter for a certain solution is greater than fixed limit, then a solution can enter the scout phase. The latter food source is then considered as exhausted and will therefore be abandoned by the bees. After discarding the exhausted solution, a new random solution is generated and the trial counter of this solution is reset to zero.

### Functions 

```@docs
Main.BeesAlgorithm.initialize_population
Main.BeesAlgorithm.compute_objective
Main.BeesAlgorithm.compute_fitness
Main.BeesAlgorithm.foodsource_info_prob
Main.BeesAlgorithm.create_newsolution
Main.BeesAlgorithm.employed_bee_phase
Main.BeesAlgorithm.onlooker_bee_phase
Main.BeesAlgorithm.scouting_phase
Main.BeesAlgorithm.ArtificialBeeColonization
Main.BeesAlgorithm.sphere
Main.BeesAlgorithm.ackley
Main.BeesAlgorithm.rosenbrock
Main.BeesAlgorithm.branin
Main.BeesAlgorithm.rastrigine
```