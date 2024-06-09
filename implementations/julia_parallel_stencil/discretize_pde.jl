using WriteVTK
using ProgressBars
function discretize_heat_equation(N::Int, dt::Float64, t_end::Float64, write_every::Int)
    pvd = paraview_collection("output/solution.pvd")
    h = 1 / (N - 1)
    x=0:h:1
    y=0:h:1

    U::Matrix{Float64} = ones(N, N)
    # set boundary conditions to 0
    U[1, :] .= 0
    U[N, :] .= 0
    U[:, 1] .= 0
    U[:, N] .= 0
    U_new::Matrix{Float64}= copy(U)

    println("Running with $(Threads.nthreads()) threads")
    for (iteration,t) in ProgressBar(enumerate(0:dt:t_end))
        Threads.@threads :static for j = 2:N-1
            for i = 2:N-1
                @inbounds U_new[i, j] = U[i, j] + dt / (h^2) * (U[i-1, j] + U[i+1, j] + U[i, j-1] + U[i, j+1] - 4 * U[i, j])
            end
        end
        if write_every!=-1 && iteration % write_every == 0
            vtk_grid("output/$(iteration)",x, y) do vtk
                vtk["temperature"] = U[:]
                vtk["TimeValue"] = t
                pvd[t]=vtk
            end
        end
        U, U_new = U_new, U
    end
    vtk_save(pvd)
end