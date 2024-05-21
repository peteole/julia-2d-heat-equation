#include <yaml-cpp/yaml.h>
#include <fstream>
#include <iostream>
#include <tuple>
#include <vector>
#include <string>
#include <exception>
#include <memory>

template <typename T>
struct ProblemConfig
{
    uint32_t N;
    double dt;
    double t_end;
    int write_every;

public:
    ProblemConfig(std::string filename)
    {
        // open file. partially generated with ChatGPT
        std::ifstream file_in(filename);
        if (!file_in)
        {
            std::cerr << "failed to open file \"" << filename << "\"" << std::endl;
            throw std::runtime_error("Could not read provided configuration file");
        }

        YAML::Node config = YAML::Load(file_in);

        N = 100;
        dt = 0.01;
        t_end = 1;
        write_every = 100;

        // get values from yaml if they exist. Partially generated with ChatGPT
        if (config["discretization"])
        {
            if (config["discretization"]["N"])
            {
                N = config["discretization"]["N"].as<uint32_t>();
            }
            else
                throw std::runtime_error("no N given");
            if (config["discretization"]["dt"])
                dt = config["discretization"]["dt"].as<T>();
            else
                throw std::runtime_error("no dt given");
        }
        if (config["t_end"])
            t_end = config["t_end"].as<T>();
        else
            throw std::runtime_error("no t_end given");
        if (config["write_every"])
            write_every = config["write_every"].as<int>();
        else
            throw std::runtime_error("no write_every given");

    }
};

template <typename T>
void discretize_heat_equation(ProblemConfig<T> config)
{

    auto u = std::vector<std::vector<T>>(config.N, std::vector<T>(config.N, 1));
    auto u_temp = std::vector<std::vector<T>>(config.N, std::vector<T>(config.N, 1));
    T h = 1.0 / (config.N - 1);
    uint size = u.size();
    for (uint i = 1; i < u.size() - 1; i++)
    {
        if (size != u[i].size())
            throw std::runtime_error("domain is not square");
        u[i][0] = 0;
        u[i][size - 1] = 0;
        u[0][i] = 0;
        u[size - 1][i] = 0;
    }
    // less relevant for correctness of stencil computations, only for visualization
    u[0][0] = 0;
    u[size - 1][0] = 0;
    u[0][size - 1] = 0;
    u[size - 1][size - 1] = 0;
    for (double t = 0; t < config.t_end; t += config.dt)
    {
        for (int i = 1; i < config.N - 1; i++)
        {
            for (int j = 1; j < config.N - 1; j++)
            {
                u_temp[i][j] = u[i][j] + config.dt / (4 * h * h) * (u[i - 1][j] + u[i + 1][j] + u[i][j + 1] + u[i][j - 1] - 4 * u[i][j]);
            }
        }
        u = u_temp;
    }
}