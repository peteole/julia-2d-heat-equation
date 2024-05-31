rm -rf output_raw
rm -rf output
mkdir output_raw
mkdir output
./main $1
julia --project=. convert_output.jl