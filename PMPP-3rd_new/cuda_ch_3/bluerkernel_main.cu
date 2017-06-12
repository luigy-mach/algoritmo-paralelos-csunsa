#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cuda.h>
#include <math.h>

#define T 2 // max threads x bloque

#define N 5  

#define BLUR_SIZE 1


__global__
   void blurKernel(int * in, int * out, int w, int h) {
     int Col = blockIdx.x * blockDim.x + threadIdx.x;
     int Row = blockIdx.y * blockDim.y + threadIdx.y;
     if (Col < w && Row < h) {
       int pixVal = 0;
       int pixels = 0;
       // Get the average of the surrounding 2xBLUR_SIZE x 2xBLUR_SIZE box
       for(int blurRow = -BLUR_SIZE; blurRow < BLUR_SIZE+1; ++blurRow) {
         for(int blurCol = -BLUR_SIZE; blurCol < BLUR_SIZE+1; ++blurCol) {
           int curRow = Row + blurRow;
           int curCol = Col + blurCol;
           // Verify we have a valid image pixel
           if(curRow > -1 && curRow < h && curCol > -1 && curCol < w){
             pixVal += in[curRow * w + curCol];
             pixels++; // Keep track of number of pixels in the accumulated total
           }
         }
       }
       // Write our new pixel value out
       out[Row * w + Col] = (int)(pixVal / pixels);
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

  fill(m1,N);
  fill(m2,N);

  int *dm1, *dm2;

  cudaMalloc((void**) &dm1, N * N * sizeof(int));
  cudaMalloc((void**) &dm2, N * N * sizeof(int));

  cudaMemcpy(dm1, m1, N * N * sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(dm2, m2, N * N * sizeof(int), cudaMemcpyHostToDevice);

  int B = (int) ceil((float) N / (float) T);

  dim3 dimBloques(B, B);
  dim3 dimThreadsBloque(T, T);

  int w=N;
  int h=N;

  blurKernel<<<dimBloques, dimThreadsBloque>>>(dm1, dm2, w, h);

  cudaMemcpy(m2, dm2, N * N * sizeof(int), cudaMemcpyDeviceToHost);

  printf("&&&&&&&&&&&&&&&&&&\n");
  print(m1,N);
  print(m2,N);
  printf("&&&&&&&&&&&&&&&&&&\n");

  cudaFree(dm1);
  cudaFree(dm2);  

 	return 0;
}
