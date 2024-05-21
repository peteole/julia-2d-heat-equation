# check if executable exists
if [ ! -f "./benchmark" ]; then
    ./build.sh
fi

./benchmark $1