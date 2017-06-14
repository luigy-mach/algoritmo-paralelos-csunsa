#include <stdlib.h>
#include <stdio.h>

#define TAM 10

#define N 2
#define T 6




__global__ 
void print_matrix(int** dd_mat_a, int n, int m){
	int x = threadIdx.x + blockIdx.x*blockDim.x;
	int y = threadIdx.y + blockIdx.y*blockDim.y;
	if( y<n && x<m ){ 
		*(*(dd_mat_a+y)+x)=-3;
		printf("%d ",*(*(dd_mat_a+y)+x));
	}

}


__global__ 
void matrix_add(int** dd_mat_a,int** dd_mat_b,int** dd_mat_c, int n, int m){
	int x = threadIdx.x + blockIdx.x*blockDim.x;
	int y = threadIdx.y + blockIdx.y*blockDim.y;
	if( y<n && x<m ){ 
		*(*(dd_mat_c+y)+x)=*(*(dd_mat_a+y)+x)+*(*(dd_mat_b+y)+x);
	}

}

void create_host_matrix(int*** mat,int n, int m){
	*mat = (int** )malloc(sizeof(int*)*n);	
	(*mat)[0] = (int* )malloc(sizeof(int)*n*m);	
	int i;
	for(i=1;i<n;i++){
		(*mat)[i] = (*mat)[0]+i*m;
	}
}



void fill_host_matrix(int** mat, int n, int m){
	int i,j; 
	for(i=0; i<n ;i++){
		for(j=0; j<m ;j++)
			mat[i][j] = rand()%50;
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
			printf("%d ",mat[i][j]);
		printf("\n");
	}
}

void create_matrices(int** &mat_a,int** &d_mat_a,int** &dd_mat_a,int n,int m)
{
	int i;

	int size_row = sizeof(int*) * n;
	int size_col = sizeof(int ) * m;

	create_host_matrix(&mat_a,n,m);
	fill_host_matrix(mat_a,n,m);

	d_mat_a = (int**) malloc(size_row);
	cudaMalloc((void**)& d_mat_a[0], sizeof(int) * m * n );
	cudaMemcpy(d_mat_a[0], mat_a[0], sizeof(int) * m * n ,cudaMemcpyHostToDevice);
	for(i=1;i<n;i++){
		d_mat_a[i]=(d_mat_a[i-1]+m);
	}

	cudaMalloc((void***)&dd_mat_a,size_row);
	cudaMemcpy(dd_mat_a,d_mat_a,size_row,cudaMemcpyHostToDevice);
	
}



int main(){


	int n = TAM;
	int m = TAM;

	int** mat_a; int** d_mat_a;	 int** dd_mat_a;	
	int** mat_b; int** d_mat_b;	 int** dd_mat_b;	
	int** mat_c; int** d_mat_c;	 int** dd_mat_c;	

	int i;
	int size_row = sizeof(int*) * n;
	int size_col = sizeof(int ) * m;

    create_matrices(mat_a,d_mat_a,dd_mat_a,n,m);
    create_matrices(mat_b,d_mat_b,dd_mat_b,n,m);
    create_matrices(mat_c,d_mat_c,dd_mat_c,n,m);

    printf("Matrix A\n");
    print(mat_a,n,m);
    printf("\n");

    printf("Matrix B\n");
    print(mat_b,n,m);
    printf("\n");

    printf("Matrix C\n");
    print(mat_c,n,m);
    printf("\n");
    printf(\n");
    



	dim3 grid(N,N,1);
	dim3 blockNum(T,T,1);

	matrix_add<<<grid,blockNum>>>(dd_mat_a,dd_mat_b,dd_mat_c,n,m);

	for(i=0;i<n;i++){
		cudaMemcpy(mat_c[i],d_mat_c[i],size_col,cudaMemcpyDeviceToHost);	
	}	

	printf("//////////////////\n");
	print(mat_c,n,m);


	return 0;
}