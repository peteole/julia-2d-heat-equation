#include "utility.hpp"

template<typename T>
class NaiveProblem : Problem<T>{

    void step() override{

    }


    NaiveProblem(std::string filename) : Problem(filename){

    }
};