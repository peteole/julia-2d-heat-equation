#include <yaml-cpp/yaml.h>
#include <fstream>
#include <iostream>
#include <tuple>
#include <vector>
#include <string>
#include <exception>
#include <memory>

template <typename T>
class Problem
{
    private:

    /*
     * @brief Read the program parameters from the provided file
     * @param[in] Name of the file to read from
     * @param[out] Tuple of N, dt, t_end and the number of iterations between outputs
     */
    void read_yaml(std::string filename)
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
        if (config["N"])
            N = config["N"].as<uint32_t>();
        if (config["dt"])
            dt = config["dt"].as<double>();
        if (config["t_end"])
            t_end = config["t_end"].as<double>();
        if (config["write_every"])
            write_every = config["write_every"].as<uint32_t>();

        return std::make_tuple(N, dt, t_end, write_every);
    }

    /*
     * @brief Set up domain boundaries. Assume all domain cells already have initial state
     * @param[inout] Reference to the vector of vectors where the boundaries will be set up.
     */
    void boundary_setup()
    {
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
    }

protected:
    /*
    * @brief pointer to the array storing the temperature grid
    */
    std::shared_ptr<std::vector<std::vector<T>>>u;
    /*
    * @brief pointer to the temporary array
    */
    std::shared_ptr<std::vector<std::vector<T>>>u_temp;
    /*
    * @brief size of the domain including ghost cells
    */
    uint32_t N;
    /*
    * @brief time step size
    */
    T dt;
    /*
    * @brief maximum time
    */
    T t_end;
    /*
    * @brief specifies how many steps are performed between outputs.
    */
    uint32_t write_every;   


public:
    Problem(std::string filename)
    {
        read_yaml(filename);
        u = std::make_shared(N, std::vector<T>(N, 1));
        u_temp = std::make_shared(N, std::vector<T>(N, 1));
        boundary_setup();
    }

    /*
    * abstract method for performing a timestep
    */
    void step() = 0;

    void solve(){
        uint32_t it = 0;
        T time = 0;

        while(time < t_end){
            step();
            time += dt;
            it++;
        }
    }
};