#include <stdio.h>
#include <stdlib.h>

#define N 10
#define T 2



__global__ void MatAdd(int A[][N], int B[][N], int C[][N]){
           int i = threadIdx.x;
           int j = threadIdx.y;

           C[i][j] = A[i][j] + B[i][j];
}


void fill(int mat[N][N]){
	int i,j;
	for(i=0;i<N;i++)
		for(j=0;j<N;j++)
			mat[i][j]=rand()%5;

}


void fill_zero(int mat[N][N]){
	int i,j;
	for(i=0;i<N;i++)
		for(j=0;j<N;j++)
			mat[i][j]=0;

}


void print(int mat[N][N]){
	int i,j;
	for(i=0;i<N;i++){
		for(j=0;j<N;j++)
			printf("%i",mat[i][j]);
		printf("\n");	
	}

}

int main(){

	int A[N][N];
	int B[N][N];
	int C[N][N];

	fill(A); fill(B); fill_zero(C);

	printf("//////////////////////\n");
	print(A);
	printf("//////////////////////\n");
	print(B);
	printf("//////////////////////\n");
	print(C);
	printf("//////////////////////\n");

	int (*pA)[N], (*pB)[N], (*pC)[N];

	cudaMalloc((void**)&pA, (N*N)*sizeof(int));
	cudaMalloc((void**)&pB, (N*N)*sizeof(int));
	cudaMalloc((void**)&pC, (N*N)*sizeof(int));
	 
	cudaMemcpy(pA, A, (N*N)*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(pB, B, (N*N)*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(pC, C, (N*N)*sizeof(int), cudaMemcpyHostToDevice);

	int numBlocks = 1;
	dim3 threadsPerBlock(N,N);
	MatAdd<<<numBlocks,threadsPerBlock>>>(pA,pB,pC);

	cudaMemcpy(C, pC, (N*N)*sizeof(int), cudaMemcpyDeviceToHost);

	printf("//////////////////////\n");
	print(C);
	printf("//////////////////////\n");



	cudaFree(pA); 
	cudaFree(pB); 
	cudaFree(pC);

	printf("\n");

	return 0;
}
