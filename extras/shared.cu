__global__ void histo_kernel(unsigned char *buffer, long size, unsigned int *histo) {
    __shared__ unsigned int temp[256];
    temp[threadIdx.x] = 0;
    __syncthreads();

    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    while (tid < size) {
            atomicAdd(&temp[buffer[tid]], 1);
            tid += stride;
    }
    __syncthreads();

    atomicAdd(&(histo[threadIdx.x]), temp[threadIdx.x]);
}