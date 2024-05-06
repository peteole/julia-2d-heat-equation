#include <yaml-cpp/yaml.h>
#include <fstream>
#include <iostream>
#include <tuple>
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

    // 
    for(const auto& pair : config){
        if(config["N"]) N = config["N"].as<uint32_t>();
        if(config["dt"]) dt = config["dt"].as<double>();
        if(config["t_end"]) t_end = config["t_end"].as<double>();
        if(config["write_every"]) write_every = config["write_every"].as<uint32_t>();
    }

    return std::make_tuple(N, dt, t_end, write_every);
}

