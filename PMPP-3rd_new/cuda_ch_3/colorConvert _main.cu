#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cuda.h>
#include <math.h>

#include "qdbmp.h"



#define T 2 // max threads x bloque

#define N 295
#define W 295
#define H 250

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


void fill(int m[N][N], int n, int m){
  int i,j;
   for (i = 0; i < n; i++) {
    for (j = 0; j < m; j++) {
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

  int m1[H][W*CHANNELS];
  int m2[H][W];

  fill(m1,H,W*CHANNELS);
  fill(m2,H,W);


  printf("///////////////////////////////////////////////////////////////////////\n");
  printf("///////////////////////////////////////////////////////////////////////\n");
  UCHAR r, g, b;
  UINT  width, height;
  UINT  x, y;
  BMP*  bmp;

  /* Check arguments */
  if ( argc != 3 )
  {
    fprintf( stderr, "Usage: %s <input file> <output file>\n", argv[ 0 ] );
    return 0;
  }

  printf("///////////////////////////////////////////////////////////////////////\n");
  /* Read an image file */
  bmp = BMP_ReadFile( argv[ 1 ] );
  BMP_CHECK_ERROR( stdout, -1 );

  /* Get image's dimensions */
  width = BMP_GetWidth( bmp );
  height = BMP_GetHeight( bmp );



|/* Iterate through all the image's pixels */
  for ( x = 0 ; x < width ; ++x )
  {
    for ( y = 0 ; y < height ; ++y )
    {
      /* Get pixel's RGB values */
      BMP_GetPixelRGB( bmp, x, y, &r, &g, &b );


      
    }
  }




  printf("///////////////////////////////////////////////////////////////////////\n");
  printf("///////////////////////////////////////////////////////////////////////\n");






  int *dm1, *dm2;

  cudaMalloc((void**) &dm1, H * CHANNELS * W * sizeof(int));
  cudaMalloc((void**) &dm2, H * W * sizeof(int));

  cudaMemcpy(dm1, m1, H * CHANNELS * W * sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(dm2, m2, H * W * sizeof(int), cudaMemcpyHostToDevice);

  int B = (int) ceil((float) N / (float) T);

  dim3 dimBloques(B, B);
  dim3 dimThreadsBloque(T, T);

  int w=W;
  int h=H;
  colorConvert<<<dimBloques, dimThreadsBloque>>>(dm2, dm1, w, h);


  cudaMemcpy(m2, dm2, N * N * sizeof(int), cudaMemcpyDeviceToHost);

  printf("&&&&&&&&&&&&&&&&&&\n");
    print(m1);
    print(m2,N);
  printf("&&&&&&&&&&&&&&&&&&\n");


  printf("///////////////////////////////////////////////////////////////////////\n");
  printf("///////////////////////////////////////////////////////////////////////\n");


  /* Iterate through all the image's pixels */
  for ( x = 0 ; x < width ; ++x )
  {
    for ( y = 0 ; y < height ; ++y )
    {
      BMP_SetPixelRGB( bmp, x, y, m2[i][j], 0, 0 );
    }
  }

  printf("///////////////////////////////////////////////////////////////////////\n");



  /* Save result */
  BMP_WriteFile( bmp, argv[ 2 ] );
  BMP_CHECK_ERROR( stdout, -2 );


  /* Free all memory allocated for the image */
  BMP_Free( bmp );


  printf("///////////////////////////////////////////////////////////////////////\n");

  cudaFree(dm1);
  cudaFree(dm2);  



 	return 0;
}
