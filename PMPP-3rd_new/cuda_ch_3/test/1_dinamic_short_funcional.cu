#include <stdlib.h>
#include <stdio.h>

#define N 4	
#define T 2


__global__ void sum_matrix(int** d_mat_a, int** dd_mat_a, int n, int m, int size){
				dd_mat_a[0][3]=-2;
				dd_mat_a[1][3]=-2;
				dd_mat_a[2][3]=-2;
				dd_mat_a[3][3]=-2;
				//**dd_mat_a=-1;
}

/*
void create(int** & mat,int n){
	mat = (int **)malloc(sizeof(int*)*n);	
	int i;
	for(i=0;i<n;i++){
		mat[i] = (int*)malloc(sizeof(int)*n);
	}
}

void create2(int**& mat,int n, int m){
	mat = (int** )malloc(sizeof(int*)*n);	
	mat[0] = (int* )malloc(sizeof(int)*n*m);	
	int i;
	//mat[1] = mat[0]+1*m;
	for(i=1;i<n;i++){
		mat[i] = mat[0]+i*m;
	}
}*/


void create3(int*** mat,int n, int m){
	*mat = (int** )malloc(sizeof(int*)*n);	
	(*mat)[0] = (int* )malloc(sizeof(int)*n*m);	
	int i;
	for(i=1;i<n;i++){
		(*mat)[i] = (*mat)[0]+i*m;
	}
}



/*
void create4(int** mat,int n, int m){
	mat = (int** )malloc(sizeof(int*)*n);	
	mat[0] = (int* )malloc(sizeof(int)*n*m);	
	int i;
	for(i=1;i<n;i++){
		mat[i] = mat[0]+i*m;
	}
}
*/


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

	int n = N;
	int m = N;

	int** mat_a;

	create3(&mat_a,n,m);
	//create4(mat_a,n,m);

	fill(mat_a,n);

	int **d_mat_a;
	int **dd_mat_a;
	int size = sizeof(int*) * n * sizeof(int) * n;
	
	int i;

	int size_row = sizeof(int*) * n;
	int size_col = sizeof(int ) * m;

	d_mat_a = (int**) malloc(size_row);
	for(i=0;i<n;i++){
		cudaMalloc((void**)&d_mat_a[i],size_col);
	}
	for(i=0;i<n;i++){
		cudaMemcpy(d_mat_a[i],mat_a[i],size_col,cudaMemcpyHostToDevice);	
	}	

	cudaMalloc((void***)&dd_mat_a,size_row);
	cudaMemcpy(dd_mat_a,d_mat_a,size_row,cudaMemcpyHostToDevice);

	
	print(mat_a,n);
	printf("//////////////////\n");

	//dim3 grid(ceil(N/T),ceil(N/T),1);
	//dim3 blockNum(T,T,1);
	dim3 grid(T,T,1);
	dim3 blockNum(n*T,m*T,1);

	sum_matrix<<<grid,blockNum>>>(d_mat_a,dd_mat_a,n,n,size);
	
	//cudaMemcpy(mat_a,*d_mat_a,size_row,cudaMemcpyDeviceToHost);
	for(i=0;i<n;i++){
		cudaMemcpy(mat_a[i],d_mat_a[i],size_col,cudaMemcpyDeviceToHost);	
	}	

	
	printf("//////////////////\n");
	print(mat_a,n);


	return 0;
}