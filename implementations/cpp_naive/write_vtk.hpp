#include <vector>
#include <string>
#include <vtkSmartPointer.h>
#include <vtkImageData.h>
#include <vtkDoubleArray.h>
#include <vtkPointData.h>
#include <vtkXMLImageDataWriter.h>

template <typename T>
void write_vti_file(const std::vector<std::vector<T>>& data, std::string path)
{
    uint32_t N = data.size();
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

    auto writer = vtkSmartPointer<vtkXMLImageDataWriter>::New();
    writer->SetFileName(path.c_str());
    writer->SetInputData(imageData);
    writer->Write();
}
