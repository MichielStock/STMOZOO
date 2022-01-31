# Cross-Entropy method
By Ceri-Anne Laureyssens

The notebook gives an introduction to cross-entropy and its use in the cross-entropy method. Cross-entropy is a metric used to measure the Kullback-Leibler (KL) distance between two probability distributions (f and g). The cross-entropy method is a Monte Carlo method for importance sampling and optimization and is found by minimizing the previously called KL distance in between distribution f and g (parameterized by θ). This is equivalent to choosing θ that minimizes the cross-entropy.

The notebook provides an implementation of the cross entropy method for optimizing multivariate time series distributions. Suppose we have a timeseries `X = {x₁, ..., xₙ}` where each `xᵢ` is a vector of dimension `m`. The `cross_entropy_method` function can handle two different scenarios:

1. The time series is sampled IID from a single distribution `p`: `xᵢ ~ p(x)`. In this case, the distribution is represented as a `Dict{Symbol, Tuple{Sampleable, Int64}}`. The dictionary will contain `m` symbols, one for each variable in the series. The `Sampleable` object represents `p` and the integer is the length of the timeseries (`N`).
2. The time series is sampled from a different distribution at each timestep `pᵢ`: `xᵢ ~ pᵢ(x)`. In this case, the distribution is also represented as a `Dict{Symbol, Tuple{Sampleable, Int64}}`.

Finishing off the notebook provides a fun little example implementing the CE method in the importance sampling technique.

[![Build Status](https://travis-ci.org/MichielStock/STMOZOO.svg?branch=master)](https://travis-ci.org/MichielStock/STMOZOO)[![Coverage Status](https://coveralls.io/repos/github/MichielStock/STMOZOO/badge.svg?branch=master)](https://coveralls.io/github/MichielStock/STMOZOO?branch=master)
