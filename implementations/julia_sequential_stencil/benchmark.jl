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

flops=N^2*t_end/dt
max_flops=1000^2*5000
speedup_factor=max(1,flops/max_flops) # >1 if we need to speed up
@info "Speedup factor" speedup_factor
@assert speedup_factor <= t_end/dt/5 "speedup factor too big"
t_end = t_end / speedup_factor

t = @benchmark discretize_heat_equation(N, dt, t_end, write_every)
display(t)
times_s= t.times ./ 1e9 .* speedup_factor
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