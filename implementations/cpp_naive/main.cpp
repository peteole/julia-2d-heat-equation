#include <chrono>
#include "discretize_pde.hpp"


int main(int argc, char* argv[]){
    if(argc != 2){
        std::cout << "Call this program with exactly one parameter.\nUsage: naive <Name of Config file>";
    }
    auto config=ProblemConfig<double>(argv[1]);
    discretize_heat_equation<double>(config);
}