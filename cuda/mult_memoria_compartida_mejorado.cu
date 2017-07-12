// Luigy Machaca Arcana
// Computer science - Arequipa, Perú  2017

/*
CUDA Device Query...
There are 1 CUDA devices.

CUDA Device #0
Major revision number:         2
Minor revision number:         1
Name:                          GeForce GT 610
Total global memory:           2080440320
Total shared memory per block: 49152 
Total registers per block:     32768
Warp size:                     32
Maximum memory pitch:          2147483647
Maximum threads per block:     1024
Maximum dimension 0 of block:  1024
Maximum dimension 1 of block:  1024
Maximum dimension 2 of block:  64
Maximum dimension 0 of grid:   65535
Maximum dimension 1 of grid:   65535
Maximum dimension 2 of grid:   65535
Clock rate:                    1620000
Total constant memory:         65536
Texture alignment:             512
Concurrent copy and execution: Yes
Number of multiprocessors:     1
Kernel execution timeout:      Yes

*/


#include <stdlib.h>
#include <stdio.h>


#define WIDTH_TILE 32




__global__ void matrix_mult_shared(int** dd_mat_a, int n_rows_a, int n_cols_a ,int** dd_mat_b, int n_rows_b, int n_cols_b, int** dd_mat_c, int n_rows_c, int n_cols_c){

	
	__shared__ int Mds[WIDTH_TILE][WIDTH_TILE];
	__shared__ int Nds[WIDTH_TILE][WIDTH_TILE];

	int bx=blockIdx.x;
	int by=blockIdx.y;

	int tx=threadIdx.x;
	int ty=threadIdx.y;

	int value = 0;

	int row = by*WIDTH_TILE + ty;
	int col = bx*WIDTH_TILE + tx;	

	int width = n_cols_a; //n_cols_a == n_rows_b

	int k;
	for(k=0 ; k<(int)(width-1+WIDTH_TILE)/(int)WIDTH_TILE ; ++k){
		if (k*WIDTH_TILE+tx < n_cols_a && row < n_rows_a){
			Mds[ty][tx] = dd_mat_a[row][k*WIDTH_TILE+tx];
		}
        else{
			Mds[ty][tx] = 0;
        }

        if (k*WIDTH_TILE+ty < n_rows_b && col < n_cols_b){
			Nds[ty][tx] = dd_mat_b[k*WIDTH_TILE+ty][col];
        }
        else{
			Nds[ty][tx] = 0;
        }

		__syncthreads();
		int m;
		for(m=0 ; m<WIDTH_TILE ; ++m){
			value += Mds[ty][m]*Nds[m][tx];
		}
		__syncthreads();

	}

	if(row<n_rows_c && col<n_cols_c){
		dd_mat_c[row][col]=value;
	}
	

}



__global__ void matrix_mult_shared_mejorado(int** dd_mat_a, int n_rows_a, int n_cols_a ,int** dd_mat_b, int n_rows_b, int n_cols_b, int** dd_mat_c, int n_rows_c, int n_cols_c){

	
	__shared__ int Mds[WIDTH_TILE][WIDTH_TILE];
	__shared__ int Nds[WIDTH_TILE][WIDTH_TILE];

	int bx = blockIdx.x;
	int by = blockIdx.y;

	int tx = threadIdx.x;
	int ty = threadIdx.y;

	int Row = by*WIDTH_TILE + ty;
	int Col1  = (bx*2)*WIDTH_TILE + tx;
	int Col2 = (bx*2+1)*WIDTH_TILE + tx;

	int value1 = 0;
	int value2 = 0;
	
	int k = 0;
	int prefM  = dd_mat_a[Row][k*WIDTH_TILE + tx];
	int prefN  = dd_mat_b[k*WIDTH_TILE + ty][Col1];
	int prefN2 = dd_mat_b[k*WIDTH_TILE + ty][Col2];
		

	Mds[ty][tx] = prefM;
	Nds[ty][tx] = prefN;
	__syncthreads();
	

	int width = n_cols_a; //n_cols_a == n_rows_b

	for(int m = 0; m < (int)(width-1+WIDTH_TILE)/(int)WIDTH_TILE ; ++m){				
		
		prefM = dd_mat_a[Row][m*WIDTH_TILE + tx];
		prefN = dd_mat_b[(m*WIDTH_TILE + ty)][Col1];
		
		for(int k = 0; k<WIDTH_TILE; k++){
			value1 += Mds[ty][k] * Nds[k][tx];
		}		
		__syncthreads();
		
		Nds[ty][tx] = prefN2;
		
		__syncthreads();
		
		prefN2 = dd_mat_b[(m*WIDTH_TILE + ty)][Col2];
		
		for(int k = 0; k < WIDTH_TILE; k++){
			value2 += Mds[ty][k] * Nds[k][tx];
		}
		__syncthreads();
		
		
		Mds[ty][tx] = prefM;
		Nds[ty][tx] = prefN;
		//__syncthreads();		
		
	}


	if( Row<n_rows_c && Col1<n_cols_c ){
		dd_mat_c[Row][Col1] = value1;
	}

	if( Row<n_rows_c && Col2<n_cols_c ){
		dd_mat_c[Row][Col2] = value2;
	}

}





__global__ 
void matrix_mult(int** dd_mat_a, int n_rows_a, int n_cols_a ,int** dd_mat_b, int n_rows_b, int n_cols_b, int** dd_mat_c, int n_rows_c, int n_cols_c){
	int value=0;


	int tx=threadIdx.x;
	int ty=threadIdx.y;


	int x = tx + blockIdx.x*blockDim.x;
	int y = ty + blockIdx.y*blockDim.y;

	if( y<n_rows_c && x<n_cols_c ){
		int i;
		for(i=0 ; i<n_cols_a ; i++){
			value += dd_mat_a[y][i] * dd_mat_b[i][x];
		}
		dd_mat_c[y][x]=value;
	} 
}



