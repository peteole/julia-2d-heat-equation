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
    flops=N**2*t_end/dt
    max_flops=800**2*5000
    speedup_factor=max(1,flops/max_flops) # >1 if we need to speed up
    assert speedup_factor <= t_end/dt/5 , "speedup factor too big"
    t_end=t_end/speedup_factor
    #benchmark
    num_iterations=5
    times=[]
    for i in range(num_iterations):
        start=time.time()
        discretize_heat_equation(N, dt, t_end, write_every)
        end=time.time()
        times.append((end-start)*speedup_factor)
    output_file="benchmark_results.yaml"
    yaml.dump({"time":{
            "mean":np.mean(times).item(),
            "std":np.std(times).item(),
            "min":np.min(times).item(),
            "max":np.max(times).item(),
            "median":np.median(times).item()
        },"time_unit":"s"},open(output_file,"w"))
    
    