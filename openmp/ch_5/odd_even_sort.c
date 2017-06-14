#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <getopt.h>
#include <string.h>



/*
	g++ -c main.cpp -o test.o -fopenmp
	g++ test.o -o test -fopenmp -lpthread
*/


void fill_vec(int *a, int n)
{
	int i;
	for(i=0;i<n;i++){
		a[i] = rand()%100;		
	}
}


void print_vec(int *a, int n){
	int i;
	for(i=0;i<n;i++){
		printf("%d ",a[i]);
	}
	printf("\n");
}


void odd_even_sort1(int* a, int n,int num_thread)
{
  int fase, i, temp;
  for(fase=0;fase<n;++fase)
  {
  	if(fase%2==0) 
    {
    	#pragma omp parallel for num_threads(num_thread) default(none) shared(a,n) private(i,temp)
      	for(i=1;i<n;i+=2)
			if(a[i-1] > a[i])
			{
	  			temp = a[i];
	  			a[i] = a[i-1];
	  			a[i-1] = temp;
			}
    }
    else 
    {
		#pragma omp parallel for num_threads(num_thread) default(none) shared(a,n) private(i,temp)
      	for(i=1;i<n-1;i+=2)
			if(a[i] > a[i+1])
			{
      	  		temp = a[i];
	  			a[i] = a[i+1];
	  			a[i+1] = temp;
			}
    }
  }
}

void odd_even_sort2(int* a, int n,int num_thread)
{
  int fase, i, temp;
  #pragma omp parallel num_threads(num_thread) default(none) shared(a,n) private(i,temp,fase)
  for(fase=0;fase<n;++fase)
  {
    if(fase%2==0) 
    {
		#pragma omp for
      	for(i=1;i<n;i+=2)
			if(a[i-1] > a[i])
			{
	  			temp = a[i];
	  			a[i] = a[i-1];
	  			a[i-1] = temp;
			}
    }
    else 
    {
		#pragma omp for
      	for(i=1;i<n-1;i+=2)
			if(a[i] > a[i+1])
			{
      	  		temp = a[i];
	  			a[i] = a[i+1];
	  			a[i+1] = temp;
			}
    }
  }
}

int main(int argc,char* argv[])
{
	int num = 20;
	int num_thread = 4;
	
	double start1, end1, e1;
 	double start2, end2, e2;

	int size = num*sizeof(int);

	int* input = (int*) malloc(size);
	fill_vec(input,num);

	int *vec_a ,*vec_b;
	vec_a = (int*) malloc(size);
	vec_b = (int*) malloc(size);

	memcpy(vec_a,input,size);
	memcpy(vec_b,input,size);

	print_vec(vec_a,num);
	print_vec(vec_b,num);

	start1 = omp_get_wtime();
  		odd_even_sort1(vec_a,num,num_thread);
  	end1 = omp_get_wtime();
  	e1 = end1 - start1;

  	start2 = omp_get_wtime();
  		odd_even_sort2(vec_b,num,num_thread);
  	end2 = omp_get_wtime();
  	e2 = end2 - start2;

	print_vec(vec_a,num);
	print_vec(vec_b,num);

	printf("->1 - time: %f\n",e1);
  	printf("->2 - time: %f\n",e2);


	free(input);
	free(vec_a);
	free(vec_b);
	return 0;
}