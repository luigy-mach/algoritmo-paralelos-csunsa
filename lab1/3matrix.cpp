#include<iostream>
#include<stdlib.h>
#include <ctime>

using namespace std;
#define COTA 5

void start(int **&a,int tam){
      a=new int*[tam];
      for(int i=0;i<tam;i++){
        a[i]=new int[tam];
      }
};

void fill(int **a,int tam,int value=1){
  //srand (time(NULL));
    for(int i=0;i<tam;i++){
      for(int j=0;j<tam;j++){
        a[i][j]=rand() % COTA *value;
      }
    }
};

void show(int **a,int tam){
  cout<<"-------------"<<endl;
  for(int i=0;i<tam;i++){
    for(int j=0;j<tam;j++){
      cout<<a[i][j]<<"  ";
    }
    cout<<endl;
  }
  cout<<"-------------"<<endl;
};


//matrices cuadradas del mismo tamaño
void prodoct3loop(int **a,int **b ,int **r, int tam){
  for(int i=0;i<tam;i++){
    for(int j=0;j<tam;j++){
      for(int k=0;k<tam;k++){
        r[i][j]+=(a[i][k]*b[k][j]);
      }
    }
  }
};

int main(){
  int tam=3 ;
  int **m1,**m2,**r;
  start(m1,tam);
    fill(m1,tam);
  start(m2,tam);
    fill(m2,tam);
  start(r,tam);
    fill(r,tam,0);

  show(m1,tam);
  show(m2,tam);
  show(r,tam);

  prodoct3loop(m1,m2,r,tam);
  show(r,tam);


  return 0;
};
