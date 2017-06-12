#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

double my_random() {
   double numero = (double) random() / (double) RAND_MAX;
   if((double) random() / (double) RAND_MAX < 0.5) {
      numero *= -1;
   }
   return numero;
}


int main(int argc, char* argv[]) {

   long int number_tosses;
   long int number_in_circle;

   int thread_count, i;
   double x, y, distance;

   thread_count = 24;
   number_tosses = 1000000000; // 10000000 -> 8 threads

   number_in_circle =0;

   srandom(time(NULL));
   #pragma omp parallel for num_threads(thread_count) \
      reduction(+: number_in_circle) private(x, y, distance)
      for (i = 0; i < number_tosses; i++) {
         x = my_random(); 
         y = my_random();
         distance = x*x + y*y;

         if (distance <= 1) {
            number_in_circle += 1;
         }
      }

   double pi = 4 * number_in_circle/((double) number_tosses);

   printf("Estimation de pi = %.14f\n", pi);

   return 0;
}

