## Sudoku local search solver

Provide basic functions to solve a sudoku using a greedy descent algorithm.

Algorithm: It starts with a random solution, then randomly chooses a positon in the grid and change its value for a different number,
if the sudoku cost decrease, the new number is assigned to the current postion.
Then, the values of the resulted sudoku are swapped randomly to further decrease the cost of the solution   
The search function should be run more than 1000 to ensure a solution

```@docs
sudoku_greedydesc
flip
make_flip
search
print_sudoku
```