using YAML
using BenchmarkTools
rm("output_raw", recursive=true, force=true)
mkpath("output_raw")
t = @benchmark run(`./main $(ARGS[1])`)
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