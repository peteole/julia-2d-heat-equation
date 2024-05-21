import yaml
import sys
from discretize_pde import discretize_heat_equation
import torch
filename = sys.argv[1]
with open(filename) as stream:
    node = yaml.safe_load(stream)
    N = node["discretization"]["N"]
    dt = node["discretization"]["dt"]
    t_end = node["t_end"]
    write_every = node["write_every"]
    device = "cuda" if torch.cuda.is_available() else "cpu"
    discretize_heat_equation(N, dt, t_end, write_every,device=device)