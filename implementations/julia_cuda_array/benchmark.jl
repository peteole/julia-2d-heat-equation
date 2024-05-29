using YAML
using BenchmarkTools
include("discretize_pde.jl")
rm("output", recursive=true, force=true)
mkpath("output")
config_path = length(ARGS) == 1 ? ARGS[1] : "../../config.yaml"
config = YAML.load_file(config_path)
#display(config)
N = config["discretization"]["N"]
dt = config["discretization"]["dt"]
t_end = config["t_end"]
write_every = config["write_every"]

t = @benchmark discretize_heat_equation(N, Float32(dt), Float32(t_end), write_every)
display(t)
times= t.times ./ 1e9
YAML.write_file("benchmark_results.yaml", Dict(
    "time" => Dict(
        "mean" => mean(times),
        "std" => std(times),
        "median" => median(times),
        "min" => minimum(times),
        "max" => maximum(times)
    ),
    "time_unit" => "s",
    "memory" => t.memory
))