cmake .
cmake --build .
julia --project=. -e 'using Pkg; Pkg.instantiate()'