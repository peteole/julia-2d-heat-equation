using YAML
rm("output_raw", recursive=true, force=true)
mkpath("output_raw")
config_path = length(ARGS)==1 ? ARGS[1] : "../../config.yaml"
config = YAML.load_file(config_path)
#display(config)
N = config["discretization"]["N"]
dt = config["discretization"]["dt"]
t_end = config["t_end"]
write_every = config["write_every"]
run(`./main $N $dt $t_end $write_every`)
include("convert_output.jl")