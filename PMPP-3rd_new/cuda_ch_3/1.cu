#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cuda.h>
#include <math.h>

#define T 2 // max threads x bloque
#define N 5  




__global__ void sumaMatrices(int *m1, int *m2, int *m3) {
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  int fil = blockIdx.y * blockDim.y + threadIdx.y;

  int indice = fil * N + col;
  if (col < N && fil < N) {
    m3[indice] = m1[indice] + m2[indice];
  }

}


void fill(int m[N][N], int n){
  int i,j;
  int c;
   for (i = 0; i < N; i++) {
    c = rand()%99;
    //c = 0;
    for (j = 0; j < N; j++) {
      m[i][j] = c;
      c++;
    }
  }    
}


void print(int m[N][N], int n){
  printf("------------------------------------\n"); 
  int i,j;
  for (i = 0; i < N; i++) {
    for (j = 0; j < N; j++) {
      printf(" %d ", m[i][j]);
     }
    printf("\n\n"); 
  }
  printf("------------------------------------\n"); 
}



int main(int argc, char** argv) {

  int m1[N][N];
  int m2[N][N];
  int m3[N][N];

  fill(m1,N);
  fill(m2,N);


  int *dm1, *dm2, *dm3;

  cudaMalloc((void**) &dm1, N * N * sizeof(int));
  cudaMalloc((void**) &dm2, N * N * sizeof(int));
  cudaMalloc((void**) &dm3, N * N * sizeof(int));

  cudaMemcpy(dm1, m1, N * N * sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(dm2, m2, N * N * sizeof(int), cudaMemcpyHostToDevice);

  int B = (int) ceil((float) N / (float) T);

  dim3 dimThreadsBloque(T, T);
  dim3 dimBloques(B, B);

  sumaMatrices<<<dimBloques, dimThreadsBloque>>>(dm1, dm2, dm3);

  cudaMemcpy(m3, dm3, N * N * sizeof(int), cudaMemcpyDeviceToHost);
  //cudaMemcpy(m2, dm2, N * N * sizeof(int), cudaMemcpyDeviceToHost);

 

  print(m1,N);
  print(m2,N);
  print(m3,N);

  printf("\nB = %d", B);
  printf("\n%d, %d",dimBloques.x, dimBloques.y);
  printf("\n%d, %d\n",dimThreadsBloque.x, dimThreadsBloque.y);


  cudaFree(dm1);
  cudaFree(dm2);
  cudaFree(dm3);
  

 	return 0;
}
