using YAML
include("discretize_pde.jl")
rm("output", recursive=true, force=true)
mkpath("output")
config_path = length(ARGS)==1 ? ARGS[1] : "../../config.yaml"
config = YAML.load_file(config_path)
#display(config)
N = config["discretization"]["N"]
dt = config["discretization"]["dt"]
t_end = config["t_end"]
write_every = config["write_every"]

@time discretize_heat_equation(N, Float32(dt), Float32(t_end), write_every)