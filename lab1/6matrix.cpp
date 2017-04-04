
#include <stdlib.h>
#include <iomanip>
#include <iostream>
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
void product6loop(int **a,int **b ,int **r, int tam,int sizeofblock){
  if(sizeofblock>=tam){return;}
  for(int i=0 ; i<tam ; i+=sizeofblock ){
    for(int j=0 ; j<tam ; j+=sizeofblock ){
      for(int k=0 ; k<tam ; k+=sizeofblock){
        for(int ii=i ; ii<((i+sizeofblock)>tam?tam:(i+sizeofblock)) ;ii++){
          for(int jj=j ; jj<((j+sizeofblock)>tam?tam:(j+sizeofblock)) ;jj++){
            for(int kk=k ; kk<((k+sizeofblock)>tam?tam:(k+sizeofblock))  ;kk++){
              r[ii][kk]+=a[ii][jj]*b[jj][kk];
            }
          }
        }
      }
    }
  }
};



int main(){
  int sizeofblock=2;
  int tam=800;
  int **m1,**m2,**r;
  start(m1,tam);
    fill(m1,tam);
  start(m2,tam);
    fill(m2,tam);
  start(r,tam);
    fill(r,tam,0);

  //show(m1,tam);
  //show(m2,tam);
  //show(r,tam);
  float t=clock();

  product6loop(m1,m2,r,tam,sizeofblock);

  t=clock()-t;
  //cout<<setprecision(0)<<fixed;
  cout<<"timess: "<< ((float)t)/CLOCKS_PER_SEC <<" s"<<endl;

  //show(r,tam);


  return 0;
};
