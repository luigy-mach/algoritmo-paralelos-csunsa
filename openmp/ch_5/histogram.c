#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

void Gen_data(float min_meas,float max_meas, float data[], int data_count);

void Gen_bins(float min_meas, float max_meas, float bin_maxes[], int bin_counts[], int bin_count);

int Which_bin(float data, float bin_maxes[], int bin_count, float min_meas);

void print_histogram(float bin_maxes[],int bin_counts[], int bin_count, float min_meas);

int main(int argc, char* argv[]) 
{
  int thread_count;
  int bin_count, i, bin;
  float min_meas, max_meas;
  float* bin_maxes;
  int* bin_counts;
  int data_count;
  float* data;

  //bin_count = strtol(argv[1], NULL, 10);
  //min_meas = strtof(argv[2], NULL);
  //max_meas = strtof(argv[3], NULL);
  //data_count = strtol(argv[4], NULL, 10);
  //thread_count = strtol(argv[5], NULL, 10);

  bin_count = 10;
  min_meas = 1;
  max_meas = 100;
  data_count = 200;
  thread_count = 4;

  bin_maxes = malloc(bin_count*sizeof(float));
  bin_counts = malloc(bin_count*sizeof(int));
  data = malloc(data_count*sizeof(float));

  Gen_data(min_meas, max_meas, data, data_count);

  Gen_bins(min_meas, max_meas, bin_maxes, bin_counts, bin_count);

  #pragma omp parallel for num_threads(thread_count) default(none) \
    shared(data_count, data, bin_maxes, bin_count, min_meas, bin_counts) \
        private(bin, i)
    for (i = 0; i < data_count; i++) 
    {
      bin = Which_bin(data[i], bin_maxes, bin_count, min_meas);
      #pragma omp critical
      bin_counts[bin]++;
    }

    print_histogram(bin_maxes, bin_counts, bin_count, min_meas);

    free(data);
    free(bin_maxes);
    free(bin_counts);
    return 0;

}  

void Gen_data(float min_meas,float max_meas, float data[], int data_count ) 
{
   int i;

   srandom(0);
   //#pragma omp parallel for num_threads(thread_count) \
      default(none) shared(data, min_meas, max_meas, data_count)
      for (i = 0; i < data_count; i++) {
         data[i] = min_meas + (max_meas - min_meas) * random() / ((double) RAND_MAX);
      }
}  

void Gen_bins(float min_meas, float max_meas, float bin_maxes[], int bin_counts[], int bin_count) {
   float bin_width;
   int   i;

   bin_width = (max_meas - min_meas)/bin_count;

   //#pragma omp parallel for num_threads(thread_count) \
      default(none) \
      shared(min_meas, max_meas, bin_maxes, bin_counts, bin_count, bin_width) \
      private(i)
   for (i = 0; i < bin_count; i++) {
      bin_maxes[i] = min_meas + (i+1)*bin_width;
      bin_counts[i] = 0;
   }

} 

int Which_bin(float  data, float bin_maxes[], int bin_count, float min_meas) 
{
   int bottom = 0, top =  bin_count-1;
   int mid;
   float bin_max, bin_min;

   while (bottom <= top) {
      mid = (bottom + top)/2;
      bin_max = bin_maxes[mid];
      bin_min = (mid == 0) ? min_meas: bin_maxes[mid-1];
      if (data >= bin_max) 
         bottom = mid+1;
      else if (data < bin_min)
         top = mid-1;
      else
         return mid;
   }
}

void print_histogram(float  bin_maxes[], int bin_counts[], int bin_count, float  min_meas) 
{
   int i, j;
   float bin_max, bin_min;

   for (i = 0; i < bin_count; i++) {
      bin_max = bin_maxes[i];
      bin_min = (i == 0) ? min_meas: bin_maxes[i-1];
      printf("%.3f-%.3f:\t", bin_min, bin_max);
      for (j = 0; j < bin_counts[i]; j++)
         printf("| ");
      printf("\n");
   }
} 