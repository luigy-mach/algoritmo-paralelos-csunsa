#include <stdio.h>
#include <mpi.h>

double my_fun(double x)
{
	return x*x;
}


double My_Trap(double a,double b,double n,double h)
{
	double integral = (my_fun(a)+my_fun(b))/2;
	int i;
	for(i=1;i<=n-1;i++)
	{
		integral += my_fun(a+i*h);
	}
	return integral*h;
}


int main()
{
	int rank,size;
	MPI_Init(NULL,NULL);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);

	double a = 0;
	double b = 80.0;
	int n = 16;

	double h = (b-a)/n;
	int my_n = n/size;

	double my_a = a + rank*h*my_n;
	double my_b = my_a + h*my_n;
	double my_integral = My_Trap(my_a,my_b,my_n,h);

	int i;
	double total_integral;
	if(rank==0)
	{
		for(i=1;i<size;i++)
		{
			total_integral = my_integral;
			MPI_Recv(&my_integral,1,MPI_DOUBLE,i,0,MPI_COMM_WORLD,MPI_STATUS_IGNORE);
			total_integral += my_integral;
		}
		printf("Estimation of integral: %f\n",total_integral);
	}
	else
	{
		MPI_Send(&my_integral,1,MPI_DOUBLE,0,0,MPI_COMM_WORLD);
	}


	MPI_Finalize();
}