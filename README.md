# hpc-lab

We compute the 2d heat equation using explicit euler method:

$$
\frac{\partial u}{\partial t} = \nabla^2 u\\
u(x, y, 0) = 1\\
u(x, y, t) = 0 \quad \text{for} \quad x = 0, x = 1, y = 0, y = 1
$$

where $u$ is the temperature field.

The discretization is described in a config file of the following form:
```yaml
discretization:
  N: 100
  dt: 0.01
t_end: 3.0
write_every: 10
```
The discretization works using the following scheme:
$$
u_{i,j}^t \approx u(x_i, y_j, t)\\
x_i = i \cdot h\\
y_j = j \cdot h\\
t_n = n \cdot \Delta t\\
h = \frac{1}{N-1}\\
\Delta t = dt\\
u_{i,j}^{t+1} = u_{i,j}^t + \frac{\Delta}{4h^2} \cdot (u_{i+1,j}^t + u_{i-1,j}^t + u_{i,j+1}^t + u_{i,j-1}^t - 4 \cdot u_{i,j}^t)\\
u_{i,j}^0 = 1\\
u_{i,j}^t = 0 \quad \text{for} \quad i = 0, i = n, j = 0, j = n
$$

$N$ is the number of grid points in each direction including ghost cells. Therefore, the grid size is $1/(N-1)$.

The solver will compute the discretization every `write_every` steps and write the result to a file called `output/{step}.vtr` with a field called `temperature`.