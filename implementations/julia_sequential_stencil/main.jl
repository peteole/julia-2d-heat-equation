using YAML
using WriteVTK
mkpath("output")
config = YAML.load_file(ARGS[1])
#display(config)
N = config["discretization"]["N"]
dt = config["discretization"]["dt"]
t_end = config["t_end"]
write_every = config["write_every"]
h = 1 / (N - 1)
function discretize_heat_equation(N, dt, t_end, write_every)
    pvd = paraview_collection("output/solution.pvd")
    x=0:h:1
    y=0:h:1

    U = ones(N, N)
    # set boundary conditions to 0
    U[1, :] .= 0
    U[N, :] .= 0
    U[:, 1] .= 0
    U[:, N] .= 0
    U_new = zeros(N, N)


    for (iteration,t) = enumerate(0:dt:t_end)
        for i = 2:N-1
            for j = 2:N-1
                U_new[i, j] = U[i, j] + dt / (4 * h) * (U[i-1, j] + U[i+1, j] + U[i, j-1] + U[i, j+1] - 4 * U[i, j])
            end
        end
        U = U_new
        if write_every!=-1 && iteration % write_every == 0
            vtk_grid("output/$(iteration)",x, y) do vtk
                vtk["temperature"] = U[:]
                vtk["TimeValue"] = t
                pvd[t]=vtk
            end
        end
    end
    vtk_save(pvd)
end
@time discretize_heat_equation(N, dt, t_end, write_every)