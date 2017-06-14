#include <stdlib.h>
#include <stdio.h>

#define N 5	
#define T 2


__global__ 
void sum_matrix(int** dd_mat_a, int n, int m){
	int x = threadIdx.x + blockIdx.x*blockDim.x;
	int y = threadIdx.y + blockIdx.y*blockDim.y;
	if( y<n && x<m ){
		*(*(dd_mat_a+y)+x)=-9;
	}
}




void create3(int*** mat,int n, int m){
	*mat = (int** )malloc(sizeof(int*)*n);	
	(*mat)[0] = (int* )malloc(sizeof(int)*n*m);	
	int i;
	for(i=1;i<n;i++){
		(*mat)[i] = (*mat)[0]+i*m;
	}
}




void fill(int** mat, int n, int m){
	int i,j; 
	for(i=0; i<n ;i++){
		for(j=0; j<m ;j++)
			mat[i][j] = rand()%2;
	}
}


void fill_zero(int** mat,int n, int m, int value=0){
	int i,j; 
	for(i=0;i<n;i++)
		for(j=0;j<m;j++)
			mat[i][j] = value;
}


void print(int** mat,int n, int m){
	int i,j; 
	for(i=0; i<n ;i++){
		for(j=0; j<m ;j++)
			printf("%d",mat[i][j]);
		printf("\n");
	}
}



int main(){

	int n = N;
	int m = N+4;

	int** mat_a;

	create3(&mat_a,n,m);

	fill(mat_a,n,m);

	int **d_mat_a;
	int **dd_mat_a;
		

	int size_row = sizeof(int*) * n;
	int size_col = sizeof(int ) * m;

	int i;

	d_mat_a = (int**) malloc(size_row);
	cudaMalloc((void**)& d_mat_a[0], sizeof(int) * m * n );
	cudaMemcpy(d_mat_a[0], mat_a[0], sizeof(int) * m * n ,cudaMemcpyHostToDevice);
	for(i=1;i<n;i++){
	//for(i=0;i<n;i++){
		d_mat_a[i]=(d_mat_a[i-1]+m);
		//d_mat_a[i]=(d_mat_a[i]+m);
	}	
	
	cudaMalloc((void***)&dd_mat_a,size_row);
	cudaMemcpy(dd_mat_a,d_mat_a,size_row,cudaMemcpyHostToDevice);


	
	print(mat_a,n,m);
	printf("//////////////////\n");

	dim3 grid(ceil(N/T)+1,ceil(N/T)+1,1);
	dim3 blockNum(T,T,1);

	sum_matrix<<<grid,blockNum>>>(dd_mat_a,n,m);
	
	//cudaMemcpy(mat_a,*d_mat_a,size_row,cudaMemcpyDeviceToHost);
	for(i=0;i<n;i++){
		cudaMemcpy(mat_a[i],d_mat_a[i],size_col,cudaMemcpyDeviceToHost);	
	}	

	
	printf("//////////////////\n");
	print(mat_a,n,m);


	return 0;
}