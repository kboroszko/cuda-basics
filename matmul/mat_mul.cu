#include <stdio.h>
#include "common/errors.h"

#define N 1000

__global__ void add(int *a, int *b, int *c) {
    int bid = blockIdx.x;
	int tid = bid * 256 + threadIdx.x;
	if (tid < N) {
		c[tid] = a[tid] + b[tid];
    }
}

int main(void) {
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

	HANDLE_ERROR(cudaMemcpy(devA, a, N * sizeof(int), cudaMemcpyHostToDevice));
	HANDLE_ERROR(cudaMemcpy(devB, b, N * sizeof(int), cudaMemcpyHostToDevice));
	add<<<(N+255)/256,256>>>(devA, devB, devC);
	HANDLE_ERROR(cudaMemcpy(c, devC, N * sizeof(int), cudaMemcpyDeviceToHost));


	//check if ok
    for(int i=0; i<N; i++){
        if(c[i] != a[i] + b[i]){
            printf("error at cell %d, %d != %d", i, c[i], a[i]+b[i]);
            return 1;
        }
    }

	HANDLE_ERROR(cudaFree(devA));
	HANDLE_ERROR(cudaFree(devB));
	HANDLE_ERROR(cudaFree(devC));
	return 0;
}