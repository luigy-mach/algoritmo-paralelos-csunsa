#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int my_rank, comm_sz;
MPI_Comm comm;

void Check_for_error(int local_ok, char fname[], char message[]);
void Get_dims(int argc, char* argv[], int* m_p, int* local_m_p, 
      int* n_p, int* local_n_p);
void Allocate_arrays(double** local_A_pp, double** local_x_pp, 
      double** local_y_pp, int local_m, int n, int local_n);
void Read_matrix(char prompt[], double local_A[], int m, int local_m, 
      int n, int local_n);
void Read_vector(char prompt[], double local_vec[], int n, int local_n);
void Generate_matrix(double local_A[], int local_m, int n);
void Generate_vector(double local_x[], int local_n);
void Print_matrix(char title[], double local_A[], int m, int local_m, 
      int n);
void Print_vector(char title[], double local_vec[], int n,
      int local_n);
void Mat_vect_mult(double local_A[], double local_x[], 
      double local_y[], double x[], int m, int local_m, int n, 
      int local_n);

/*-------------------------------------------------------------------*/
int main(int argc, char* argv[]) {
   double* local_A;
   double* local_x;
   double* local_y;
   double* x;
   int m, local_m, n, local_n;
   double start, finish, loc_elapsed, elapsed;

   MPI_Init(&argc, &argv);
   comm = MPI_COMM_WORLD;
   MPI_Comm_size(comm, &comm_sz);
   MPI_Comm_rank(comm, &my_rank);

   Get_dims(argc, argv, &m, &local_m, &n, &local_n);
   Allocate_arrays(&local_A, &local_x, &local_y, local_m, n, local_n);

   srandom(my_rank);
   Generate_matrix(local_A, local_m, n);
#  ifdef DEBUG
   Print_matrix("A", local_A, m, local_m, n);
#  endif

   Generate_vector(local_x, local_n);
#  ifdef DEBUG
   Print_vector("x", local_x, n, local_n);
#  endif

   x = malloc(n*sizeof(double));
   MPI_Barrier(comm);
   start = MPI_Wtime();
   Mat_vect_mult(local_A, local_x, local_y, x, m, local_m, n, local_n);
   finish = MPI_Wtime();
   loc_elapsed = finish-start;
   MPI_Reduce(&loc_elapsed, &elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, comm);

#  ifdef DEBUG
   Print_vector("y", local_y, m, local_m);
#  endif

   if (my_rank == 0) {

      printf("%e\n", elapsed);

   }
   free(local_A);
   free(local_x);
   free(local_y);
   free(x);
   MPI_Finalize();
   return 0;
}  


/*-------------------------------------------------------------------*/
void Check_for_error(
      int       local_ok   , 
      char      fname[]    ,
      char      message[]  ) {
   int ok;

   MPI_Allreduce(&local_ok, &ok, 1, MPI_INT, MPI_MIN, comm);
   if (ok == 0) {
      int my_rank;
      MPI_Comm_rank(comm, &my_rank);
      if (my_rank == 0) {
         fprintf(stderr, "Proc %d > In %s, %s\n", my_rank, fname, 
               message);
         fflush(stderr);
      }
      MPI_Finalize();
      exit(-1);
   }
}


/*-------------------------------------------------------------------*/
void Get_dims(
      int       argc       ,
      char*     argv[]    ,
      int*      m_p        , 
      int*      local_m_p  ,
      int*      n_p        ,
      int*      local_n_p  ) {
   int local_ok = 1;

   if (my_rank == 0) {
      if (argc != 2) 
         *m_p = *n_p = 0;
      else 
         *m_p = *n_p = strtol(argv[1], NULL, 10);
   }
   MPI_Bcast(m_p, 1, MPI_INT, 0, comm);
   MPI_Bcast(n_p, 1, MPI_INT, 0, comm);
   if (*m_p <= 0 || *n_p <= 0 || *m_p % comm_sz != 0 
         || *n_p % comm_sz != 0) local_ok = 0;
   Check_for_error(local_ok, "Get_dims",
      "m and n must be positive and evenly divisible by comm_sz");

   *local_m_p = *m_p/comm_sz;
   *local_n_p = *n_p/comm_sz;
}  

/*-------------------------------------------------------------------*/
void Allocate_arrays(
      double**  local_A_pp  , 
      double**  local_x_pp  , 
      double**  local_y_pp  , 
      int       local_m     , 
      int       n           ,   
      int       local_n     ) {

   int local_ok = 1;

   *local_A_pp = malloc(local_m*n*sizeof(double));
   *local_x_pp = malloc(local_n*sizeof(double));
   *local_y_pp = malloc(local_m*sizeof(double));

   if (*local_A_pp == NULL || local_x_pp == NULL ||
         local_y_pp == NULL) local_ok = 0;
   Check_for_error(local_ok, "Allocate_arrays",
         "Can't allocate local arrays");
}  

