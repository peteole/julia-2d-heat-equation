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
    u=u.tolist()
    # Define the convolutional layer
    iteration=1
    for t in tqdm.tqdm(np.arange(0, t_end, dt)):
        u_tmp = u
        for i in range(1,N-1):
            for j in range(1,N- 1):
                u_tmp[i][ j] = u[i][ j] + dt / (h * h) * (u[i-1][ j] + u[i+1][ j] + u[i][ j-1] + u[i][j+1] - 4 * u[i][ j])
        u = u_tmp
        if write_every != -1 and iteration % write_every == 0:
            grid = pv.grid.ImageData(dimensions=(N, N, 1))
            # Convert the torch tensor to a numpy array
            # Convert the numpy array to a vtk array
            grid["temperature"] = np.array(u).flatten(order="F")
            grid.save(f"output/{iteration}.vti")
        iteration += 1
            
        