__global__ void domain_setup(float* U, int N){
    int i = blockIdx.y * blockDim.y + threadIdx.y;
    int j = blockIdx.x * blockDim.x + threadIdx.x;

    if(i > 0 && i < N - 1 && j > 0 && j < N - 1){
        U[i * N + j] = 1;
    }else{
        if(i < N && j < N){
            U[i * N + j] = 0;
        }
    }
}

__global__ void heat_step(float* U, float* U_temp, int N, float dt, float h){
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if(i > 0 && i < N - 1 && j > 0 && j < N - 1){
        U_temp[i * N + j] = U[i * N + j] + dt / (4 * h * h) * (U[(i - 1) * N + j] + U[(i + 1) * N + j] + U[i * N + j + 1] + U[i * N + j - 1] - 4 * U[i * N + j]);
    }
}



