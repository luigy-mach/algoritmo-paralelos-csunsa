#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "my_rand.h"
#include "timer.h"

const int MAX_KEY = 100000000;


const int IN_LIST = 1;
const int EMPTY_LIST = -1;
const int END_OF_LIST = 0;


struct list_node_s {
   int    data;
   pthread_mutex_t mutex;
   struct list_node_s* next;
};

struct list_node_s* head = NULL;  
pthread_mutex_t head_mutex;
int thread_count;
int total_ops;
double insert_percent;
double search_percent;
double delete_percent;
pthread_mutex_t count_mutex;
int member_total=0, insert_total=0, delete_total=0;

void Usage(char* prog_name);
void Get_input(int* inserts_in_main_p);

void* Thread_work(void* rank);

void Init_ptrs(struct list_node_s** curr_pp, 
      struct list_node_s** pred_pp);
int Advance_ptrs(struct list_node_s** curr_pp, 
      struct list_node_s** pred_pp);
int Insert(int value);
void Print(void);
int Member(int value);
int Delete(int value);
void Free_list(void);
int Is_empty(void);

/*-----------------------------------------------------------------*/
int main(int argc, char* argv[]) {
   long i; 
   int key, success, attempts;
   pthread_t* thread_handles;
   int inserts_in_main;
   unsigned seed = 1;
   double start, finish;

   if (argc != 2) Usage(argv[0]);
   thread_count = strtol(argv[1], NULL, 10);

   Get_input(&inserts_in_main);

   i = attempts = 0;
   pthread_mutex_init(&head_mutex, NULL);
   while ( i < inserts_in_main && attempts < 2*inserts_in_main ) {
      key = my_rand(&seed) % MAX_KEY;
      success = Insert(key);
      attempts++;
      if (success) i++;
   }
   printf("Inserted %ld keys in empty list\n", i);

#  ifdef OUTPUT
   printf("Before starting threads, list = \n");
   Print();
   printf("\n");
#  endif

   thread_handles = malloc(thread_count*sizeof(pthread_t));
   pthread_mutex_init(&count_mutex, NULL);


   //GET_TIME(start);
   for (i = 0; i < thread_count; i++)
      pthread_create(&thread_handles[i], NULL, Thread_work, (void*) i);

   for (i = 0; i < thread_count; i++)
      pthread_join(thread_handles[i], NULL);
   //GET_TIME(finish);

   printf("Elapsed time = %e seconds\n", finish - start);
   printf("Total ops = %d\n", total_ops);
   printf("member ops = %d\n", member_total);
   printf("insert ops = %d\n", insert_total);
   printf("delete ops = %d\n", delete_total);

#  ifdef OUTPUT
   printf("After threads terminate, list = \n");
   Print();
   printf("\n");
#  endif

   Free_list();
   pthread_mutex_destroy(&head_mutex);
   pthread_mutex_destroy(&count_mutex);
   free(thread_handles);

   return 0;
}  





void Init_ptrs(struct list_node_s** curr_pp, struct list_node_s** pred_pp) {
   *pred_pp = NULL;
   pthread_mutex_lock(&head_mutex);
   *curr_pp = head;
   if (head != NULL)
      pthread_mutex_lock(&(head->mutex));
}  /* Init_ptrs */


int Advance_ptrs(struct list_node_s** curr_pp, struct list_node_s** pred_pp) {
   int rv = IN_LIST;
   struct list_node_s* curr_p = *curr_pp;
   struct list_node_s* pred_p = *pred_pp;

   if (curr_p == NULL)
      if (pred_p == NULL)
         return EMPTY_LIST;
      else 
         return END_OF_LIST;
   else { // *curr_pp != NULL
      if (curr_p->next != NULL)
         pthread_mutex_lock(&(curr_p->next->mutex));
      else
         rv = END_OF_LIST;
      if (pred_p != NULL)
         pthread_mutex_unlock(&(pred_p->mutex));
      else
         pthread_mutex_unlock(&head_mutex);
      *pred_pp = curr_p;
      *curr_pp = curr_p->next;
      return rv;
   }
}

int Insert(int value) {
   struct list_node_s* curr;
   struct list_node_s* pred;
   struct list_node_s* temp;
   int rv = 1;

   Init_ptrs(&curr, &pred);
   
   while (curr != NULL && curr->data < value) {
      Advance_ptrs(&curr, &pred);
   }

   if (curr == NULL || curr->data > value) {
#     ifdef DEBUG
      printf("Inserting %d\n", value);
#     endif
      temp = malloc(sizeof(struct list_node_s));
      pthread_mutex_init(&(temp->mutex), NULL);
      temp->data = value;
      temp->next = curr;
      if (curr != NULL) 
         pthread_mutex_unlock(&(curr->mutex));
      if (pred == NULL) {
         // Inserting in head of list
         head = temp;
         pthread_mutex_unlock(&head_mutex);
      } else {
         pred->next = temp;
         pthread_mutex_unlock(&(pred->mutex));
      }
   } else { /* value in list */
      if (curr != NULL) 
         pthread_mutex_unlock(&(curr->mutex));
      if (pred != NULL)
         pthread_mutex_unlock(&(pred->mutex));
      else
         pthread_mutex_unlock(&head_mutex);
      rv = 0;
   }

   return rv;
}  

