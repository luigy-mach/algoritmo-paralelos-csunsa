#include <stdio.h>
#include <mpi.h>

int main(int argc,char* argv[])
{
	int rank,size;

	MPI_Init(NULL,NULL);

	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);

	int i;

	int n=0;

	if(rank==0)
	{
		for(i=0;i<5;i++)
		{
			n++;

			MPI_Send(&n,1,MPI_INT,1,0,MPI_COMM_WORLD);
			printf("Process: %i - Sending: %i\n\n", rank, n);

			MPI_Recv(&n,1,MPI_INT,1,0,MPI_COMM_WORLD,MPI_STATUS_IGNORE);
			printf("Process: %i - Receiving: %i\n\n", rank,n);
		}

	}
	else
	{
		for(i=0;i<5;i++)
		{
			MPI_Recv(&n,1,MPI_INT,0,0,MPI_COMM_WORLD,MPI_STATUS_IGNORE);
			printf("Process: %i - Receiving: %i\n\n", rank,n);

			n++;

			MPI_Send(&n,1,MPI_INT,0,0,MPI_COMM_WORLD);
			printf("Process: %i - Sending: %i\n\n", rank, n);
			
		}

	}
	MPI_Finalize();

}
