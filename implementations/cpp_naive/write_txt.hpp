#include <iostream>
#include <fstream>
#include <vector>

template<typename T> void write_solution(const std::vector<std::vector<T>>& data, std::string path)
{
    uint32_t N = data.size();
    std::ofstream file;
    file.open(path);
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            file << data[i][j] << " ";
        }
        file << "\n";
    }
    file.close();
}