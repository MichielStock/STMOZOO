# Plot Library

To avoid naming confusion with `Plots`, my plot module was coined `PlotLib` and contains solely functions that are concerned with the creation of plots. Thus, all of these return ready to display `PlotlyJS` plots. In contrast to the functionality provided in `Figures`, functions presented here are more raw or general purpose in the sense that they plot a certain aspect of the neural network and the training process.

```@docs
plot_train_and_test_data
plot_loss_and_accuracy
plot_features
plot_decision_boundary
```