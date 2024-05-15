#include "utility.hpp"
#include <chrono>

template<typename T>
class NaiveProblem : public Problem<T>{
    public:
    void step() override{
        for(int i = 1; i < Problem<T>::N - 1; i++){
            for(int j = 1; j < Problem<T>::N - 1; j++){
                Problem<T>::u_temp[i][j] = Problem<T>::u[i][j] + Problem<T>::dt / (4 * Problem<T>::h * Problem<T>::h) * (Problem<T>::u[i - 1][j] + Problem<T>::u[i + 1][j] + Problem<T>::u[i][j + 1] + Problem<T>::u[i][j - 1] - 4* Problem<T>::u[i][j]);
            }
        }

        std::swap(Problem<T>::u_temp, Problem<T>::u);
    }

    
    NaiveProblem(std::string filename) : Problem<T>(filename){

    }
};

int main(int argc, char* argv[]){
    if(argc != 2){
        std::cout << "Call this program with exactly one parameter.\nUsage: naive <Name of Config file>";
    }

    NaiveProblem<double> problem(argv[1]);
    auto start = std::chrono::steady_clock::now();
    problem.solve();
    auto end = std::chrono::steady_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    std::cout << "Calculated " << static_cast<int>(problem.t_end / problem.dt) << " iterations in " << duration << " milliseconds" << std::endl;
}