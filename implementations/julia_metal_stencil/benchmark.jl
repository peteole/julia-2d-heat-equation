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

t = @benchmark discretize_heat_equation(N, dt, t_end, write_every)
display(t)
times_s= t.times ./ 1e9
YAML.write_file("benchmark_results.yaml", Dict(
    "time" => Dict(
        "mean" => mean(times_s),
        "std" => std(times_s),
        "median" => median(times_s),
        "min" => minimum(times_s),
        "max" => maximum(times_s)
    ),
    "time_unit" => "s",
    "memory" => t.memory
))