/*-------------------------------------------------------------------*/
void Read_matrix(
      char      prompt[]   , 
      double    local_A[]  , 
      int       m         , 
      int       local_m    , 
      int       n          ,
      int       local_n    ) {
   double* A = NULL;
   int local_ok = 1;
   int i, j;

   if (my_rank == 0) {
      A = malloc(m*n*sizeof(double));
      if (A == NULL) local_ok = 0;
      Check_for_error(local_ok, "Read_matrix",
            "Can't allocate temporary matrix");
      printf("Enter the matrix %s\n", prompt);
      for (i = 0; i < m; i++)
         for (j = 0; j < n; j++)
            scanf("%lf", &A[i*n+j]);
      MPI_Scatter(A, local_m*n, MPI_DOUBLE, 
            local_A, local_m*n, MPI_DOUBLE, 0, comm);
      free(A);
   } else {
      Check_for_error(local_ok, "Read_matrix",
            "Can't allocate temporary matrix");
      MPI_Scatter(A, local_m*n, MPI_DOUBLE, 
            local_A, local_m*n, MPI_DOUBLE, 0, comm);
   }
}  

/*-------------------------------------------------------------------*/
void Read_vector(
      char      prompt[]     , 
      double    local_vec[]  , 
      int       n            ,
      int       local_n      ) {
   double* vec = NULL;
   int i, local_ok = 1;

   if (my_rank == 0) {
      vec = malloc(n*sizeof(double));
      if (vec == NULL) local_ok = 0;
      Check_for_error(local_ok, "Read_vector",
            "Can't allocate temporary vector");
      printf("Enter the vector %s\n", prompt);
      for (i = 0; i < n; i++)
         scanf("%lf", &vec[i]);
      MPI_Scatter(vec, local_n, MPI_DOUBLE,
            local_vec, local_n, MPI_DOUBLE, 0, comm);
      free(vec);
   } else {
      Check_for_error(local_ok, "Read_vector",
            "Can't allocate temporary vector");
      MPI_Scatter(vec, local_n, MPI_DOUBLE,
            local_vec, local_n, MPI_DOUBLE, 0, comm);
   }
}  

/*-------------------------------------------------------------------*/
void Generate_matrix(double local_A[], int local_m, int n) {
   int i, j;

#  ifndef DEBUG
   for (i = 0; i < local_m; i++)
      for (j = 0; j < n; j++) 
         local_A[i*n + j] = ((double) random())/((double) RAND_MAX);
#  else
   for (i = 0; i < local_m; i++)
      for (j = 0; j < n; j++) 
         local_A[i*n + j] = my_rank + i;
#  endif
}  

/*-------------------------------------------------------------------*/
void Generate_vector(double local_x[], int local_n) {
   int i;

#  ifndef DEBUG
   for (i = 0; i < local_n; i++)
      local_x[i] = ((double) random())/((double) RAND_MAX);
#  else
   for (i = 0; i < local_n; i++)
      local_x[i] = my_rank + 1;

#  endif
}  

/*-------------------------------------------------------------------*/
void Print_matrix(
      char      title[]    ,
      double    local_A[]  , 
      int       m          , 
      int       local_m    , 
      int       n          ) {
   double* A = NULL;
   int i, j, local_ok = 1;

   if (my_rank == 0) {
      A = malloc(m*n*sizeof(double));
      if (A == NULL) local_ok = 0;
      Check_for_error(local_ok, "Print_matrix",
            "Can't allocate temporary matrix");
      MPI_Gather(local_A, local_m*n, MPI_DOUBLE,
            A, local_m*n, MPI_DOUBLE, 0, comm);
      printf("\nThe matrix %s\n", title);
      for (i = 0; i < m; i++) {
         for (j = 0; j < n; j++)
            printf("%f ", A[i*n+j]);
         printf("\n");
      }
      printf("\n");
      free(A);
   } else {
      Check_for_error(local_ok, "Print_matrix",
            "Can't allocate temporary matrix");
      MPI_Gather(local_A, local_m*n, MPI_DOUBLE,
            A, local_m*n, MPI_DOUBLE, 0, comm);
   }
}  

/*-------------------------------------------------------------------*/
void Print_vector(
      char      title[]     , 
      double    local_vec[] , 
      int       n           ,
      int       local_n     ) {
   double* vec = NULL;
   int i, local_ok = 1;

   if (my_rank == 0) {
      vec = malloc(n*sizeof(double));
      if (vec == NULL) local_ok = 0;
      Check_for_error(local_ok, "Print_vector",
            "Can't allocate temporary vector");
      MPI_Gather(local_vec, local_n, MPI_DOUBLE,
            vec, local_n, MPI_DOUBLE, 0, comm);
      printf("\nThe vector %s\n", title);
      for (i = 0; i < n; i++)
         printf("%f ", vec[i]);
      printf("\n");
      free(vec);
   }  else {
      Check_for_error(local_ok, "Print_vector",
            "Can't allocate temporary vector");
      MPI_Gather(local_vec, local_n, MPI_DOUBLE,
            vec, local_n, MPI_DOUBLE, 0, comm);
   }
}  

/*-------------------------------------------------------------------*/
void Mat_vect_mult(
      double    local_A[]  , 
      double    local_x[]  , 
      double    local_y[]  ,
      double    x[]        ,
      int       m          ,
      int       local_m    , 
      int       n          ,
      int       local_n    ) {
   int local_i, j;

   MPI_Allgather(local_x, local_n, MPI_DOUBLE,
         x, local_n, MPI_DOUBLE, comm);

   for (local_i = 0; local_i < local_m; local_i++) {
      local_y[local_i] = 0.0;
      for (j = 0; j < n; j++)
         local_y[local_i] += local_A[local_i*n+j]*x[j];
   }
}  