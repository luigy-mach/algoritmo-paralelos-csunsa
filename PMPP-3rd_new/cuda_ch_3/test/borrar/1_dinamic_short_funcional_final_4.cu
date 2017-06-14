#include <stdlib.h>
#include <stdio.h>

#define TAM 3

#define N 2
#define T 6
#define TPB 16


__global__ 
void sum_matrix(int** dd_mat_a,int** dd_mat_b,int** dd_mat_c, int n, int m){
	int x = threadIdx.x + blockIdx.x*blockDim.x;
	int y = threadIdx.y + blockIdx.y*blockDim.y;
	if( y<n && x<m ){ // revisar <<<<<<<<<<<<<<<<<<<<<<<<<<<<
		//*(*(dd_mat_a+y)+x)=-9;
		*(*(dd_mat_c+y)+x)= *(*(dd_mat_a+y)+x) + *(*(dd_mat_b+y)+x);
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
			printf("%d",mat[i][j]);
		printf("\n");
	}
}




void create5(int**& mat, int**& d_mat, int**& dd_mat, int n, int m, int fillValue=-1){
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
	int size_col = sizeof(int ) * m;



	d_mat = (int**) malloc(size_row);
	cudaMalloc((void**)& d_mat[0], sizeof(int) * m * n );
	cudaMemcpy(d_mat[0], mat[0], sizeof(int) * m * n ,cudaMemcpyHostToDevice);
	for(i=1;i<n;i++){
		d_mat[i]=(d_mat[i-1]+m);
	}	
	
	cudaMalloc((void***)&dd_mat,size_row);
	cudaMemcpy(dd_mat,d_mat,size_row,cudaMemcpyHostToDevice);
	

}




int main(){

	if(N*T<TAM){
		printf("no cubre la matriz\n");
		return 0;
	}

	int n = TAM;
	int m = TAM;

	int** mat_a; int** d_mat_a;	 int** dd_mat_a;	
	int** mat_b; int** d_mat_b;	 int** dd_mat_b;	
	int** mat_c; int** d_mat_c;	 int** dd_mat_c;	

	create5(mat_a,d_mat_a,dd_mat_a,n,m);
	create5(mat_b,d_mat_b,dd_mat_b,n,m);
	create5(mat_c,d_mat_c,dd_mat_c,n,m,0);

	int i;

	int size_row = sizeof(int*) * n;
	int size_col = sizeof(int ) * m;

/*	
	int** mat_a;

	create3(&mat_a,n,m);

	fill(mat_a,n,m);

	int **d_mat_a;
	int **dd_mat_a;
		

	d_mat_a = (int**) malloc(size_row);
	cudaMalloc((void**)& d_mat_a[0], sizeof(int) * m * n );
	cudaMemcpy(d_mat_a[0], mat_a[0], sizeof(int) * m * n ,cudaMemcpyHostToDevice);
	for(i=1;i<n;i++){
		d_mat_a[i]=(d_mat_a[i-1]+m);
	}	
	
	cudaMalloc((void***)&dd_mat_a,size_row);
	cudaMemcpy(dd_mat_a,d_mat_a,size_row,cudaMemcpyHostToDevice);
*/
	print(mat_a,n,m);
	printf("//////////////////\n");
	print(mat_b,n,m);
	printf("//////////////////\n");
	print(mat_c,n,m);
	printf("//////////////////\n");
	printf("//////////////////\n");



	dim3 blockNum(TPB,TPB,1);
	dim3 grid((blockNum.x-1+n)/blockNum.x,(blockNum.y-1+m)/blockNum.y,1);

	sum_matrix<<<grid,blockNum>>>(dd_mat_a,dd_mat_b,dd_mat_c,n,m);

	for(i=0;i<n;i++){
		cudaMemcpy(mat_c[i],d_mat_c[i],size_col,cudaMemcpyDeviceToHost);	
	}	

	printf("//////////////////\n");
	printf("//////////////////\n");
	//print(mat_a,n,m);
	printf("//////////////////\n");
	//print(mat_b,n,m);
	printf("//////////////////\n");
	print(mat_c,n,m);


	return 0;
}