void Print(void) {
   struct list_node_s* temp;

   printf("list = ");

   temp = head;
   while (temp != (struct list_node_s*) NULL) {
      printf("%d ", temp->data);
      temp = temp->next;
   }
   printf("\n");
}  


/*-----------------------------------------------------------------*/
int  Member(int value) {
   struct list_node_s* temp;

   pthread_mutex_lock(&head_mutex);
   temp = head;
   while (temp != NULL && temp->data < value) {
      if (temp->next != NULL) 
         pthread_mutex_lock(&(temp->next->mutex));
      if (temp == head)
         pthread_mutex_unlock(&head_mutex);
      pthread_mutex_unlock(&(temp->mutex));
      temp = temp->next;
   }

   if (temp == NULL || temp->data > value) {
#     ifdef DEBUG
      printf("%d is not in the list\n", value);
#     endif
      if (temp == head)
         pthread_mutex_unlock(&head_mutex);
      if (temp != NULL) 
         pthread_mutex_unlock(&(temp->mutex));
      return 0;
   } else {
#     ifdef DEBUG
      printf("%d is in the list\n", value);
#     endif
      if (temp == head)
         pthread_mutex_unlock(&head_mutex);
      pthread_mutex_unlock(&(temp->mutex));
      return 1;
   }
}  /* Member */


int Delete(int value) {
   struct list_node_s* curr;
   struct list_node_s* pred;
   int rv = 1;

   Init_ptrs(&curr, &pred);

   /* Find value */
   while (curr != NULL && curr->data < value) {
      Advance_ptrs(&curr, &pred);
   }
   
   if (curr != NULL && curr->data == value) {
      if (pred == NULL) { /* first element in list */
         head = curr->next;
#        ifdef DEBUG
         printf("Freeing %d\n", value);
#        endif
         pthread_mutex_unlock(&head_mutex);
         pthread_mutex_unlock(&(curr->mutex));
         pthread_mutex_destroy(&(curr->mutex));
         free(curr);
      } else { 
         pred->next = curr->next;
         pthread_mutex_unlock(&(pred->mutex));
#        ifdef DEBUG
         printf("Freeing %d\n", value);
#        endif
         pthread_mutex_unlock(&(curr->mutex));
         pthread_mutex_destroy(&(curr->mutex));
         free(curr);
      }
   } else { /* Not in list */
      if (pred != NULL)
         pthread_mutex_unlock(&(pred->mutex));
      if (curr != NULL)
         pthread_mutex_unlock(&(curr->mutex));
      if (curr == head)
         pthread_mutex_unlock(&head_mutex);
      rv = 0;
   }

   return rv;
}  /* Delete */


void Free_list(void) {
   struct list_node_s* current;
   struct list_node_s* following;

   if (Is_empty()) return;
   current = head; 
   following = current->next;
   while (following != NULL) {
#     ifdef DEBUG
      printf("Freeing %d\n", current->data);
#     endif
      free(current);
      current = following;
      following = current->next;
   }
#  ifdef DEBUG
   printf("Freeing %d\n", current->data);
#  endif
   free(current);
}  

/*-----------------------------------------------------------------*/
int  Is_empty(void) {
   if (head == NULL)
      return 1;
   else
      return 0;
}  

/*-----------------------------------------------------------------*/
void* Thread_work(void* rank) {
   long my_rank = (long) rank;
   int i, val;
   double which_op;
   unsigned seed = my_rank + 1;
   int my_member=0, my_insert=0, my_delete=0;
   int ops_per_thread = total_ops/thread_count;

   for (i = 0; i < ops_per_thread; i++) {
      which_op = my_drand(&seed);
      val = my_rand(&seed) % MAX_KEY;
      if (which_op < search_percent) {
#        ifdef DEBUG
         printf("Thread %ld > Searching for %d\n", my_rank, val);
#        endif
         Member(val);
         my_member++;
      } else if (which_op < search_percent + insert_percent) {
#        ifdef DEBUG
         printf("Thread %ld > Attempting to insert %d\n", my_rank, val);
#        endif
         Insert(val);
         my_insert++;
      } else { /* delete */
#        ifdef DEBUG
         printf("Thread %ld > Attempting to delete %d\n", my_rank, val);
#        endif
         Delete(val);
         my_delete++;
      }
   }  

   pthread_mutex_lock(&count_mutex);
   member_total += my_member;
   insert_total += my_insert;
   delete_total += my_delete;
   pthread_mutex_unlock(&count_mutex);

   return NULL;
}  

/*-----------------------------------------------------------------*/
void Usage(char* prog_name) {
   fprintf(stderr, "usage: %s <thread_count>\n", prog_name);
   exit(0);
}  
/*-----------------------------------------------------------------*/
void Get_input(int* inserts_in_main_p) {

   printf("How many keys should be inserted in the main thread?\n");
   scanf("%d", inserts_in_main_p);
   printf("How many total ops should the threads execute?\n");
   scanf("%d", &total_ops);
   
	search_percent = 0.85;
	//printf("Percent of ops that should be searches? (between 0 and 1)\n");
   //scanf("%lf", &search_percent);
   //printf("Percent of ops that should be inserts? (between 0 and 1)\n");
   //scanf("%lf", &insert_percent);
	insert_percent = 0.95;
   delete_percent = 1.0 - (search_percent + insert_percent);
}  
