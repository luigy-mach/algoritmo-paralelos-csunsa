#include <stdio.h>
#include <string.h> 
#include <mpi.h> 


const int MAX_STRING = 100;

int main(void) {
char greeting[MAX_STRING];
int comm_sz; 
int my_rank; 
int value=0;

MPI_Init(NULL, NULL);
MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
MPI_Status status;

int i=0;
int limit=1;
while(i<limit){
	if (my_rank == 0) {
	    MPI_Send(&i, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
	    MPI_Recv(&i, 1, MPI_INT, 1, 0, MPI_COMM_WORLD, &status);
	    printf("PING from process %d has i= %d \n", my_rank, i);
	    i++;

	 } else {
        MPI_Recv(&i, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
        printf("PONG from process %d has i= %d \n", my_rank, i);
        i++;
        MPI_Send(&i, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);     
	 }
}

 MPI_Finalize();
 return 0;

} 

