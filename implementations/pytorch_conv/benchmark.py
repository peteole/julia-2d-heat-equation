import yaml
import sys
from discretize_pde import discretize_heat_equation
import torch
import time
import numpy as np
filename = sys.argv[1]
with open(filename) as stream:
    node = yaml.safe_load(stream)
    N = node["discretization"]["N"]
    dt = node["discretization"]["dt"]
    t_end = node["t_end"]
    write_every = node["write_every"]
    device = "cuda" if torch.cuda.is_available() else "cpu"
    #benchmark
    num_iterations=5
    times=[]
    for i in range(num_iterations):
        start=time.time()
        discretize_heat_equation(N, dt, t_end, write_every,device=device)
        end=time.time()
        times.append((end-start))
    output_file="benchmark_results.yaml"
    yaml.dump({"time":{
            "mean":np.mean(times).item(),
            "std":np.std(times).item(),
            "min":np.min(times).item(),
            "max":np.max(times).item(),
            "median":np.median(times).item()
        },"time_unit":"s"},open(output_file,"w"))
    
    