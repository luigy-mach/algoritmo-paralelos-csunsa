#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mpi.h>
#include <math.h>

#define N 20

void sequentialSort(int *arrayToSort, int size) {
    int sorted = 0;
    while( sorted == 0) {
        sorted= 1;
        int i;
        for(i=1;i<size-1; i += 2) {
            if(arrayToSort[i] > arrayToSort[i+1])
            {
                int temp = arrayToSort[i+1];
                arrayToSort[i+1] = arrayToSort[i];
                arrayToSort[i] = temp;
                sorted = 0;
            }
        }
 
        for(i=0;i<size-1;i+=2) {
            if(arrayToSort[i] > arrayToSort[i+1])
            {
                int temp = arrayToSort[i+1];
                arrayToSort[i+1] = arrayToSort[i];
                arrayToSort[i] = temp;
                sorted = 0;
            }
        }   
    }
}


void lower(int *array1, int *array2, int size) 
{
    
    int *new = malloc(size*sizeof(int));
    int k = 0;
    int l = 0;
    int count;
    for(count=0;count<size;count++) {
        if (array1[k] <= array2[l] ) {
            new[count] = array1[k];
            k++;
        } else {
            new[count] = array2[l];
            l++;
        }
    } 
    
    for(count=0;count<size;count++) {
        array1[count] = new[count];
    }
    free(new);
}


void higher(int *array1, int *array2, int size) 
{
    int *new = malloc(size*sizeof(int));
    int k = size-1;
    int l = size-1;
    int count;
    for(count=size-1;count>=0;count--) {
        if (array1[k] >= array2[l] ) {
            new[count] = array1[k];
            k--;
        } else {
            new[count] = array2[l];
            l--;
        }
    } 
    
    for(count=0;count<size;count++) {
        array1[count] = new[count];
    }
    free(new);
}


void exchangeWithNext(int *subArray, int size, int rank)
{
    MPI_Send(subArray,size,MPI_INT,rank+1,0,MPI_COMM_WORLD);
  
    int *nextArray = malloc(size*sizeof(int));
    MPI_Status stat;
    MPI_Recv(nextArray,size,MPI_INT,rank+1,0,MPI_COMM_WORLD,&stat);
    lower(subArray,nextArray,size);
    free(nextArray);
}

void exchangeWithPrevious(int *subArray, int size, int rank)
{
    
    MPI_Send(subArray,size,MPI_INT,rank-1,0,MPI_COMM_WORLD);
    
    int *previousArray = malloc(size*sizeof(int));
    MPI_Status stat;
    MPI_Recv(previousArray,size,MPI_INT,rank-1,0,MPI_COMM_WORLD,&stat);
    
    higher(subArray,previousArray,size);
    free(previousArray);
}

int main(int argc, char **argv)
{
    
    MPI_Init(&argc,&argv);
        
    
    int hostCount;
    MPI_Comm_size(MPI_COMM_WORLD,&hostCount);
    
    
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    
    
    int *arrayToSort = malloc(N * sizeof(int));
    if(rank == 0) {
        srand(time(NULL));
        printf("Iinitial array\n");
        int i;
        for(i=0;i<N;i++) {
            arrayToSort[i] = rand()%100;
            printf("%d ",arrayToSort[i]);
        }
        printf("\n");
    }
    
    
    
    double start;
    if (rank == 0) {
        start = clock();
    }
    
    int *subArray = malloc(N/hostCount  * sizeof(int));
    if(rank == 0) { 
        
        MPI_Scatter(arrayToSort,N/hostCount,MPI_INT,subArray,N/hostCount,MPI_INT,0,MPI_COMM_WORLD);
    }
    
   
    int *displs = malloc(hostCount * sizeof(int));
    int i;
    for (i=0;i<hostCount;i++) {
        displs[i] = i*(N/hostCount);
    }
    
    
    int *sendcnts = malloc(hostCount * sizeof(int));
    for (i=0;i<hostCount;i++) {
        sendcnts[i]=N/hostCount;
    }
    
    MPI_Scatterv(arrayToSort,sendcnts,displs,MPI_INT,subArray,N/hostCount,MPI_INT,0,MPI_COMM_WORLD);
    free(displs);
    free(sendcnts);
    
    
    sequentialSort(subArray,N/hostCount);
    
    i =0;
    for(i=0;i<hostCount;i++) {
        /* even phase */
        if (i%2==0) {
            /* even numbered host */
            if(rank%2==0) { 
                
                if(rank<hostCount-1) {
                    
                    exchangeWithNext(subArray,N/hostCount,rank);
                }
            } else { 
               
                if (rank-1 >=0 ) {
                   
                     exchangeWithPrevious(subArray,N/hostCount,rank);
                }
            }
        }
        /* odd phase */
        else { 
            /* odd host */
            if(rank%2!=0) { 
                
                if (rank<hostCount-1) {
                    
                    exchangeWithNext(subArray,N/hostCount,rank);
                }
            } 
            
            else {
                
                if (rank-1 >=0 ) {
                    
                     exchangeWithPrevious(subArray,N/hostCount,rank);
                }
            }
        }
    }
    
  
    MPI_Gather(subArray,N/hostCount,MPI_INT,arrayToSort,N/hostCount,MPI_INT,0,MPI_COMM_WORLD);
    
    if(rank == 0) {
        printf("\n");
        printf("Sorted array\n");
        int elem;
        for(elem=0;elem<N;elem++) {
            printf("%d ",arrayToSort[elem]);
        }
        printf("\n");
    }
    
    MPI_Finalize();
    return 0;
}
