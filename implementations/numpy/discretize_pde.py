import numpy as np
import pyvista as pv
import os
import shutil
import tqdm
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
    # Define the convolutional layer
    iteration=1
    for t in tqdm.tqdm(np.arange(0, t_end, dt)):
        u[ 1:-1, 1:-1] +=dt / (4 * h * h) * (u[0:-2, 1:-1] + u[2:, 1:-1] + u[1:-1,0:-2] + u[1:-1,2:] - 4 * u[1:-1, 1:-1])
        t += dt
        if write_every != -1 and iteration % write_every == 0:
            print(f"Writing output at iteration {iteration}")
            grid = pv.grid.ImageData(dimensions=(N, N, 1))
            # Convert the torch tensor to a numpy array
            # Convert the numpy array to a vtk array
            grid["temperature"] = u.flatten(order="F")
            grid.save(f"output/{iteration}.vti")
        iteration += 1
            
        