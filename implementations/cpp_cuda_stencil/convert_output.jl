using WriteVTK
using YAML

rm("output", recursive=true, force=true)
mkpath("output")
pvd = paraview_collection("output/solution.pvd")
for file in readdir("output_raw/")
    base_name=replace(file, ".txt" => "")
    iteration=parse(Int,first(split(base_name, ",")))
    t=parse(Float64,last(split(base_name, ",")))
    open("output_raw/" * file) do f
        data = read(f, String)
        lines=split(data, "\n")
        lines_split = [split(line," "; keepempty=false) for line in lines if line != ""]
        #display(lines_split)
        N=length(lines_split)
        h=1/(N-1)
        x=0:h:1
        y=0:h:1

        U=[parse(Float64, lines_split[i][j]) for i in 1:N, j in 1:N]
        vtk_grid("output/$(iteration)",x, y) do vtk
            vtk["temperature"] = U[:]
            vtk["TimeValue"] = t
            pvd[t]=vtk
        end
    end
end
vtk_save(pvd)
