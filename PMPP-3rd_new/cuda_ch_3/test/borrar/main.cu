#include<stdio.h>



#define N 2


void foo(int a[N][N]){
	int i,j;
	for(i=0;i<N;i++)
		for(j=0;j<N;j++)
			a[i][j]=0;

}



int main(){
		
	int a[N][N];
	int (*b)[N];


	//a=malloc( N * sizeof(int*) );
	//int i;
	//for(i=0;i<N;i++)
	//	a[i]=malloc(sizeof(int)*N);

	foo(a);


	int i,j;
	for(i=0;i<N;i++){
		for(j=0;j<N;j++)
			//printf("%i",a[i][j]);
		printf("\n");	
	}
	


	printf("&&&&&&&&&&&&&&&&&&&&\n");
	printf("%d\n",sizeof(float*));
	printf("%d\n",sizeof(double*));
	printf("%d\n",sizeof(char*));
	printf("%d\n",sizeof(int*));
	printf("&&&&&&&&&&&&&&&&&&&&\n");
	printf("%d\n",sizeof(int));
	printf("%d\n",sizeof(a));
	printf("%d\n",sizeof(b));

	//int size = sizeof(char*);
	//printf("%i \n",size);


	return 0;
}