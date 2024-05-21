#include <yaml-cpp/yaml.h>
#include <fstream>
#include <iostream>
#include <tuple>
#include <vector>
#include <string>
#include <exception>
#include <memory>


#include <vtkSmartPointer.h>
#include <vtkImageData.h>
#include <vtkDoubleArray.h>
#include <vtkPointData.h>
#include <vtkXMLImageDataWriter.h>


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
void write_vti_file(const std::vector<std::vector<T>>& data, int iteration, uint32_t N)
{
    std::cout << "writing iteration" << iteration << std::endl;
    auto imageData = vtkSmartPointer<vtkImageData>::New();
    imageData->SetDimensions(N, N, 1);
    imageData->AllocateScalars(VTK_DOUBLE, 1);

    auto temperatureArray = vtkSmartPointer<vtkDoubleArray>::New();
    temperatureArray->SetName("temperature");
    temperatureArray->SetNumberOfComponents(1);
    temperatureArray->SetNumberOfTuples(N * N);

    for (uint32_t i = 0; i < N; i++)
    {
        for (uint32_t j = 0; j < N; j++)
        {
            double* pixel = static_cast<double*>(imageData->GetScalarPointer(i, j, 0));
            pixel[0] = data[i][j];
            temperatureArray->SetTuple1(i * N + j, data[i][j]);
        }
    }

    imageData->GetPointData()->SetScalars(temperatureArray);

    std::string filename = "output/" + std::to_string(iteration) + ".vti";
    auto writer = vtkSmartPointer<vtkXMLImageDataWriter>::New();
    writer->SetFileName(filename.c_str());
    writer->SetInputData(imageData);
    writer->Write();
}

template <typename T>
void discretize_heat_equation(ProblemConfig<T> config)
{
    auto N = config.N;
    auto u = std::vector<std::vector<T>>(config.N, std::vector<T>(config.N, 1));
    auto u_temp = std::vector<std::vector<T>>(config.N, std::vector<T>(config.N, 0));
    T h = 1.0 / (config.N - 1);
    for (uint i = 1; i < N - 1; i++)
    {
        if (N != u[i].size())
            throw std::runtime_error("domain is not square");
        u[i][0] = 0;
        u[i][N - 1] = 0;
        u[0][i] = 0;
        u[N - 1][i] = 0;
    }
    // less relevant for correctness of stencil computations, only for visualization
    u[0][0] = 0;
    u[N - 1][0] = 0;
    u[0][N - 1] = 0;
    u[N - 1][N - 1] = 0;
    int iteration=0;
    for (double t = 0; t < config.t_end; t += config.dt)
    {
        for (int i = 1; i < config.N - 1; i++)
        {
            for (int j = 1; j < config.N - 1; j++)
            {
                u_temp[i][j] = u[i][j] + config.dt / (4 * h * h) * (u[i - 1][j] + u[i + 1][j] + u[i][j + 1] + u[i][j - 1] - 4 * u[i][j]);
            }
        }
        std::swap(u_temp, u);
        if(config.write_every!=-1 && iteration%config.write_every==0)
        {
            //TODO: Write to vti file
            write_vti_file(u,iteration,config.N);
        }
        iteration++;
    }
}