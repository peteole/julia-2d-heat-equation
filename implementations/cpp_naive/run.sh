# check if executable exists
if [ ! -f "./main" ]; then
    ./build.sh
fi

./main $1