using YAML
include("discretize_pde.jl")
mkpath("output")
config_path = length(ARGS)==1 ? ARGS[1] : "../../config.yaml"
config = YAML.load_file(config_path)
#display(config)
N = config["discretization"]["N"]
dt = config["discretization"]["dt"]
t_end = config["t_end"]
write_every = config["write_every"]

@time discretize_heat_equation(N, dt, t_end, write_every)