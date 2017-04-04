
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
void prodoct3loop(int **a,int **b ,int **r, int tam){
  for(int i=0;i<tam;i++){
    for(int j=0;j<tam;j++){
      for(int k=0;k<tam;k++){
        r[i][j]+=(a[i][k]*b[k][j]);
      }
    }
  }
};



//matrices cuadradas del mismo tamaño
void product6loop(int **a,int **b ,int **r, int tam,int sizeofblock){
  if(sizeofblock>=tam){
    return;
  }

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

  int tamx=1200;

 //-------------prodoct3loop-----------------
  int tam1=tamx;
  int **m1,**m2,**r1;
  start(m1,tam1);
    fill(m1,tam1);
  start(m2,tam1);
    fill(m2,tam1);
  start(r1,tam1);
    fill(r1,tam1,0);

  //show(m1,tam1);
  //show(m2,tam1);
  //show(r1,tam1);

  float t1=clock();
  prodoct3loop(m1,m2,r1,tam1);
  t1=clock()-t1;
  //cout<<setprecision(0)<<fixed;
  cout<<"time 3loops: "<< ((float)t1)/CLOCKS_PER_SEC <<" s"<<endl;
  
  //show(r1,tam1);

 //--------------product6loop--------------------
  int tam2=tamx;
  int sizeofblock=2;
  int **m3,**m4,**r2;
  start(m3,tam2);
    fill(m3,tam2);
  start(m4,tam2);
    fill(m4,tam2);
  start(r2,tam2);
    fill(r2,tam2,0);

  //show(m3,tam2);
  //show(m4,tam2);
  //show(r2,tam2);

  float t2=clock();
  product6loop(m3,m4,r2,tam2,sizeofblock);
  t2=clock()-t2;
  //cout<<setprecision(0)<<fixed;
  cout<<"time 6loops: "<< ((float)t2)/CLOCKS_PER_SEC <<" s"<<endl;

  //show(r2,tam2);

  return 0;
};
