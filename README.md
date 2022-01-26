# Cross-Entropy method
By Ceri-Anne Laureyssens

The notebook gives an introduction to cross-entropy and its use in the cross-entropy method. Cross-entropy is a metric used to measure the Kullback-Leibler (KL) distance between two probability distributions (f and g). The cross-entropy method is a Monte Carlo method for importance sampling and optimization and is found by minimizing the previously called KL distance in between distribution f and g (parameterized by θ). This is equivalent to choosing θ that minimizes the cross-entropy.

The method itself is implemented in the Pluto notebook and gives you an optimized distribution based on an objective function (S) and the originally entered distribution d_in.

# STMO-ZOO

Welcome to the STMO zoo! This is your final assignment for the course Selected Topics in Mathematical Optimization. Your goal is to implement an optimization method in Julia and contribute this to this repository. To pass, you have to:

- fork this repo and create a pull request;
- add a module to `src` with **at least one function**
- add at least one unit test to the folder `test`;
- document all your functions and add a page to the documentation page;
- make a notebook in [Pluto](https://github.com/fonsp/Pluto.jl) and add it to `notebooks`;
- perform a small code review of two other students.

Depending on the project you choose some of these individual assignments might be really minimalistic, with other parts larger. For example, if you want to develop an application, say solving the graph coloring problem with Tabu Search, you might have only a single function in the source code (e.g., generating an instance) but have a fairly large notebook with a tutorial. On the other hand, if you work on a method, e.g., implementing Bee Colony Optimization, you might have many functions in the source code, while your notebook is only a demonstration on the test functions. 

[![Build Status](https://travis-ci.org/MichielStock/STMOZOO.svg?branch=master)](https://travis-ci.org/MichielStock/STMOZOO)[![Coverage Status](https://coveralls.io/repos/github/MichielStock/STMOZOO/badge.svg?branch=master)](https://coveralls.io/github/MichielStock/STMOZOO?branch=master)
