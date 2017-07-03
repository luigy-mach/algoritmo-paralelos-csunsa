#include <stdlib.h>
#include <stdio.h>

#define WIDTH_TILE 70
#define TPB 32




__global__ 
void matrix_mult(int** dd_mat_a,int** dd_mat_b,int** dd_mat_c, int n, int m){
	int value=0;
	int x = threadIdx.x + blockIdx.x*blockDim.x;
	int y = threadIdx.y + blockIdx.y*blockDim.y;
	if( y>n && x>m ) return;
	int i;
	for(i=0;i<m;i++){
		value += *(*(dd_mat_a)+y*m+i)  * *(*(dd_mat_b)+i*m+x);
	}

	*(*(dd_mat_c)+y*m+x)=value;


}



__global__ 
void matrix_mult_shared(int** dd_mat_a,int** dd_mat_b,int** dd_mat_c, int width){

	__shared__ int Mds[WIDTH_TILE][WIDTH_TILE];
	__shared__ int Nds[WIDTH_TILE][WIDTH_TILE];

	int bx=blockIdx.x;
	int by=blockIdx.y;

	int tx=threadIdx.x;
	int ty=threadIdx.y;



	int value=0;

	int fil = by*WIDTH_TILE+ty;
	int col = bx*WIDTH_TILE+tx;

	int m;
	int k;
	for(k=0 ; k<width/WIDTH_TILE ; k++){
		Mds[ty][tx]=dd_mat_a[fil][k+WIDTH_TILE+tx];
		Nds[ty][tx]=dd_mat_b[k*WIDTH_TILE+ty][col];
		__syncthreads();

		for(m=0;m<WIDTH_TILE;m++){
			value+=Mds[ty][m]*Nds[m][tx];
		}
		__syncthreads();

	}
	dd_mat_c[fil][col]=value;
}



void fill(int** mat, int n, int m){
	srand(time(0));
	int i,j; 
	for(i=0; i<n ;i++){
		for(j=0; j<m ;j++)
			mat[i][j] = rand()%3+1;
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

	int tam = 10000;
	///////////////////////////////
	int n = tam;
	int m = tam;



	int i;
	int** mat_a; int** d_mat_a;	 int** dd_mat_a;	
	int** mat_b; int** d_mat_b;	 int** dd_mat_b;	
	int** mat_c; int** d_mat_c;	 int** dd_mat_c;	

	create(mat_a,d_mat_a,dd_mat_a,n,m);
	create(mat_b,d_mat_b,dd_mat_b,n,m);
	create(mat_c,d_mat_c,dd_mat_c,n,m,0);


	int size_col = sizeof(int ) * m;

	//print(mat_a,n,m);
	printf("//////////////////\n");
	//print(mat_b,n,m);
	printf("//////////////////\n");
	//print(mat_c,n,m);
	//printf("//////////////////\n");
	//printf("//////////////////\n");




	dim3 blockNum(TPB,TPB);
	dim3 grid((n + TPB-1)/blockNum.x,(m + TPB-1)/blockNum.y);



	/////////////////////////////////////////
	float time;
	cudaEvent_t my_start,my_stop;
	cudaEventCreate(&my_start);
	cudaEventCreate(&my_stop);

	///////////////////////////////////////// TIME
    cudaEventRecord(my_start,0);
	matrix_mult_shared<<<grid,blockNum>>>(dd_mat_a,dd_mat_b,dd_mat_c,n);
	//matrix_mult<<<grid,blockNum>>>(dd_mat_a,dd_mat_b,dd_mat_c,n);
    cudaEventRecord(my_stop,0);
    cudaEventSynchronize(my_stop);
    /////////////////////////////////////////////////////

	for(i=0;i<n;i++){
		cudaMemcpy(mat_c[i],d_mat_c[i],size_col,cudaMemcpyDeviceToHost);	
	}	

    cudaEventElapsedTime(&time,my_start,my_stop);
	printf("time %dX%d , tam %d : %.25f \n",WIDTH_TILE,WIDTH_TILE,tam,time);

	//printf("//////////////////\n");
	//printf("//////////////////\n");
	//print(mat_a,n,m);
	//printf("//////////////////\n");
	//print(mat_b,n,m);
	printf("//////////////////\n");
	//print(mat_c,n,m);



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
