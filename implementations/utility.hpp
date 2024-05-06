#include <yaml-cpp/yaml.h>
#include <fstream>
#include <iostream>
#include <tuple>
#include <vector>
#include <string>
#include <exception>

/*
* @brief Read the program parameters from the provided file
* @param[in] Name of the file to read from
* @param[out] Tuple of N, dt, t_end and the number of iterations between outputs
*/
std::tuple<uint32_t, double, double, uint32_t> read_yaml(std::string filename){
    // open file. partially generated with ChatGPT
    std::ifstream file_in(filename);
    if(!file_in){
        std::cerr << "failed to open file \"" << filename << "\"" << std::endl;
        throw std::runtime_error("Could not read provided configuration file");
    }

    YAML::Node config = YAML::Load(file_in);

    uint32_t N = 100;
    double dt = 0.01;
    double t_end = 1;
    uint32_t write_every = 100;

    // get values from yaml if they exist. Partially generated with ChatGPT
    if(config["N"]) N = config["N"].as<uint32_t>();
    if(config["dt"]) dt = config["dt"].as<double>();
    if(config["t_end"]) t_end = config["t_end"].as<double>();
    if(config["write_every"]) write_every = config["write_every"].as<uint32_t>();

    return std::make_tuple(N, dt, t_end, write_every);
}

/*
* @brief Set up domain boundaries. Assume all domain cells already have initial state
* @param[inout] Reference to the vector of vectors where the boundaries will be set up.
*/
template<typename T>
void set_up_boundaries(std::vector<std::vector<T>>& array){
    uint size = array.size();
    for(uint i = 1; i < array.size() - 1; i++){
        if(size != array[i].size())throw std::runtime_error("domain is not square");
        array[i][0] = 0;
        array[i][size - 1] = 0;
        array[0][i] = 0;
        array[size - 1][i] = 0;
    }
    //less relevant for correctness of stencil computations, only for visualization
    array[0][0] = 0;
    array[size - 1][0] = 0;
    array[0][size - 1] = 0;
    array[size - 1][size - 1] = 0;
}