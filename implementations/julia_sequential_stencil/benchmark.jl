using YAML
using BenchmarkTools
include("discretize_pde.jl")
mkpath("output")
config_path = length(ARGS) == 1 ? ARGS[1] : "../../config.yaml"
config = YAML.load_file(config_path)
#display(config)
N = config["discretization"]["N"]
dt = config["discretization"]["dt"]
t_end = config["t_end"]
write_every = config["write_every"]

t = @benchmark discretize_heat_equation(N, dt, t_end, write_every)
display(t)
display(t.memory)
YAML.write_file("benchmark_results.yaml", Dict(
    "time" => Dict(
        "mean" => mean(t.times),
        "std" => std(t.times),
        "median" => median(t.times),
        "min" => minimum(t.times),
        "max" => maximum(t.times)
    ),
    "time_unit" => "ns",
    "memory" => t.memory
))