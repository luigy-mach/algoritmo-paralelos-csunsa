#include <stdlib.h>
#include <stdio.h>

#define N 4	
#define T 2


__global__ void sum_matrix(int** mat1, int** ddmat1, int** mat2, int** ddmat2, int** mat3, int** ddmat3, int n, int m){
				int x = threadIdx.x + blockIdx.x*blockDim.x;
				int y = threadIdx.y + blockIdx.y*blockDim.y;
				mat3[1][x] = 0;
				
}

void create(int**&mat,int n){
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

/*
 void create_matrix(int**&mat, int**&h_mat, int**&d_mat, int n, int m){
	int size_n=sizeof(int)*n;
	int size_m=sizeof(int)*m;

	h_mat = (int**)malloc(size_n);

	int i;
	for(i=0;i<n;i++){
		printf(">>>>>\n");
		cudaMalloc((void**)& h_mat[i],size_n);
		cudaMemcpy(h_mat[i],&mat[i][0],size_m,cudaMemcpyHostToDevice);
	}

	cudaMalloc((void*** )& d_mat,size_n);
	cudaMemcpy(d_mat,h_mat,size_n,cudaMemcpyHostToDevice);

}*/


int main(){

	int   n = N;
	int   m = N;
	int** mat_a;
		create(mat_a,n);
		fill(mat_a,n);
		print(mat_a,n);
	printf("//////////////////\n");

	int** mat_b;
		create(mat_b,n);
		fill(mat_b,n);
		print(mat_b,n);

	printf("//////////////////\n");
	
	int** mat_c;
		create(mat_c,n);
		fill_zero(mat_c,n,-1);
		print(mat_c,n);

	printf("//////////////////\n");

	int ** h_mat_a;	int ** d_mat_a; int ** dd_mat_a;
	int ** h_mat_b;	int ** d_mat_b; int ** dd_mat_b;
	int ** h_mat_c;	int ** d_mat_c; int ** dd_mat_c;

	
	int i;
	 
	///////////////////////

    h_mat_a = (int** )malloc(sizeof(int*)*n);
    for(i=0;i<n;i++){
    	printf(">>>>>\n");
        cudaMalloc((void** )& h_mat_a[i], sizeof(int)*m);
        cudaMemcpy(h_mat_a[i],&mat_a[i][0],sizeof(int)*m,cudaMemcpyHostToDevice);
    }
    
    cudaMalloc((void*** )& d_mat_a,sizeof(int*)*n);
    cudaMemcpy(d_mat_a,h_mat_a,sizeof(int)*n,cudaMemcpyHostToDevice);    

    cudaMalloc((void*** )& dd_mat_a,sizeof(int*)*n);
    cudaMemcpy(dd_mat_a,h_mat_a,sizeof(int)*n,cudaMemcpyHostToDevice);    
 
    ///

  	h_mat_b = (int** )malloc(sizeof(int*)*n);
    for(i=0;i<n;i++){
    	printf(">>>>>\n");
        cudaMalloc((void** )& h_mat_b[i], sizeof(int)*m);
        cudaMemcpy(h_mat_b[i],&mat_b[i][0],sizeof(int)*m,cudaMemcpyHostToDevice);
    }
    
    cudaMalloc((void*** )& d_mat_b,sizeof(int*)*n);
    cudaMemcpy(d_mat_b,h_mat_b,sizeof(int)*n,cudaMemcpyHostToDevice);    

    cudaMalloc((void*** )& dd_mat_b,sizeof(int*)*n);
    cudaMemcpy(dd_mat_b,h_mat_b,sizeof(int)*n,cudaMemcpyHostToDevice);    

    ///
    
  	h_mat_c = (int** )malloc(sizeof(int*)*n);
    for(i=0;i<n;i++){
    	printf(">>>>>\n");
        cudaMalloc((void** )& h_mat_c[i], sizeof(int)*m);
        cudaMemcpy(h_mat_c[i],&mat_c[i][0],sizeof(int)*m,cudaMemcpyHostToDevice);
    }
    
    cudaMalloc((void*** )& d_mat_c,sizeof(int*)*n);
    cudaMemcpy(d_mat_c,h_mat_c,sizeof(int)*n,cudaMemcpyHostToDevice);    

    cudaMalloc((void*** )& dd_mat_c,sizeof(int*)*n);
    cudaMemcpy(dd_mat_c,h_mat_c,sizeof(int)*n,cudaMemcpyHostToDevice);    

    ////////////////77

	//create_matrix(mat_a,h_mat_a,d_mat_a,n,m);
	//create_matrix(mat_b,h_mat_b,d_mat_b,n,m);
	//create_matrix(mat_c,h_mat_c,d_mat_c,n,m);



	dim3 grid(ceil(N/T),ceil(N/T),1);
	dim3 blockNum(T,T,1);

	//int size = sizeof(int)*n*n;
	sum_matrix<<<grid,blockNum>>>(d_mat_a,dd_mat_a,d_mat_b,dd_mat_b,d_mat_c,dd_mat_c,n,m);

	
	for(i=0;i<n;i++){
		cudaMemcpy(&mat_c[i][0],h_mat_c[i],sizeof(int)*m,cudaMemcpyDeviceToHost);	
	}
	

	printf("///////CCCCCC///////////\n");
	print(mat_c,n);


	return 0;
}