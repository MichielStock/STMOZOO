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

# RSO: Fitting a Neural Network by Optimizing One Weight at a Time
Heesoo Song (01514152)


**RSO (Random Search Optimization)** is a new weight update algorithm for training deep neural networks which explores the region around the initialization point by sampling weight changes to minimize the objective function. The idea is based on the assumption that the initial set of weights is already close to the final solution, as deep neural networks are heavily over-parametrized. Unlike traditional backpropagation in training deep neural networks that involves estimation of gradient at a given point, RSO is a gradient-free method that searches for the update one weight at a time with random sampling. The difference between both methods can be visualized as the figure below.

![Gradient_vs_sampling.png](https://github.com/HeesooSong/STMOZOO/blob/master/notebook/Figures/Gradient_vs_sampling.png?raw=true)

The original paper (https://arxiv.org/abs/2005.05955) showed that sampling method could be compatible to the traditional back-propagation method (e.g. SGD) which gives very close classification accuracy in a very few rounds of updates. In this project, I tried to reproduce RSO function from the paper with simpler convolutional neural network (1 convolutional layer) and compared its classification accuracy to backpropagation method.

**!!IMPORTANT!!**\
Before you open and run the notebook, install MLDatasets.jl package so that you can access to MNIST dataset:
**Pkg.add("MLDatasets")**

Then, my notebook will do the rest! :)
