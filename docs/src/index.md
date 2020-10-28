# STMO ZOO documentation

This is the documentation page for the STMO ZOO packages (edition 2020-2021). This is the place for the **documentation**
of your function. So explain the main functionality of your module and list the documentation of your funtions.

```@contents
```

## Example

This is the example code, written by Michiel Stock. It contains some basic functionality
to solve quadratic systems of the form:

``\min_{\mathbf{x}} \frac{1}{2} \mathbf{x}^\intercal P\mathbf{x} + \mathbf{q} \cdot \mathbf{x} + r\,,``

It contains a function to solve this optimization problem and a helper function that generates a quadratic function from
the parameters in their canonical form.

```@docs
solve_quadratic_system
quadratic_function
```