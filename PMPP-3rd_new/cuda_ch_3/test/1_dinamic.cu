#include <stdlib.h>
#include <stdio.h>

#define N 4	
#define T 2


/*
int i = threadIdx.x + blockIdx.x*blockDim.x ;
	int j = threadIdx.y + blockIdx.y*blockDim.y ;
	int index_i=0;
	int index_j=0;

		mat3[0][0]= 1;
		mat3[0][1]= 2;
		mat3[0][2]= 3;

	if( i<m && j<n ){
		index_i=i*m;
		index_j=+j;
		//mat3[index_i][index_j]=mat1[index_i][index_j] + mat2[index_i][index_j];
	}
*/


__global__ void sum_matrix(int** mat1, int** mat2, int** mat3, int n, int m, int size){
				mat3[0][0]=1;
				mat3[0][1]=2;
				mat3[0][2]=3;
}

void create(int** & mat,int n){
	mat = (int **)malloc(sizeof(int*)*n);	
	int i;
	for(i=0;i<n;i++){
		mat[i] = (int*)malloc(sizeof(int)*n);
	}
}

void create2(int** & mat,int n, int m){
	mat = (int** )malloc(sizeof(int*)*n);	
	mat[0] = (int* )malloc(sizeof(int)*n*m);	
	int i;
	for(i=0;i<n;i++){
		mat[i] = (*mat+i*m);
	}
}

void fill(int** mat,int n){
	int i,j; 
	for(i=0;i<n;i++){
		for(j=0;j<n;j++)
			mat[i][j] = rand()%10;
	}
}

void fill_zero(int** mat,int n, int value=0){
	int i,j; 
	for(i=0;i<n;i++)
		for(j=0;j<n;j++)
			mat[i][j] = value;
}



void print(int** mat,int n){
	int i,j; 
	for(i=0;i<n;i++){
		for(j=0;j<n;j++)
			printf("%d",mat[i][j]);
		printf("\n");
	}
}



int main(){

	int n=N;

	int** mat_a;
	int** mat_b;
	int** mat_c;

	create(mat_a,n);
	create(mat_b,n);
	create(mat_c,n);

	fill(mat_a,n);
	fill(mat_b,n);
	fill_zero(mat_c,n);

	int **d_mat_a, **d_mat_b, **d_mat_c;
	int size=sizeof(int*)*n*sizeof(int)*n;
	
	int i,j;

	int size_row=sizeof(int*)*n;
	int size_col=sizeof(int)*n;

	cudaMalloc((void*** )&d_mat_a,size_row);
	for(i=0;i<n;i++){
		cudaMalloc((void**)&d_mat_a[i],size_col);
	}

	cudaMalloc((void*** )&d_mat_b,size_row);
	for(i=0;i<n;i++){
		cudaMalloc((void**)&d_mat_b[i],size_col);
	}

	cudaMalloc((void*** )&d_mat_c,size_row);
	for(i=0;i<n;i++){
		cudaMalloc((void**)&d_mat_c[i],size_col);
	}

	cudaMemcpy(d_mat_a,mat_a,size_row,cudaMemcpyHostToDevice);
	for(i=0;i<n;i++){
		cudaMemcpy(d_mat_a[i],mat_a[i],size_col,cudaMemcpyHostToDevice);	
	}	
	cudaMemcpy(d_mat_b,mat_b,size_row,cudaMemcpyHostToDevice);
	for(i=0;i<n;i++){
		cudaMemcpy(d_mat_b[i],mat_b[i],size_col,cudaMemcpyHostToDevice);	
	}	
	cudaMemcpy(d_mat_c,mat_c,size_row,cudaMemcpyHostToDevice);
	for(i=0;i<n;i++){
		cudaMemcpy(d_mat_c[i],mat_c[i],size_col,cudaMemcpyHostToDevice);	
	}	

	
	print(mat_a,n);
	printf("//////////////////\n");
	print(mat_b,n);
	printf("///////////////////\n");
	print(mat_c,n);

	dim3 grid(ceil(N/T),ceil(N/T),1);
	dim3 blockNum(T,T,1);

	sum_matrix<<<grid,blockNum>>>(d_mat_a,d_mat_b,d_mat_c,n,n,size);
	
	cudaMemcpy(mat_c,d_mat_c,size_row,cudaMemcpyDeviceToHost);
	for(i=0;i<n;i++){
		cudaMemcpy(d_mat_c[i],mat_c[i],size_col,cudaMemcpyDeviceToHost);	
	}	

	
	printf("//////////////////\n");
	print(mat_c,n);


	return 0;
}