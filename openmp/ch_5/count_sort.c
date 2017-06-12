#include <stdio.h>
#include <stdlib.h>
#include <omp.h>


#define RAND_MAXIMO 99


void serial_count_sort(int* a,int n)
{
	int i,j,count;
	int size = n*sizeof(int);
	int* tmp = malloc(size);
	for(i=0;i<n;i++){
		count = 0;
		for(j=0;j<n;j++){
			if(a[j] < a[i])
				count++;
			else if(a[j] == a[i] && j<i)
				count++;
		}
		tmp[count] = a[i];
	}
	memcpy(a,tmp,size);
	free(tmp);
}

void parallel_count_sort(int* a,int n,int thread_count)
{
	int i,j,count;
	int size = n*sizeof(int);
	int* tmp = malloc(size);
	#pragma omp parallel for num_threads(thread_count) \
	default(none) private(i, j, count) shared(a, n, tmp, thread_count)
	for (i = 0; i < n; i++){
        count = 0;
        for (j = 0; j < n; j++){
            if (a[j] < a[i])
               count++;
            else if (a[j] == a[i] && j < i)
               count++;
       	}
        tmp[count] = a[i];
     }
	memcpy(a,tmp,size);
	free(tmp);
}

void fill_vec(int* a,int n)
{
	srand(time(NULL));
	int i;
	for(i=0;i<n;i++){
		a[i] = rand()%RAND_MAXIMO +1;
	}

}

void print_vec(int* a,int n)
{
	int i;
	for(i=0;i<n;i++){
		printf("%d ",a[i]);
	}
	printf("\n");

}


int main(int argc,char* argv[])
{
	int thread_count = 24;
	//int n_elems = 1000000; //1000000-> 8threads
	int n_elems = 100000000; //1000000-> 8threads

	int my_size = n_elems*sizeof(int);
	int* vec1 = (int*) malloc(my_size);
	
	fill_vec(vec1,n_elems);

	//serial_count_sort(vec1,n_elems);
	parallel_count_sort(vec1,n_elems,thread_count);

	free(vec1);

	return 0;
}