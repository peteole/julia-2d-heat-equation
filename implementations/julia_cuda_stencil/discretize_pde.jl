using WriteVTK
using CUDA

function heat_kernel(U, U_new, dt, h)
    i = thread_index.x + 2
    j = thread_index.y + 2
    U_new[i, j] = U[i, j] + dt / (4 * h^2) * (U[i-1, j] + U[i + 1, j] + U[i, j - 1] + U[i, j + 1] - 4 * U[i, j])
end

function discretize_heat_equation(N::Int, dt::Float32, t_end::Float32, write_every::Int)
    pvd = paraview_collection("output/solution.pvd")
    h = Float32(1 / (N - 1))
    x = 0:h:1
    y = 0:h:1

    U::CuArray{Float32} = CuArray{Float32}(undef, N, N)
    U .= 1
    # set boundary conditions to 0
    U[1, :] .= 0
    U[N, :] .= 0
    U[:, 1] .= 0
    U[:, N] .= 0

    U_new::CuArray{Float32} = copy(U)

    for (iteration, t) = enumerate(0:dt:t_end)
        print("launch kernel")
        @cuda threads=(N - 2, N - 2) heat_kernel(U, U_new, dt, h)
        print("iteration complete")
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