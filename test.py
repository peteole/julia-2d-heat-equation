import pyvista as pv
import numpy as np
import os
def load(path):
    loaded=pv.read(path)
    temperature = loaded['temperature']
    dimensions = loaded.dimensions
    return np.array(temperature).reshape(dimensions, order='F')
def compare(path1, path2):
    data1 = load(path1)
    data2 = load(path2)
    return np.allclose(data1, data2,rtol=1e-2,atol=1e-2)

def compare_directories(dir1, dir2):
    files1 = os.listdir(dir1)
    files2 = os.listdir(dir2)
    files1=list(filter(lambda x: x.endswith(".vti"), files1))
    files2=list(filter(lambda x: x.endswith(".vti"), files2))
    files1.sort()
    files2.sort()
    if files1 != files2:
        print(f"Files in {dir1} and {dir2} do not match: {files1} vs {files2}")
        return False
    for file1, file2 in zip(files1, files2):
        if not compare(os.path.join(dir1, file1), os.path.join(dir2, file2)):
            return False
    return True

implementations=os.listdir("implementations")
reference_implementation="julia_sequential_stencil"
for implementation in implementations:
    print(f"Checking implementation {implementation}")
    if not os.path.isdir(os.path.join("implementations", implementation)):
        continue
    if not os.path.exists(os.path.join("implementations", implementation, "output")):
        print(f"Output directory missing for {implementation}")
        continue
    print(f"Comparing {reference_implementation} and {implementation}")
    if compare_directories(os.path.join("implementations", reference_implementation, "output"), os.path.join("implementations", implementation, "output")):
        print("The implementations are equivalent")
    else:
        print("The implementations are not equivalent")
        #break
        