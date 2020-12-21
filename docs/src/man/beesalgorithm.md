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