#include <iostream>
#include <cmath>
#include <time.h>
#include <fstream>
using namespace std;


// Hàm phát sinh mảng dữ liệu ngẫu nhiên
void GenerateRandomData(int a[], int n)
{
    srand((unsigned int)time(NULL));

    for (int i = 0; i < n; i++)
    {
        a[i] = rand()%n;
    }
}

// Hàm phát sinh mảng dữ liệu có thứ tự tăng dần
void GenerateSortedData(int a[], int n)
{
    for (int i = 0; i < n; i++)
    {
        a[i] = i;
    }
}

// Hàm phát sinh mảng dữ liệu có thứ tự ngược (giảm dần)
void GenerateReverseData(int a[], int n)
{
    for (int i = 0; i < n; i++)
    {
        a[i] = n - 1 - i;
    }
}

// Hàm phát sinh mảng dữ liệu gần như có thứ tự
void GenerateNearlySortedData(int a[], int n)
{
    for (int i = 0; i < n; i++)
    {
        a[i] = i;
    }
    srand((unsigned int) time(NULL));
    for (int i = 0; i < 10; i ++)
    {
        int r1 = rand()%n;
        int r2 = rand()%n;
        std::swap(a[r1], a[r2]);
    }
}

void GenerateData(int a[], int n, int dataType)
{
    switch (dataType)
    {
    case 0: // ngẫu nhiên
        GenerateRandomData(a, n);
        break;
    case 1: // có thứ tự
        GenerateSortedData(a, n);
        break;
    case 2: // có thứ tự ngược
        GenerateReverseData(a, n);
        break;
    case 3: // gần như có thứ tự
        GenerateNearlySortedData(a, n);
        break;
    default:
        printf("Error: unknown data type!\n");
    }
}

//---------------------------------------------------

string getDataName(int state) {
    switch (state)
    {
    case 0: // ngẫu nhiên
        return "RandomData";
        break;
    case 1: // có thứ tự
        return"SortedData";
        break;
    case 2: // có thứ tự ngược
        return "ReverseData";
        break;
    case 3: // gần như có thứ tự
        return "NearlySortedData";
        break;
    default:
        return "Undefined";
        break;
    }
}

void Output(string filename, int size, int arr[]) {
    if (size <= 0)
        return;

    ofstream fout;
    fout.open(filename);
    fout << size << "\n";
    for (int i = 0; i < size; ++i) {
        fout << arr[i];
        if(i < size -1)
            fout <<" ";
    }
    fout << endl;
    fout.close();
}

int main(){
    int *Arr, size = 0, dataType = 0;
    do{
        cout << "Enter size of array: ";
        cin >> size;
    }while (size<=0);
    Arr = new int [size];
    do{
        cout<<"<1> RandomData\n<2> SortedData\n<3> ReverseData\n<4> NearlySortedData\nEnter data type: ";
        cin >> dataType;
    }while(dataType<0||dataType>4);

    GenerateData(Arr, size, dataType);

    Output("input_sort.txt", size, Arr);

    cout << "All tasks completed!\n";
    system("pause");
    delete[] Arr;
    return 0;
}
