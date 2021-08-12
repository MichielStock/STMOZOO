# SA sudoku solver 

Sarah Laperre 

A look at using simulated annealing for solving sudokus.
For example:

    julia> sudoku =  [7 4 1 5 9 0 3 8 2
	    3 0 6 2 4 7 1 9 5
    	2 9 5 1 8 3 6 0 7
    	9 7 2 0 0 8 0 1 4
    	0 0 4 0 5 0 8 0 0
    	1 5 0 4 0 0 7 3 6
    	5 0 3 9 7 2 4 6 8
    	4 6 9 8 3 5 2 0 1
    	8 2 7 0 1 4 9 5 3]

    julia> sudoku_solver(sudoku)
    741|590|382
    306|247|195
    295|183|607
    -----------
    972|008|014
    004|050|800
    150|400|736
    -----------
    503|972|468
    469|835|201
    827|014|953

    741|596|382
    386|247|195
    295|183|647
    -----------
    972|368|514
    634|751|829
    158|429|736
    -----------
    513|972|468
    469|835|271
    827|614|953

[![Build Status](https://travis-ci.org/MichielStock/STMOZOO.svg?branch=master)](https://travis-ci.org/MichielStock/STMOZOO)[![Coverage Status](https://coveralls.io/repos/github/MichielStock/STMOZOO/badge.svg?branch=master)](https://coveralls.io/github/MichielStock/STMOZOO?branch=master)