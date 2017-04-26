#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>


long long n = 100000;
double sum;
int num_of_threads;

void* thread_sum(void* rank);

int main(int argc,char* argv[])
{
	num_of_threads = strtol(argv[1],NULL,10);	
	
	pthread_t* threads = (pthread_t*) malloc(sizeof(pthread_t)*num_of_threads);
	sum = 0.0;

	int i;
	for(i=0;i<num_of_threads;i++)
	{
		pthread_create(&threads[i],NULL,thread_sum,(void*)i);

	}

	for(i=0;i<num_of_threads;i++)
	{
		pthread_join(threads[i],NULL);

	}

	sum = 4*sum;
	printf("Pi: %f\n",sum);
	free(threads);
	
	return 0;
}

void* thread_sum(void* rank) {
   long my_rank = (long) rank;
   double factor;
   long long i;
   long long my_n = n/num_of_threads;
   long long my_first_i = my_n*my_rank;
   long long my_last_i = my_first_i + my_n;

   if (my_first_i % 2 == 0)
      factor = 1.0;
   else
      factor = -1.0;

   for (i = my_first_i; i < my_last_i; i++, factor = -factor) {
      sum += factor/(2*i+1);  
   }

   return NULL;
}
