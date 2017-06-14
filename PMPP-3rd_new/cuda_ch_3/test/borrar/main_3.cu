#include <cstdio>
__global__ void add(int * dev_a[], int * dev_b[], int * dev_c[])
{
    for(int i=0;i<2;i++)
    { 
        for(int j=0;j<2;j++)
        {
            dev_c[i][j]=dev_a[i][j]+dev_b[i][j];
        }
    }
}

inline void GPUassert(cudaError_t code, char * file, int line, bool Abort=true)
{
    if (code != 0) {
        fprintf(stderr, "GPUassert: %s %s %d\n", cudaGetErrorString(code),file,line);
        if (Abort) exit(code);
    }       
}

#define GPUerrchk(ans) { GPUassert((ans), __FILE__, __LINE__); }

int main(void)
{


        ///////////////////////
/*  
    h_mat_a = (int** )malloc(size_col);
    for(i=0;i<n;i++){
    printf(">>>>>\n");
        cudaMalloc((void** )& h_mat_a[i], size_row);
        cudaMemcpy(h_mat_a[i],&mat_a[i][0],size_col,cudaMemcpyHostToDevice);
    }
    
    cudaMalloc((void*** )& d_mat_a,size_row);
    cudaMemcpy(d_mat_a,h_mat_a,size_row,cudaMemcpyHostToDevice);    
*/  
    ////////////////77

    const int aa[2][2]={{1,2},{3,4}};
    const int bb[2][2]={{5,6},{7,8}};
    int cc[2][2];

    int ** h_a = (int **)malloc(2 * sizeof(int *));
    for(int i=0; i<2;i++){
        GPUerrchk(cudaMalloc((void**)&h_a[i], 2*sizeof(int)));
        GPUerrchk(cudaMemcpy(h_a[i], &aa[i][0], 2*sizeof(int), cudaMemcpyHostToDevice));
    }

    int **d_a;
    GPUerrchk(cudaMalloc((void ***)&d_a, 2 * sizeof(int *)));
    GPUerrchk(cudaMemcpy(d_a, h_a, 2*sizeof(int *), cudaMemcpyHostToDevice));

    int ** h_b = (int **)malloc(2 * sizeof(int *));
    for(int i=0; i<2;i++){
        GPUerrchk(cudaMalloc((void**)&h_b[i], 2*sizeof(int)));
        GPUerrchk(cudaMemcpy(h_b[i], &bb[i][0], 2*sizeof(int), cudaMemcpyHostToDevice));
    }

    int ** d_b;
    GPUerrchk(cudaMalloc((void ***)&d_b, 2 * sizeof(int *)));
    GPUerrchk(cudaMemcpy(d_b, h_b, 2*sizeof(int *), cudaMemcpyHostToDevice));

    int ** h_c = (int **)malloc(2 * sizeof(int *));
    for(int i=0; i<2;i++){
        GPUerrchk(cudaMalloc((void**)&h_c[i], 2*sizeof(int)));
    }

    int ** d_c;
    GPUerrchk(cudaMalloc((void ***)&d_c, 2 * sizeof(int *)));
    GPUerrchk(cudaMemcpy(d_c, h_c, 2*sizeof(int *), cudaMemcpyHostToDevice));

    add<<<1,1>>>(d_a,d_b,d_c);
    GPUerrchk(cudaPeekAtLastError());

    for(int i=0; i<2;i++){
        GPUerrchk(cudaMemcpy(&cc[i][0], h_c[i], 2*sizeof(int), cudaMemcpyDeviceToHost));
    }

    for(int i=0;i<2;i++) {
        for(int j=0;j<2;j++) {
            printf("(%d,%d):%d\n",i,j,cc[i][j]);
        }
    }

    return cudaThreadExit();
}