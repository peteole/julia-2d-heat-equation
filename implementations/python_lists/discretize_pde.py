import numpy as np
import pyvista as pv
import os
import shutil
def discretize_heat_equation(N:int, dt:float, t_end:float, write_every:int):
    shutil.rmtree("output", ignore_errors=True)
    os.makedirs("output", exist_ok=True)
    t = 0
    h = 1 / (N - 1)
    u = np.ones((N, N))
    u[0:N, 0] = 0
    u[0:N, N - 1] = 0
    u[0, 0:N - 1] = 0
    u[N - 1, 0:N - 1] = 0
    u=u.tolist()
    # Define the convolutional layer
    iteration=0
    while t < t_end:
        u_tmp = u
        for i in range(1,N-1):
            for j in range(1,N- 1):
                u_tmp[i][ j] = u[i][ j] + dt / (4 * h * h) * (u[i-1][ j] + u[i+1][ j] + u[i][ j-1] + u[i][j+1] - 4 * u[i][ j])
        u = u_tmp
        t += dt
        if write_every != -1 and iteration % write_every == 0:
            print(f"Writing output at iteration {iteration}")
            grid = pv.grid.ImageData(dimensions=(N, N, 1))
            # Convert the torch tensor to a numpy array
            # Convert the numpy array to a vtk array
            grid["temperature"] = np.array(u).flatten(order="F")
            grid.save(f"output/{iteration}.vti")
        iteration += 1
            
        