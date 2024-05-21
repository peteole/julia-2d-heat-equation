import numpy as np
import torch
import torch.nn as nn
import yaml

class Problem:
    def __init__(self, filename) -> None:
        
        # load configuration file
        with open(filename) as stream:
            node = yaml.safe_load(stream)
            self.N = node["discretization"]["N"]
            self.h = 1 / (self.N - 3)
            self.dt = node["discretization"]["dt"]
            self.t_end = node["t_end"]
            self.write_every = node["write_every"]
            
        # initialize numpy domain as ones 
        self.u = np.ones((self.N, self.N))
        
        # set up boundary conditions
        self.u[0:self.N, 0] = 0
        self.u[0:self.N, self.N - 1] = 0
        self.u[0, 0:self.N - 1] = 0
        self.u[self.N - 1, 0:self.N - 1] = 0
        
    def solve(self, step):
        t = 0
        while t < self.t_end:
            self.domain = step()
            t += self.dt
            
    def solve_torch_conv(self):
        t = 0
        gpu_u = torch.tensor(self.u).unsqueeze(0).to("cuda")
        gpu_u.requires_grad_(False)
        with torch.no_grad():
            # Define the convolutional layer
            conv_layer = nn.Conv2d(in_channels=1, out_channels=1, kernel_size=3, bias=False)

            # Set custom values for weights
            custom_weights = torch.tensor([[[[0, 1, 0], [1, -4, 1], [0, 1, 0]]]], dtype=torch.float64)  # Example custom weights
            conv_layer.weight = nn.Parameter(custom_weights)
            conv_layer = conv_layer.to("cuda")

            while t < self.t_end:
                gpu_u[:, 1:-1, 1:-1] += self.dt / (4 * self.h * self.h) * conv_layer(gpu_u)
                t += self.dt
            self.u = gpu_u.to("cpu").squeeze(0).numpy()

    def solve_torch_array(self):
        t = 0
        gpu_u = torch.tensor(self.u).to("cuda")
        gpu_u.requires_grad_(False)
        with torch.no_grad():
            while t < self.t_end:
                gpu_u[1:-1, 1:-1] += self.dt / (4 * self.h * self.h) * (gpu_u[0:-2, 1:-1] + gpu_u[2:, 1:-1] + gpu_u[1:-1,0:-2] + gpu_u[1:-1,2:] - 4 * gpu_u[1:-1, 1:-1])
                t += self.dt
            self.u = gpu_u.to("cpu").numpy()      
        
    def naive_step(self):
        u = self.u
        u_tmp = u
          
        for i in range(1, u.shape[0] - 1):
            for j in range(1, u.shape[1] - 1):
                u_tmp[i, j] = u[i, j] + self.dt / (4 * self.h * self.h) * (u[i-1, j] + u[i+1, j] + u[i, j-1] + u[i,j+1] - 4 * u[i, j])
        self.u = u_tmp
        
    def np_step(self):
        self.u[1:-1, 1:-1] += self.dt / (4 * self.h * self.h) * (self.u[0:-2, 1:-1] + self.u[2:, 1:-1] + self.u[1:-1,0:-2] + self.u[1:-1,2:] - 4 * self.u[1:-1, 1:-1])
        
 