#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#define n 800
#define nbloque 80

#define MIN(a,b) ((a) < (b) ? (a) : (b))
inline int min ( int a, int b ) { return a < b ? a : b; }

void matrix_product_bloked(int A[n][n],int B[n][n],int C[n][n]){
for(int i1=1;i1<n;i1=i1+nbloque){
   for(int j1=1;j1<n;j1=j1+nbloque){
	  for(int k1=1;k1<n;k1=k1+nbloque){
		 for(int i=i1;i<MIN(i1+nbloque-1,n);i++){
			for(int j=j1;j<MIN(j1+nbloque-1,n);j++){
		    	for(int k=k1;k<MIN(k1+nbloque-1,n);k++){
					C[i][j]+=A[i][k]*B[k][j];
					}
				}
			}
		}
	}
  }
}	
