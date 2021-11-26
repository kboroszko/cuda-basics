#define DIM 1024

texture<float, 2> simpleTexture;

__global__ void textureReadKernel() {

    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int offset = x + y * blockDim.x * gridDim.x;  
    
    float top, left, center, right, bottom;
    top = tex2D(simpleTexture, x, y - 1);    
    left = tex2D(simpleTexture, x - 1, y);
    center = tex2D(simpleTexture, x, y);
    right = tex2D(simpleTexture, x + 1, y);
    bottom = tex2D(simpleTexture, x, y + 1);

    //do something with top, left, center, right, bottom
}

int main(void) {
    dim3 blocks(DIM / 16, DIM / 16);
    dim3 threads(16, 16);
    float *devicePointer;
    float *hostPointer = (float*)malloc(SIZE * sizeof(float));
    cudaMalloc((void**)&devicePointer, SIZE * sizeof(float));

    cudaChannelFormatDesc desc = cudaCreateChannelDesc<float>();
    cudaBindTexture2D(NULL, simpleTexture, devicePointer, desc, SIZE, SIZE, SIZE * sizeof(float));

    //fill hostPointer with data

    cudaMemcpy(devicePointer, hostPointer, SIZE * sizeof(float), cudaMemcpyHostToDevice);

    textureReadKernel<<<blocks, threads>>>();
    
    cudaUnbindTexture(simpleTexture);
    cudaFree(devicePointer);
    free(hostPointer);
}