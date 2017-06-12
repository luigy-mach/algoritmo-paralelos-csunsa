#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

double num_random();

int main(int argc, char* argv[]) {

   long int number_tosses, number_in_circle;
   int thread_count, i;
   double x, y, distance;

   //thread_count = strtol(argv[1], NULL, 10);
   //number_tosses = strtoll(argv[2], NULL, 10);
   thread_count = 8;
   number_tosses = 19999999;

   number_in_circle =0;
   srandom(0);

   #pragma omp parallel for num_threads(thread_count) \
      reduction(+: number_in_circle) private(x, y, distance)
   for (i = 0; i < number_tosses; i++) {
      x = num_random(); 
      y = num_random();
      distance = x*x + y*y;

      if (distance <= 1) {
         number_in_circle += 1;
      }
   }

   double pi = 4*number_in_circle/((double) number_tosses);
   printf("Estimation de pi = %.14f\n", pi);
   return 0;
}

double num_random() {
   double numero = (double) random() / (double) RAND_MAX;
   if((double) random() / (double) RAND_MAX < 0.5) {
      numero *= -1;
   }
   return numero;
}