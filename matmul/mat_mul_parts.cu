#include <stdio.h>
#include "common/errors.h"

#define N 10000
#define P 1000

__global__ void add(int *a, int *b, int *c) {
    int bid = blockIdx.x;
	int tid = bid * 256 + threadIdx.x;
	if (tid < N) {
        for(int i=0; i<1000; i++){
            c[tid] = a[tid] + b[tid];
        }
    }
}

int main(void) {

    cudaStream_t stream[10];
    for(int i=0; i<10; i++){
        cudaStreamCreate(stream + i);
    }
	int a[N], b[N], c[N];
	int *devA, *devB, *devC;

	HANDLE_ERROR(cudaMalloc((void**)&devA, N * sizeof(int)));
	HANDLE_ERROR(cudaMalloc((void**)&devB, N * sizeof(int)));
	HANDLE_ERROR(cudaMalloc((void**)&devC, N * sizeof(int)));

	//fill a and b arrays
    for(int i=0; i<N; i++){
        a[i] = i;
        b[i] = i*2;
    }

    for(int j=0; j<10; j++){
        int i = j * P;
        printf("copying indexes %d to %d", i, i+P);
        HANDLE_ERROR(cudaMemcpyAsync(devA + i, a + i, P * sizeof(int), cudaMemcpyHostToDevice, stream[j]));
        HANDLE_ERROR(cudaMemcpyAsync(devB + i, b + i, P * sizeof(int), cudaMemcpyHostToDevice, stream[j]));
        add<<<(P+255)/256,256, 0, stream[j]>>>(devA+i, devB +i, devC + i);
        HANDLE_ERROR(cudaMemcpyAsync(c+i, devC + i, P * sizeof(int), cudaMemcpyDeviceToHost,stream[j]));
    }

    for(int i=0; i<10; i++){
        cudaStreamSynchronize(stream[i]);
    }
	
	//check if ok
    for(int i=0; i<N; i++){
        if(c[i] != a[i] + b[i]){
            printf("error at cell %d, %d != %d\n", i, c[i], a[i]+b[i]);
            return 1;
        }
    }

    printf("success\n");

	HANDLE_ERROR(cudaFree(devA));
	HANDLE_ERROR(cudaFree(devB));
	HANDLE_ERROR(cudaFree(devC));


    for(int i=0; i<10; i++){
        cudaStreamDestroy(stream[i]);
    }
	return 0;
}