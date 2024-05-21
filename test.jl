using ReadVTK
using LinearAlgebra
function load_implementation_output(implementation::String, iteration::Int)
    try
        vtk = VTKFile("implementations/$implementation/output/$iteration.vti")
        temperatures_raw=get_point_data(vtk)["temperature"]
        temperatures=get_data_reshaped(temperatures_raw)
        return temperatures
    catch e
        println("Could not load output for $implementation iteration $iteration: $e")
        return nothing
    end
end

function load_implementation_outputs(implementation::String)
    solutions = readdir("implementations/$implementation/output")
    solution_iterations = [parse(Int, split(solution, ".")[1]) for solution in solutions if occursin(".vti", solution)]
    sort!(solution_iterations)
    solutions = [load_implementation_output(implementation, iteration) for iteration in solution_iterations]
end

reference_outputs = load_implementation_outputs("julia_sequential_stencil")


for implementation in readdir("implementations")
    if isdir("implementations/$implementation")
        println("Testing output of $implementation")
        if !isdir("implementations/$implementation/output")
            println("No output directory found for $implementation")
            continue
        end
        implementation_outputs=load_implementation_outputs(implementation)
        if any(isnothing, implementation_outputs)
            println("Could not load all outputs for $implementation")
            continue
        end
        norm_diff_sum = 0
        for (reference_output, implementation_output) in zip(reference_outputs, implementation_outputs)
            norm_diff = norm(reference_output - implementation_output)
            norm_diff_sum += norm_diff
        end
        println("Norm of differences: $norm_diff_sum")
    end
end