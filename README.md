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

According to the original paper (https://arxiv.org/abs/2005.05955),there are some **advantages** in using RSO over using backpropagation with SGD. 
- RSO gives very close classification accuracy to SGD in a very few rounds of updates.
- RSO requires fewer weight updates compared to SGD to find good minimizers for deep neural networks.
- RSO can make aggressive weight updates in each step as there is no concept of learning rate.
- The weight update step for individual layers is not coupled with the magnitude of the loss.
- As a new optimization method in training deep neural networks, RSO potentially lead to a different class of training architectures.

However, RSO also has a **drawback** in terms of computational cost. Since it requires updates which are proportional to the number of network parameters, it can be very computationally expensive. The author of the paper however suggests that this issue can be solved and could be a viable alternative to back-propagation if the number of trainable parameters are reduced drastically.

In this project, I tried to reproduce the RSO function from the paper with simpler convolutional neural network (1 convolutional layer) and compared its classification accuracy to a backpropagation method (SGD). In addition explored how the RSO algorithm performs in different models and batch sizes.

**!!IMPORTANT!!**\
Before you open and run the notebook, install MLDatasets.jl package so that you can access to MNIST dataset:
**Pkg.add("MLDatasets")**

Then, my notebook will do the rest! :)
