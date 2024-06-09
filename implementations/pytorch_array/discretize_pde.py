import torch
import pyvista as pv
import os
import shutil
import tqdm
import numpy as np
def discretize_heat_equation(N:int, dt:float, t_end:float, write_every:int,device="cuda"):
    shutil.rmtree("output", ignore_errors=True)
    os.makedirs("output", exist_ok=True)
    t = 0
    h = 1 / (N - 1)
    u = torch.ones((N, N), device=device)
    u[0:N, 0] = 0
    u[0:N, N - 1] = 0
    u[0, 0:N - 1] = 0
    u[N - 1, 0:N - 1] = 0
    u.requires_grad_(False)
    with torch.no_grad():
        # Define the convolutional layer
        iteration=1
        #while t < t_end:
        for t in tqdm.tqdm(np.arange(0, t_end, dt)):
            u[ 1:-1, 1:-1] +=dt / (h * h) * (u[0:-2, 1:-1] + u[2:, 1:-1] + u[1:-1,0:-2] + u[1:-1,2:] - 4 * u[1:-1, 1:-1])
            if write_every != -1 and iteration % write_every == 0:
                grid = pv.grid.ImageData(dimensions=(N, N, 1))
                # Convert the torch tensor to a numpy array
                # Convert the numpy array to a vtk array
                grid["temperature"] = u.cpu().numpy().flatten(order="F")
                grid.save(f"output/{iteration}.vti")
            iteration += 1
                
            