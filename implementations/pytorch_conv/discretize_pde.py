import torch
from torch import nn
import pyvista as pv
import os
import shutil
def discretize_heat_equation(N:int, dt:float, t_end:float, write_every:int,device="cuda"):
    shutil.rmtree("output", ignore_errors=True)
    os.makedirs("output", exist_ok=True)
    t = 0
    h = 1 / (N - 1)
    gpu_u = torch.ones((N, N), device=device)
    gpu_u[0:N, 0] = 0
    gpu_u[0:N, N - 1] = 0
    gpu_u[0, 0:N - 1] = 0
    gpu_u[N - 1, 0:N - 1] = 0
    gpu_u = gpu_u.unsqueeze(0)
    gpu_u.requires_grad_(False)
    with torch.no_grad():
        # Define the convolutional layer
        conv_layer = nn.Conv2d(in_channels=1, out_channels=1, kernel_size=3, bias=False)

        # Set custom values for weights
        custom_weights = torch.tensor([[[[0., 1, 0], [1, -4, 1], [0, 1, 0]]]], device=device)
        conv_layer.weight = nn.Parameter(custom_weights)
        iteration=0
        while t < t_end:
            gpu_u[:, 1:-1, 1:-1] += dt / (4 * h * h) * conv_layer(gpu_u)
            t += dt
            if write_every != -1 and iteration % write_every == 0:
                print(f"Writing output at iteration {iteration}")
                grid = pv.grid.ImageData(dimensions=(N, N, 1))
                # Convert the torch tensor to a numpy array
                u = gpu_u.to("cpu").squeeze(0).numpy()
                # Convert the numpy array to a vtk array
                grid["temperature"] = u.flatten(order="F")
                grid.save(f"output/{iteration}.vti")
            iteration += 1
                
            