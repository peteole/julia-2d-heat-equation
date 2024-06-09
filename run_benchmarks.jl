using YAML

# Ensure that the benchmark_results.yaml file exists
if !isfile("benchmark_results.yaml")
    YAML.write_file("benchmark_results.yaml", Dict())
end

benchmark_filter = name -> true#startswith(name, "100")
implementaion_filter = impl_name -> true

benchmarks = YAML.load_file("benchmark_results.yaml")
benchmark_names = readdir("benchmark_configs/")
sort!(benchmark_names, by=name->parse(Int, split(name, ".")[1]))
for benchmark in benchmark_names
    # for each folder in `implementations`
    if !benchmark_filter(benchmark)
        continue
    end
    if !haskey(benchmarks, benchmark)
        benchmarks[benchmark] = Dict()
    end
    for implementation in readdir("implementations/")
        if !implementaion_filter(implementation)
            continue
        end
        if !ispath("implementations/$implementation/benchmark.sh")
            continue
        end
        try
            println("Running benchmark $benchmark for $implementation")
            proc=run(Cmd(`timeout 600 ./benchmark.sh ../../benchmark_configs/$benchmark`; dir="implementations/$implementation"))
            if proc.exitcode == 124
                println("Benchmark $benchmark timed out for $implementation")
                continue
            end
        catch e
            if isa(e, ProcessFailedException)
                println("Benchmark $benchmark failed for $implementation")
                continue
            else
                rethrow(e)
            end
        end
        benchmarks[benchmark][implementation] = YAML.load_file("implementations/$implementation/benchmark_results.yaml")
        YAML.write_file("benchmark_results.yaml", benchmarks)
    end
end
YAML.write_file("benchmark_results.yaml", benchmarks)