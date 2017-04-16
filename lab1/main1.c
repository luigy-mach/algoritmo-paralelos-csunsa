#include <stdio.h>
#include <stdlib.h>

#define n 800

void matrix_product_simple(int A[n][n],int B[n][n],int C[n][n])
{        
    for(int i=0; i<n; ++i)
    {
        for(int j=0; j<n; ++j)
        {
            for(int k=0; k<n; ++k)
            {
                C[i][j]+=A[i][k]*B[k][j];
            }    
        }
    }
}

int main(){
    
   
    



    return 0;
}



