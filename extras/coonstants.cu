__constant__ float constants[3];

__global__ void someKernel() {
    //code that reads from constants
}

int main(void) {
    float *cpuConstants = (float*)malloc(sizeof(float) * 3);
    cpuConstants[0] = 9.81f;
    cpuConstants[1] = 3.14f;
    cpuConstants[2] = 1.66f;

    cudaMemcpyToSymbol(constants, cpuConstants, sizeof(float) * 3);

    free(cpuConstants);

    someKernel<<<1,1>>>();
        
    return 0;
}