#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

#define fils 100
#define cols 100

int num_of_threads;

int A[fils][cols];
int x[cols];
int y[fils];

void fill_matrix()
{
	srand(time(NULL));
	int i,j;
	for(i=0;i<fils;i++)
	{
		for(j=0;j<cols;j++){
			A[i][j]=rand()%50+1;

		}

	}

}

void print_matrix()
{
	int i,j;
	for(i=0;i<fils;i++)
	{
		for(j=0;j<cols;j++){
			printf("%d ",A[i][j]);

		}
		printf("\n");

	}

}

void print_vector()
{
	int i;
	for(i=0;i<fils;i++)
	{
	
			printf("%d ",y[i]);

	}
	printf("\n");

}
void fill_vector()
{
	srand(time(NULL));
	int j;
	for(j=0;j<cols;j++){
		x[j]=rand()%50+1;
	}

}



void *row_by_vector(void* rank) {
   long my_rank = (long) rank;
   int i, j;
   int local_m = fils/num_of_threads; 
   int my_first_row = my_rank*local_m;
   int my_last_row = (my_rank+1)*local_m - 1;

   for (i = my_first_row; i <= my_last_row; i++) {
      y[i] = 0;
      for (j = 0; j < cols; j++)
          y[i] += A[i][j]*x[j];
   }

   return NULL;
}

int main(int argc,char* argv[])
{
	num_of_threads = strtol(argv[1],NULL,10);
	fill_matrix();
	fill_vector();
	
	
	pthread_t* threads = (pthread_t*) malloc(sizeof(pthread_t)*num_of_threads);

	int i;
	for(i=0;i<num_of_threads;i++)
	{
		pthread_create(&threads[i],NULL,row_by_vector,(void*)i);

	}

	for(i=0;i<num_of_threads;i++)
	{
		pthread_join(threads[i],NULL);

	}

	print_vector();
	free(threads);
	
	return 0;
}
