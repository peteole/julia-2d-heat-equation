using WriteVTK
using Metal
function discretize_heat_equation(N::Int, dt::Float64, t_end::Float64, write_every::Int)
    pvd = paraview_collection("output/solution.pvd")
    h = 1 / (N - 1) |> Float32
    dt = dt |> Float32
    x = 0:h:1
    y = 0:h:1

    U::MtlArray{Float32,2} = MtlArray{Float32,2}(undef, N, N)
    U .= 1
    # set boundary conditions to 0
    U[1, :] .= 0
    U[N, :] .= 0
    U[:, 1] .= 0
    U[:, N] .= 0
    U_new::MtlArray{Float32,2} = MtlArray{Float32,2}(undef, N, N)
    U_new .= 0

    function kernel(U, U_new)
        i, j = thread_position_in_grid_2d()
        if i == 1 || i == N || j == 1 || j == N
            U_new[i, j] = 0
        elseif i > 1 && i < N && j > 1 && j < N
            U_new[i, j] = U[i, j] + dt / (4 * h^2) * (U[i-1, j] + U[i+1, j] + U[i, j-1] + U[i, j+1] - 4 * U[i, j])
        end
        return
    end

    max_threads = 1024
    threads = (floor(Int, sqrt(max_threads)), floor(Int, sqrt(max_threads)))
    groups = (ceil(Int, N / threads[1]), ceil(Int, N / threads[2]))
    println("threads: ", threads, " groups: ", groups)
    for (iteration, t) = enumerate(0:dt:t_end)
        Metal.@sync @metal threads = threads groups = groups kernel(U, U_new)
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