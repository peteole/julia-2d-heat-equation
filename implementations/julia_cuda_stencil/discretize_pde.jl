using WriteVTK
using CUDA
using ProgressBars

function heat_kernel(U, U_new, dt, h, N)
    j = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    i = threadIdx().y + (blockIdx().y - 1) * blockDim().y
    if i < N && j < N && i > 1 && j > 1
        @inbounds U_new[i, j] = U[i, j] + dt / (h^2) * (U[i-1, j] + U[i + 1, j] + U[i, j - 1] + U[i, j + 1] - 4 * U[i, j])
    end
    return
end

function discretize_heat_equation(N::Int, dt, t_end, write_every::Int)
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
    #print("array setup complete\n")

    block_size = (8, 8)
    grid_size = (ceil(Int, N / block_size[1]), ceil(Int, N / block_size[2]))
    for (iteration, t) = ProgressBar(enumerate(0:dt:t_end))
        #print("launching kernel\n")
        CUDA.@sync @cuda threads=block_size blocks=grid_size heat_kernel(U, U_new, dt, h, N)
        #print("iteration complete")
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