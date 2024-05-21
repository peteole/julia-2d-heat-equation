#include <chrono>
#include "discretize_pde.hpp"
#include <vector>
#include <yaml-cpp/yaml.h>
#include <algorithm>
#include <numeric> 


#define NUM_EXPERIMENTS 10
int main(int argc, char* argv[]){
    if(argc != 2){
        std::cout << "Call this program with exactly one parameter.\nUsage: naive <Name of Config file>";
    }
    auto config=ProblemConfig<double>(argv[1]);
    int num_experiments=10;
    auto times=std::vector<double>(NUM_EXPERIMENTS);
    for(int i=0;i<NUM_EXPERIMENTS;i++){
        auto start = std::chrono::steady_clock::now();
        discretize_heat_equation<double>(config);
        auto end = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
        times[i]=duration/1000.0;
    }
    std::sort(times.begin(),times.end());
    auto mean=std::accumulate(times.begin(),times.end(),0.0)/NUM_EXPERIMENTS;
    auto std_dev=std::sqrt(std::inner_product(times.begin(), times.end(), times.begin(), 0.0)/NUM_EXPERIMENTS - mean*mean);
    auto median=times[NUM_EXPERIMENTS/2];
    auto min=times[0];
    auto max=times[NUM_EXPERIMENTS-1];
    //write to benchmark_results.yaml
    // keys are time.mean, time.std_dev, time.median, time.min, time.max
    YAML::Emitter out;
    out << YAML::BeginMap;
    out << YAML::Key << "time";
    out << YAML::Value << YAML::BeginMap; // Begin nested map
    out << YAML::Key << "mean";
    out << YAML::Value << mean;
    out << YAML::Key << "std_dev";
    out << YAML::Value << std_dev;
    out << YAML::Key << "median";
    out << YAML::Value << median;
    out << YAML::Key << "min";
    out << YAML::Value << min;
    out << YAML::Key << "max";
    out << YAML::Value << max;
    out << YAML::EndMap; // End nested map
    out <<YAML::Key << "time_unit";
    out <<YAML::Value << "s";
    out << YAML::EndMap;

    std::ofstream file_out("benchmark_results.yaml");
    file_out << out.c_str();
    file_out.close();
    

}