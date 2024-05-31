using YAML

benchmarks = Dict()
for benchmark in readdir("benchmark_configs/")
    # for each folder in `implementations`
    benchmarks[benchmark] = Dict()
    for implementation in readdir("implementations/")
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
    end
end
YAML.write_file("benchmark_results.yaml", benchmarks)