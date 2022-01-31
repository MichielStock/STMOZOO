# Neural Network

Here, we basically have the main module of the whole project. The neural network architecture is defined in this module, as well as functions to train it, to retrieve an optimization strategy or obtain information about training loss and accuracy.

```@docs
get_loss_and_accuracy
train
```

Private helper methods:
```@docs
neural_network
get_optimizer
```