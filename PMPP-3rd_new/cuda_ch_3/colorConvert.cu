#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cuda.h>
#include <math.h>

#define T 2 // max threads x bloque
#define N 6

#define CHANNELS 3


__global__ 
void colorConvert(int * grayImage, int * rgbImage, int width, int height){
    //__syncthreads();

    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
   
    if (x < width && y < height) {
      // get 1D coordinate for the grayscale image
      int grayOffset = y*(width) + x;
      // one can think of the RGB image having
      // CHANNEL times columns than the gray scale image
      int rgbOffset = grayOffset ;
        int r = rgbImage[rgbOffset + 0]; // red value for pixel
        int g = rgbImage[rgbOffset + 1]; // green value for pixel
        int b = rgbImage[rgbOffset + 2]; // blue value for pixel
      // perform the rescaling and store it
      // We multiply by floating point constants
      grayImage[grayOffset] = 0.21f*r + 0.71f*g + 0.07f*b;
      //grayImage[grayOffset] = 0;
    }
}


void fill(int m[N][N], int n){
  int i,j;
   for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      m[i][j] = -1;
    }
  }    
}

void fill(int m[N][N*CHANNELS]){
  int i,j;
   for (i = 0; i < N; i++) {
    for (j = 0; j < N*CHANNELS; j++) {
      m[i][j] = rand()%9;
    }
  }    
}


void print(int m[N][N], int n){
  printf("------------------------------------\n"); 
  int i,j;
  for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      printf(" %d ", m[i][j]);
     }
    printf("\n\n"); 
  }
  printf("------------------------------------\n"); 
}


void print(int m[N][N*CHANNELS]){
  printf("------------------------------------\n"); 
  int i,j;
  for (i = 0; i < N; i++) {
    for (j = 0; j < N*CHANNELS; j++) {
      printf(" %d ", m[i][j]);
      if(((j+1)%CHANNELS)==0){
        printf(" | ");
      }
     }
    printf("\n\n"); 
  }
  printf("------------------------------------\n"); 
}



int main(int argc, char** argv) {

  int m1[N][N*CHANNELS];
  int m2[N][N];

  fill(m1);
  fill(m2,N);


  int *dm1, *dm2;

  cudaMalloc((void**) &dm1, N * CHANNELS * N * sizeof(int));
  cudaMalloc((void**) &dm2, N * N * sizeof(int));

  cudaMemcpy(dm1, m1, N * CHANNELS * N * sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(dm2, m2, N * N * sizeof(int), cudaMemcpyHostToDevice);

  int B = (int) ceil((float) N / (float) T);

  dim3 dimBloques(B, B);
  dim3 dimThreadsBloque(T, T);

  int w=N;
  int h=N;
  colorConvert<<<dimBloques, dimThreadsBloque>>>(dm2, dm1, w, h);


  cudaMemcpy(m2, dm2, N * N * sizeof(int), cudaMemcpyDeviceToHost);

  printf("&&&&&&&&&&&&&&&&&&\n");
    print(m1);
    print(m2,N);
  printf("&&&&&&&&&&&&&&&&&&\n");

  cudaFree(dm1);
  cudaFree(dm2);  

 	return 0;
}