void fill(int** mat, int n, int m){
    srand(time(0));
	int i,j; 
	for(i=0; i<n ;i++){
		for(j=0; j<m ;j++)
			mat[i][j] = rand()%3+1;
			//mat[i][j] = 1;
	}
}


void fill_value(int** mat,int n, int m, int value=0){
	int i,j; 
	for(i=0;i<n;i++)
		for(j=0;j<m;j++)
			mat[i][j] = value;
}


void print(int** mat,int n, int m){
	int i,j; 
	for(i=0; i<n ;i++){
		for(j=0; j<m ;j++)
			printf("%d ",mat[i][j]);
		printf("\n");
	}
}




void create(int**& mat, int**& d_mat, int**& dd_mat, int n, int m, int fillValue=-1){
	int i;

	mat = (int** )malloc(sizeof(int*)*n);	
	mat[0] = (int* )malloc(sizeof(int)*n*m);	
	for(i=1;i<n;i++){
		mat[i] = mat[i-1]+m;
	}
	if(fillValue==-1){
		fill(mat,n,m);	
	}
	else{
		fill_value(mat,n,m,fillValue);
	}

	int size_row = sizeof(int*) * n;

	d_mat = (int**) malloc(size_row);
	cudaMalloc((void**)& d_mat[0], sizeof(int) * m * n );
	cudaMemcpy(d_mat[0], mat[0], sizeof(int) * m * n ,cudaMemcpyHostToDevice);
	for(i=1;i<n;i++){
		d_mat[i]=(d_mat[0]+i*m);
	}	
	
	cudaMalloc((void***)&dd_mat,size_row);
	cudaMemcpy(dd_mat,d_mat,size_row,cudaMemcpyHostToDevice);


}




int main(){

	int tam = 512;

	int n = tam;
	int m = tam;
	int p = tam;
	int q = tam;


	if(m!=p){
		printf("error m!=p");
		return 0;
	}

	int** mat_a; int** d_mat_a;	 int** dd_mat_a;	
	int** mat_b; int** d_mat_b;	 int** dd_mat_b;	
	int** mat_c; int** d_mat_c;	 int** dd_mat_c;	

	create(mat_a,d_mat_a,dd_mat_a,n,m);
	create(mat_b,d_mat_b,dd_mat_b,n,m);
	create(mat_c,d_mat_c,dd_mat_c,n,m,0);



	/////////////////////////////////////////
	float time1,time2,time3;
	cudaEvent_t my_start,my_stop;
	cudaEventCreate(&my_start);
	cudaEventCreate(&my_stop);


	dim3 blockNum(WIDTH_TILE,WIDTH_TILE,1);
	dim3 grid((int)(n-1+blockNum.x)/blockNum.x,(int)(q-1+blockNum.y)/blockNum.y,1);
	printf("tx: %d,ty: %d\n",(int)(n-1+blockNum.x)/blockNum.x,(int)(q-1+blockNum.y)/blockNum.y);
	printf("grid_row: %d, grid_col: %d\n",grid.y , grid.x );

	///////////////////////////////////////// TIME1
    cudaEventRecord(my_start,0);

	matrix_mult_shared<<<grid,blockNum>>>(dd_mat_a,n,m,dd_mat_b,p,q,dd_mat_c,n,q);
	
    cudaEventRecord(my_stop,0);
    cudaEventSynchronize(my_stop);
    cudaEventElapsedTime(&time1,my_start,my_stop);
    /////////////////////////////////////////////////////

    ///////////////////////////////////////// TIME2
    cudaEventRecord(my_start,0);

	matrix_mult_shared_mejorado<<<grid,blockNum>>>(dd_mat_a,n,m,dd_mat_b,p,q,dd_mat_c,n,q);

    cudaEventRecord(my_stop,0);
    cudaEventSynchronize(my_stop);
    cudaEventElapsedTime(&time2,my_start,my_stop);
    /////////////////////////////////////////////////////

    ///////////////////////////////////////// TIME3
    cudaEventRecord(my_start,0);

	matrix_mult<<<grid,blockNum>>>(dd_mat_a,n,m,dd_mat_b,p,q,dd_mat_c,n,q);
	
    cudaEventRecord(my_stop,0);
    cudaEventSynchronize(my_stop);
    cudaEventElapsedTime(&time3,my_start,my_stop);
    /////////////////////////////////////////////////////



	printf("time1 %dX%d , tam %d : %.25f \n",WIDTH_TILE,WIDTH_TILE,tam,time1/1000);
	printf("time2 %dX%d , tam %d : %.25f \n",WIDTH_TILE,WIDTH_TILE,tam,time2/1000);
	printf("time2 %dX%d , tam %d : %.25f \n",WIDTH_TILE,WIDTH_TILE,tam,time3/1000);

	cudaMemcpy(mat_c[0],d_mat_c[0],sizeof(int)*n*q,cudaMemcpyDeviceToHost);		

	
	/*
	printf("//////////////////\n");
	printf("//////////////////\n");
	print(mat_a,n,m);
	printf("//////////////////\n");
	print(mat_b,p,q);

	printf("//////////////////\n");
	print(mat_c,n,q);
	*/
	
	


	cudaFree(dd_mat_a);
	cudaFree(dd_mat_b);
	cudaFree(dd_mat_c);
	cudaFree(d_mat_a);
	cudaFree(d_mat_b);
	cudaFree(d_mat_c);
  	
  	free(mat_a);
  	free(mat_b);
  	free(mat_c);
  	

	return 0;
}