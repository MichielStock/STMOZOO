## Cuckoo search

This is the documentation for the cuckoo search method, implemented by Claudia Mengoni. The module allows to solve a minimization problem through the use of the biological-inspired metaheuristic of cuckoo search.

The method is based on the parasitism of some cuckoo species that exploit the resources of other bird species by laying eggs into their nests.
To abstract this concept to a computational method the phenomenon is simplified by three main rules:
* Each cuckoo lays one egg at a time into a randomly chosen nest
* The nests containing the best eggs are carried over (elitist selection) to the next generation
* The number of available host nests is fixed and at each generation the alien cuckoo egg can be discovered with a certain probability. At this point the nest is abandoned and a new nest is generated.

It's important to note that this implementation allows a single egg for each nest, hence the terms nest and egg are used interchangeably.

The module contains a function to solve a minimization problem and a helper function that generates an initial population to use as input to the main method.

```@docs 
init_nests
cuckoo! 
```