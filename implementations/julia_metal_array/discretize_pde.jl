using WriteVTK
using Metal
using ProgressBars
function discretize_heat_equation(N::Int, dt::Float32, t_end::Float32, write_every::Int)
    pvd = paraview_collection("output/solution.pvd")
    h = Float32(1 / (N - 1))
    x = 0:h:1
    y = 0:h:1

    U::MtlArray{Float32} = MtlArray{Float32}(undef, N, N)
    U .= 1
    # set boundary conditions to 0
    U[1, :] .= 0
    U[N, :] .= 0
    U[:, 1] .= 0
    U[:, N] .= 0

    U_new::MtlArray{Float32} = copy(U)


    for (iteration, t) in ProgressBar(enumerate(0:dt:t_end))
        U_new[2:end-1, 2:end-1] .= U[2:end-1, 2:end-1] .+ dt / (4 * h^2) .* (
            U[1:end-2, 2:end-1] .+
            U[3:end, 2:end-1] .+
            U[2:end-1, 1:end-2] .+
            U[2:end-1, 3:end] .- 4 .* U[2:end-1, 2:end-1]
        )
        if write_every != -1 && iteration % write_every == 0
            vtk_grid("output/$(iteration)", x, y) do vtk
                vtk["temperature"] = Array(U)[:]
                vtk["TimeValue"] = t
                pvd[t] = vtk
            end
        end
        U, U_new = U_new, U
    end
    vtk_save(pvd)
end