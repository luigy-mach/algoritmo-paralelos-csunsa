#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <time.h>
using namespace std;

#define SIZE 810



void fill_matrix(int m[][SIZE],int n,int elem)
{
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {
            m[i][j]=elem;
        }
    }
}

void print_matrix(int m[][SIZE],int n)
{
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {
            cout<<m[i][j]<<" ";
        }
        cout<<endl;
    }
}

void mult_matrix(int m1[][SIZE],int m2[][SIZE],int r[][SIZE],int n)
{
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {
            r[i][j]=0;
            for(int k=0;k<n;k++)
            {
                r[i][j]+=m1[i][k]*m2[k][j];
            }
        }
    }
}

int main()
{
	
	int m1[SIZE][SIZE];
    fill_matrix(m1,SIZE,2);
    int m2[SIZE][SIZE];
    fill_matrix(m2,SIZE,2);
    int r[SIZE][SIZE];
    fill_matrix(r,SIZE,0);

    const clock_t begin_time = clock();
    mult_matrix(m1,m2,r,SIZE);


    std::cout << "time "<<SIZE<<": "<<float( clock () - begin_time ) /  CLOCKS_PER_SEC<<endl;
	return 0;
}